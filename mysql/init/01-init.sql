-- Grok2API 数据库初始化脚本
-- 此脚本会在 MySQL 容器首次启动时自动执行

-- 设置字符集
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS grok2api 
  DEFAULT CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE grok2api;

-- 创建 Token 表（示例，实际表结构由应用自动创建）
-- CREATE TABLE IF NOT EXISTS tokens (
--   id VARCHAR(255) PRIMARY KEY,
--   sso TEXT NOT NULL,
--   email VARCHAR(255),
--   status VARCHAR(50) DEFAULT 'active',
--   quota INT DEFAULT 80,
--   used INT DEFAULT 0,
--   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--   updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--   INDEX idx_status (status),
--   INDEX idx_email (email)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 授权
GRANT ALL PRIVILEGES ON grok2api.* TO 'grok2api'@'%';
FLUSH PRIVILEGES;

-- 完成
SELECT 'Grok2API database initialized successfully!' AS message;
