# Grok2API Docker 部署指南（连接外部 MySQL）

## 📋 前置要求

- Docker 20.10+
- Docker Compose 2.0+
- 已部署的 MySQL 数据库
- MySQL 中已创建 `grok2api` 数据库

## 🚀 快速启动

### 1. 配置环境变量

```bash
cd grok2api

# 复制环境变量模板
cp .env.docker .env

# 编辑配置
vim .env
```

**重要：修改 MySQL 连接信息**

```env
# 修改为你的 MySQL 连接信息
MYSQL_URL=mysql+aiomysql://用户名:密码@MySQL主机:3306/grok2api

# 示例：
# MYSQL_URL=mysql+aiomysql://grok2api:mypassword@192.168.1.100:3306/grok2api
```

### 2. 配置应用（可选）

编辑 `data/config.toml`：

```toml
[app]
app_url = "http://你的域名或IP:8999"  # 修改为实际访问地址
app_key = "grok2api"                  # 管理后台密码（建议修改）
api_key = ""                          # API 密钥（留空则不验证）
```

### 3. 启动服务

```bash
# 启动容器
docker-compose up -d

# 查看日志
docker-compose logs -f

# 检查服务状态
docker-compose ps
```

### 4. 访问服务

- **管理面板：** http://你的IP:8999/admin
- **API 地址：** http://你的IP:8999/v1/chat/completions
- **默认密码：** `grok2api`

## 🔧 MySQL 连接配置

### 连接格式

```
mysql+aiomysql://用户名:密码@主机:端口/数据库名
```

### 不同场景的配置

#### 场景 1: MySQL 在同一台服务器（Linux）

```env
# 使用宿主机 IP（查看：ip addr show docker0）
MYSQL_URL=mysql+aiomysql://grok2api:password@172.17.0.1:3306/grok2api
```

#### 场景 2: MySQL 在同一台服务器（Mac/Windows）

```env
# 使用特殊域名
MYSQL_URL=mysql+aiomysql://grok2api:password@host.docker.internal:3306/grok2api
```

#### 场景 3: MySQL 在其他服务器

```env
# 使用 IP 地址
MYSQL_URL=mysql+aiomysql://grok2api:password@192.168.1.100:3306/grok2api

# 或使用域名
MYSQL_URL=mysql+aiomysql://grok2api:password@mysql.example.com:3306/grok2api
```

#### 场景 4: 密码包含特殊字符

```env
# 需要 URL 编码特殊字符
# @ → %40
# : → %3A
# / → %2F
# ? → %3F
# # → %23

# 示例：密码是 pass@word:123
MYSQL_URL=mysql+aiomysql://grok2api:pass%40word%3A123@192.168.1.100:3306/grok2api
```

## 🔒 MySQL 配置检查

### 1. 确保 MySQL 允许远程连接

编辑 MySQL 配置文件（`/etc/mysql/mysql.conf.d/mysqld.cnf`）：

```ini
[mysqld]
bind-address = 0.0.0.0
```

重启 MySQL：
```bash
sudo systemctl restart mysql
```

### 2. 创建数据库和用户

```sql
-- 创建数据库
CREATE DATABASE IF NOT EXISTS grok2api 
  DEFAULT CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

-- 创建用户（如果不存在）
CREATE USER IF NOT EXISTS 'grok2api'@'%' IDENTIFIED BY 'your_password';

-- 授权
GRANT ALL PRIVILEGES ON grok2api.* TO 'grok2api'@'%';
FLUSH PRIVILEGES;
```

### 3. 测试连接

从 Docker 容器测试连接：

```bash
# 启动临时容器测试
docker run --rm -it mysql:8.0 mysql -h 你的MySQL主机 -u grok2api -p

# 输入密码后，如果能连接成功，说明配置正确
```

### 4. 防火墙配置

确保防火墙允许 3306 端口：

```bash
# Ubuntu/Debian
sudo ufw allow 3306

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload
```

## 📝 常用命令

### 服务管理

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose stop

# 重启服务
docker-compose restart

# 查看日志
docker-compose logs -f

# 查看实时日志（最后 100 行）
docker-compose logs -f --tail=100

# 查看服务状态
docker-compose ps

# 进入容器
docker-compose exec grok2api sh
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

### 查看资源使用

```bash
# 查看容器资源使用
docker stats grok2api

# 查看容器详细信息
docker inspect grok2api
```

## 🐛 故障排查

### 问题 1: 无法连接 MySQL

**检查步骤：**

1. 测试网络连通性
```bash
docker-compose exec grok2api ping 你的MySQL主机
```

2. 测试端口连通性
```bash
docker-compose exec grok2api nc -zv 你的MySQL主机 3306
```

3. 查看应用日志
```bash
docker-compose logs grok2api | grep -i mysql
docker-compose logs grok2api | grep -i error
```

4. 检查 MySQL 用户权限
```sql
-- 在 MySQL 中执行
SELECT user, host FROM mysql.user WHERE user='grok2api';
SHOW GRANTS FOR 'grok2api'@'%';
```

### 问题 2: 容器启动失败

```bash
# 查看详细错误
docker-compose logs grok2api

# 检查端口占用
sudo lsof -i :8999

# 检查配置文件
cat .env
cat data/config.toml
```

### 问题 3: 数据库连接超时

- 检查 MySQL 服务是否运行
- 检查防火墙设置
- 检查 MySQL 的 `max_connections` 配置
- 检查网络延迟

### 问题 4: 权限错误

```bash
# 确保目录权限正确
sudo chown -R 1000:1000 data logs cache

# 或使用当前用户
sudo chown -R $USER:$USER data logs cache
```

## 📊 性能优化

### 1. 增加 Worker 数量

编辑 `.env`：
```env
SERVER_WORKERS=4  # 根据 CPU 核心数调整
```

### 2. MySQL 连接池配置

在 `MYSQL_URL` 中添加参数：
```env
MYSQL_URL=mysql+aiomysql://user:pass@host:3306/grok2api?pool_size=10&max_overflow=20
```

### 3. 调整超时时间

编辑 `data/config.toml`：
```toml
[grok]
timeout = 120  # 增加超时时间
```

## 🔐 安全建议

1. **修改默认密码**
   - 管理后台密码（`data/config.toml` 中的 `app_key`）
   - MySQL 密码
   - API Key（`data/config.toml` 中的 `api_key`）

2. **使用 HTTPS**
   - 配置 Nginx 反向代理
   - 申请 SSL 证书（Let's Encrypt）

3. **限制访问**
   - 使用防火墙限制端口访问
   - 配置 API Key 验证
   - 使用 IP 白名单

4. **定期备份**
   - 备份 MySQL 数据库
   - 备份 `data/config.toml`

## 📁 目录结构

```
grok2api/
├── docker-compose.yml      # Docker Compose 配置
├── .env                    # 环境变量（需要创建）
├── data/
│   └── config.toml        # 应用配置
├── logs/                  # 日志目录（自动创建）
└── cache/                 # 缓存目录（自动创建）
```

## 🔗 Nginx 反向代理示例

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8999;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # SSE 支持（流式响应）
        proxy_buffering off;
        proxy_cache off;
        proxy_set_header Connection '';
        proxy_http_version 1.1;
        chunked_transfer_encoding off;
    }
}
```

## 📞 获取帮助

- 查看日志：`docker-compose logs -f`
- 检查配置：`docker-compose config`
- 查看网络：`docker network inspect grok2api-network`

---

**祝部署顺利！** 🎉
