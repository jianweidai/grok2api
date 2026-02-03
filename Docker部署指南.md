# Grok2API Docker 部署指南

## 📋 前置要求

- Docker 20.10+
- Docker Compose 2.0+

## 🚀 快速启动

### 1. 配置环境变量

```bash
# 复制环境变量模板
cp .env.docker .env

# 编辑配置（可选，使用默认配置也可以）
vim .env
```

### 2. 启动服务

```bash
# 启动所有服务（MySQL + Grok2API）
docker-compose up -d

# 查看日志
docker-compose logs -f

# 只查看应用日志
docker-compose logs -f grok2api

# 只查看 MySQL 日志
docker-compose logs -f mysql
```

### 3. 访问服务

- **管理面板：** http://localhost:8999/admin
- **API 地址：** http://localhost:8999/v1/chat/completions
- **默认密码：** `grok2api`（在 data/config.toml 中配置）

### 4. 添加 Token

访问管理面板，添加从 grok 项目获取的 SSO Cookie。

## 📊 存储方式对比

| 存储类型 | 优点 | 缺点 | 适用场景 |
|---------|------|------|----------|
| **local** | 简单，无需额外服务 | 不支持多 worker | 单机部署 |
| **MySQL** | 持久化，支持多 worker | 需要 MySQL 服务 | **推荐生产环境** |
| **Redis** | 高性能，支持多 worker | 数据在内存中 | 高并发场景 |
| **PostgreSQL** | 功能强大，支持多 worker | 需要 PgSQL 服务 | 大型部署 |

## ⚙️ 配置说明

### 环境变量（.env 文件）

```env
# 服务端口
SERVER_PORT=8999

# Worker 数量（使用 MySQL 时可以设置 > 1）
SERVER_WORKERS=1

# MySQL 配置
MYSQL_DATABASE=grok2api
MYSQL_USER=grok2api
MYSQL_PASSWORD=grok2api_pass
MYSQL_ROOT_PASSWORD=grok2api_root_pass
```

### 应用配置（data/config.toml）

```toml
[app]
app_url = "http://localhost:8999"  # 修改为你的域名
app_key = "grok2api"               # 管理后台密码
api_key = ""                       # API 调用密钥（留空则不验证）

[grok]
stream = false                     # 默认非流式响应
thinking = true                    # 启用思维链
timeout = 120                      # 超时时间

[token]
auto_refresh = true                # 自动刷新 Token
refresh_interval_hours = 8         # 刷新间隔
```

## 🔄 切换存储方式

### 使用 MySQL（推荐）

```yaml
# docker-compose.yml
environment:
  SERVER_STORAGE_TYPE: mysql
  SERVER_STORAGE_URL: mysql+aiomysql://grok2api:grok2api_pass@mysql:3306/grok2api
```

### 使用 Redis

1. 取消 docker-compose.yml 中 Redis 服务的注释
2. 修改环境变量：

```yaml
environment:
  SERVER_STORAGE_TYPE: redis
  SERVER_STORAGE_URL: redis://:grok2api_redis_pass@redis:6379/0
```

### 使用 Local（默认）

```yaml
environment:
  SERVER_STORAGE_TYPE: local
  SERVER_STORAGE_URL: ""
```

需要挂载 token.json：
```yaml
volumes:
  - ./data/token.json:/app/data/token.json
```

## 🛠️ 常用命令

### 服务管理

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose stop

# 重启服务
docker-compose restart

# 停止并删除容器
docker-compose down

# 停止并删除容器和数据卷（⚠️ 会删除数据库数据）
docker-compose down -v

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 进入容器
docker-compose exec grok2api sh
docker-compose exec mysql bash
```

### 数据库管理

```bash
# 连接 MySQL
docker-compose exec mysql mysql -u grok2api -p
# 密码：grok2api_pass

# 备份数据库
docker-compose exec mysql mysqldump -u grok2api -pgrok2api_pass grok2api > backup.sql

# 恢复数据库
docker-compose exec -T mysql mysql -u grok2api -pgrok2api_pass grok2api < backup.sql

# 查看数据库大小
docker-compose exec mysql mysql -u grok2api -pgrok2api_pass -e "
  SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
  FROM information_schema.tables
  WHERE table_schema = 'grok2api'
  GROUP BY table_schema;
"
```

### 更新镜像

```bash
# 拉取最新镜像
docker-compose pull

# 重新创建容器
docker-compose up -d --force-recreate

# 清理旧镜像
docker image prune -f
```

## 📁 目录结构

```
grok2api/
├── docker-compose.yml      # Docker Compose 配置
├── .env                    # 环境变量配置
├── data/
│   ├── config.toml        # 应用配置
│   └── token.json         # Token 数据（local 模式）
├── logs/                  # 日志目录
├── cache/                 # 缓存目录
└── mysql/
    └── init/
        └── 01-init.sql    # MySQL 初始化脚本
```

## 🔒 安全建议

1. **修改默认密码**
   - MySQL 密码（.env 文件）
   - 管理后台密码（data/config.toml）
   - API Key（data/config.toml）

2. **使用 HTTPS**
   - 配置 Nginx 反向代理
   - 申请 SSL 证书

3. **限制端口访问**
   - MySQL 端口不要暴露到公网
   - 使用防火墙限制访问

4. **定期备份**
   - 备份 MySQL 数据库
   - 备份 data/config.toml

## 🐛 故障排查

### 问题 1: 容器启动失败

```bash
# 查看详细日志
docker-compose logs grok2api

# 检查端口占用
lsof -i :8999
lsof -i :3306
```

### 问题 2: 无法连接 MySQL

```bash
# 检查 MySQL 是否健康
docker-compose ps

# 测试连接
docker-compose exec grok2api ping mysql

# 查看 MySQL 日志
docker-compose logs mysql
```

### 问题 3: Token 数据丢失

- 使用 MySQL 存储，数据持久化在 `mysql_data` 卷中
- 不要使用 `docker-compose down -v`，会删除数据卷

### 问题 4: 性能问题

- 增加 Worker 数量（需要使用 MySQL/Redis）
- 调整 MySQL 配置
- 增加服务器资源

## 📝 生产环境建议

1. **使用 MySQL 存储**（支持多 worker）
2. **配置 Nginx 反向代理**
3. **启用 HTTPS**
4. **设置自动备份**
5. **监控服务状态**
6. **限制 API 访问频率**

## 🔗 相关链接

- [Grok2API GitHub](https://github.com/chenyme/grok2api)
- [Docker 文档](https://docs.docker.com/)
- [Docker Compose 文档](https://docs.docker.com/compose/)

---

**祝部署顺利！** 🎉
