# Grok2API 启动指南

## 📋 项目说明

Grok2API 是一个将 Grok 网页版转换为 OpenAI 兼容 API 的服务。

## 🚀 快速启动

### 方法 1: 使用 uv（推荐）

```bash
# 1. 进入项目目录
cd grok2api

# 2. 安装依赖（uv 会自动创建虚拟环境）
uv sync

# 3. 启动服务
uv run main.py
```

### 方法 2: 使用 Python venv

```bash
# 1. 进入项目目录
cd grok2api

# 2. 创建虚拟环境
python3 -m venv venv

# 3. 激活虚拟环境
source venv/bin/activate  # macOS/Linux
# Windows: venv\Scripts\activate

# 4. 安装依赖
pip install -r requirements.txt
# 或者手动安装：
pip install fastapi uvicorn curl-cffi httpx loguru pydantic-settings python-dotenv aiofiles orjson tomli pyyaml redis aiomysql asyncpg sqlalchemy python-multipart greenlet

# 5. 启动服务
python main.py
```

### 方法 3: 使用 Docker（生产环境）

```bash
# 1. 进入项目目录
cd grok2api

# 2. 启动服务
docker compose up -d

# 3. 查看日志
docker compose logs -f

# 4. 停止服务
docker compose down
```

---

## ⚙️ 配置说明

### 1. 环境变量配置（可选）

创建 `.env` 文件：

```env
# 日志级别
LOG_LEVEL=INFO

# 服务配置
SERVER_HOST=0.0.0.0
SERVER_PORT=8000
SERVER_WORKERS=1

# 存储类型（local/redis/mysql/pgsql）
SERVER_STORAGE_TYPE=local
SERVER_STORAGE_URL=
```

### 2. 应用配置

编辑 `data/config.toml`：

```toml
[app]
app_url = "http://127.0.0.1:8000"  # 外部访问地址
app_key = "grok2api"               # 管理后台密码（建议修改）
api_key = ""                       # API 调用密钥（留空则不验证）
image_format = "url"               # 图片格式：url 或 base64
video_format = "url"               # 视频格式：url

[grok]
temporary = true                   # 临时对话模式
stream = true                      # 流式响应
thinking = true                    # 思维链输出
timeout = 120                      # 超时时间（秒）

[token]
auto_refresh = true                # 自动刷新 Token
refresh_interval_hours = 8         # 刷新间隔（小时）
fail_threshold = 5                 # 失败阈值
```

### 3. 导入账号

编辑 `data/token.json`，添加从 grok 项目获取的 SSO Cookie：

```json
{
  "account1": {
    "sso": "eyJ0eXAiOiJKV1Q...",
    "email": "xxx@example.com",
    "status": "active"
  },
  "account2": {
    "sso": "eyJ0eXAiOiJKV1Q...",
    "email": "yyy@example.com",
    "status": "active"
  }
}
```

**从 grok 项目导入：**
- SSO Cookie 在 `grok/keys/grok.txt`
- 完整账号信息在 `grok/keys/accounts.txt`（格式：邮箱:密码:SSO）

---

## 🌐 访问服务

### 管理面板

```
http://localhost:8000/admin
```

默认密码：`grok2api`（对应 `app.app_key` 配置）

### API 接口

#### 1. 聊天对话

```bash
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "model": "grok-4",
    "messages": [{"role":"user","content":"你好"}],
    "stream": false
  }'
```

#### 2. 图像生成

```bash
curl http://localhost:8000/v1/images/generations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "model": "grok-imagine-1.0",
    "prompt": "一只在太空漂浮的猫",
    "n": 1
  }'
```

#### 3. 获取模型列表

```bash
curl http://localhost:8000/v1/models \
  -H "Authorization: Bearer YOUR_API_KEY"
```

---

## 📊 可用模型

| 模型名                     | 计次 | 功能         |
| :------------------------- | :--: | :----------- |
| `grok-3`                 |  1  | 对话 + 图像  |
| `grok-3-fast`            |  1  | 对话 + 图像  |
| `grok-4`                 |  1  | 对话 + 图像  |
| `grok-4-mini`            |  1  | 对话 + 图像  |
| `grok-4-fast`            |  1  | 对话 + 图像  |
| `grok-4.1`               |  1  | 对话 + 图像  |
| `grok-4.1-thinking`      |  4  | 深度思考     |
| `grok-imagine-1.0`       |  4  | 图像生成     |
| `grok-imagine-1.0-video` |  -  | 视频生成     |

---

## 🔧 常见问题

### 1. 端口被占用

修改 `.env` 文件中的 `SERVER_PORT`，或启动时指定：

```bash
SERVER_PORT=8001 uv run main.py
```

### 2. 没有 uv 命令

安装 uv：

```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# 或使用 pip
pip install uv
```

### 3. Python 版本要求

项目要求 Python >= 3.13，检查版本：

```bash
python3 --version
```

如果版本过低，需要升级 Python。

### 4. 账号导入格式

`data/token.json` 格式示例：

```json
{
  "user1": {
    "sso": "完整的SSO_Cookie",
    "email": "邮箱地址",
    "status": "active"
  }
}
```

### 5. API Key 验证

如果 `app.api_key` 为空，则不验证 API Key。
如果设置了值，调用 API 时需要在 Header 中添加：

```
Authorization: Bearer YOUR_API_KEY
```

---

## 📝 启动检查清单

- [ ] Python 3.13+ 已安装
- [ ] 依赖包已安装（uv sync 或 pip install）
- [ ] `data/config.toml` 已配置
- [ ] `data/token.json` 已添加账号
- [ ] 端口 8000 未被占用

全部完成后运行：

```bash
uv run main.py
```

或

```bash
python main.py
```

---

## 🎯 下一步

1. 访问管理面板：http://localhost:8000/admin
2. 查看账号状态和用量
3. 测试 API 接口
4. 集成到你的应用中

**祝使用愉快！** 🎉
