# cftunnel

Cloudflare Tunnel 一键管理工具 — 3 条命令搞定内网穿透。

把 Cloudflare Tunnel 的繁琐配置流程（装 cloudflared → 登录 → 创建隧道 → 写 config → 配 DNS → 注册服务）封装成简单的 CLI 命令。

## 特性

- **一键初始化** — 交互式向导，输入 Token 即可创建隧道
- **自动 DNS** — 添加路由时自动创建 CNAME 记录
- **进程托管** — 自动下载 cloudflared，支持注册系统服务开机自启
- **自动更新** — 内置版本检查和自更新
- **AI 友好** — 内置 Claude Code / OpenClaw Skills，AI 助手可直接管理隧道

## 安装

### 一键安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/qingchencloud/cftunnel/main/install.sh | bash
```

### 手动下载

从 [Releases](https://github.com/qingchencloud/cftunnel/releases) 下载对应平台的二进制文件：

```bash
# macOS Apple Silicon
curl -fsSL https://github.com/qingchencloud/cftunnel/releases/latest/download/cftunnel_darwin_arm64.tar.gz | tar xz -C /usr/local/bin/

# macOS Intel
curl -fsSL https://github.com/qingchencloud/cftunnel/releases/latest/download/cftunnel_darwin_amd64.tar.gz | tar xz -C /usr/local/bin/

# Linux amd64
curl -fsSL https://github.com/qingchencloud/cftunnel/releases/latest/download/cftunnel_linux_amd64.tar.gz | tar xz -C /usr/local/bin/

# Linux arm64
curl -fsSL https://github.com/qingchencloud/cftunnel/releases/latest/download/cftunnel_linux_arm64.tar.gz | tar xz -C /usr/local/bin/
```

### 从源码构建

```bash
git clone https://github.com/qingchencloud/cftunnel.git
cd cftunnel
make build
```

## 快速上手

### 1. 准备 Cloudflare API Token

登录 [Cloudflare Dashboard](https://dash.cloudflare.com) → 右上角头像 → 我的个人资料 → API 令牌 → 创建令牌 → 创建自定义令牌 → 开始使用

添加 3 条权限（点「+ 添加更多」逐条添加）：

```
┌──────────────────────────────────────────────────┐
│ 第 1 行: 帐户 │ Cloudflare Tunnel │ 编辑       │
│ 第 2 行: 区域 │ DNS              │ 编辑       │
│ 第 3 行: 区域 │ 区域设置          │ 读取       │
└──────────────────────────────────────────────────┘
```

> **注意**: 第 2、3 行需先将左侧「帐户」切换为「区域」

区域资源 → 包括 → 特定区域 → 选择你的域名

### 2. 初始化

```bash
# 交互式（推荐）
cftunnel init

# 非交互式
cftunnel init --token <your-token> --account <account-id> --name my-tunnel
```

### 3. 添加路由

```bash
# 将 app.example.com 指向本地 3000 端口
cftunnel add myapp 3000 --domain app.example.com
```

### 4. 启动隧道

```bash
cftunnel up
```

搞定！现在可以通过 `app.example.com` 访问你本地的 3000 端口服务了。

## 命令参考

### 配置管理

| 命令 | 说明 |
|------|------|
| `cftunnel init` | 交互式初始化（支持 `--token`/`--account`/`--name`） |
| `cftunnel add <名称> <端口> --domain <域名>` | 添加路由（自动创建 CNAME） |
| `cftunnel remove <名称>` | 删除路由（自动清理 DNS） |
| `cftunnel list` | 列出所有路由 |

### 运行管理

| 命令 | 说明 |
|------|------|
| `cftunnel up` | 启动隧道（自动下载 cloudflared） |
| `cftunnel down` | 停止隧道 |
| `cftunnel status` | 查看隧道状态 |
| `cftunnel logs [-f]` | 查看日志（`-f` 实时跟踪） |

### 系统服务

| 命令 | 说明 |
|------|------|
| `cftunnel install` | 注册系统服务（macOS launchd / Linux systemd） |
| `cftunnel uninstall` | 卸载系统服务 |

### 隧道生命周期

| 命令 | 说明 |
|------|------|
| `cftunnel destroy [--force]` | 删除隧道 + 所有 DNS 记录 |
| `cftunnel reset [--force]` | 完全重置（删隧道 + 清本地配置） |

### 版本管理

| 命令 | 说明 |
|------|------|
| `cftunnel version [--check]` | 显示版本 / 检查更新 |
| `cftunnel update` | 自动更新到最新版 |

## 典型使用场景

### 场景 1: 暴露本地开发服务

```bash
cftunnel init
cftunnel add dev 3000 --domain dev.example.com
cftunnel up
# 现在 dev.example.com 指向 localhost:3000
```

### 场景 2: Webhook 接收

```bash
cftunnel add webhook 9801 --domain webhook.example.com
cftunnel up
cftunnel install  # 开机自启
```

### 场景 3: 多服务同时暴露

```bash
cftunnel add api 8080 --domain api.example.com
cftunnel add web 3000 --domain web.example.com
cftunnel add admin 8888 --domain admin.example.com
cftunnel list
```

## 配置文件

配置存储在 `~/.cftunnel/config.yml`：

```yaml
version: 1
auth:
  api_token: "your-token"
  account_id: "your-account-id"
tunnel:
  id: "tunnel-uuid"
  name: "my-tunnel"
  token: "tunnel-run-token"
routes:
  - name: myapp
    hostname: app.example.com
    service: http://localhost:3000
    zone_id: "auto-detected"
    dns_record_id: "auto-created"
```

## AI 助手集成

cftunnel 内置了 AI 助手 Skills，让 Claude Code、OpenClaw 等 AI 编码助手可以直接管理你的隧道。

### Claude Code

将项目克隆到本地后，Claude Code 会自动加载 `.claude/skills/cftunnel.md`，你可以直接对 Claude Code 说：

```
帮我用 cftunnel 把本地 3000 端口暴露到 dev.example.com
```

### OpenClaw / 其他 AI 助手

复制以下提示词给你的 AI 助手：

```
你可以使用 cftunnel CLI 工具管理 Cloudflare Tunnel。

安装: curl -fsSL https://raw.githubusercontent.com/qingchencloud/cftunnel/main/install.sh | bash

常用命令:
- cftunnel init --token <TOKEN> --account <ACCOUNT_ID> --name <名称>  # 初始化
- cftunnel add <名称> <端口> --domain <域名>  # 添加路由
- cftunnel remove <名称>  # 删除路由
- cftunnel up / down  # 启停隧道
- cftunnel status  # 查看状态
- cftunnel list  # 列出路由
- cftunnel destroy --force  # 删除隧道
- cftunnel install  # 注册系统服务

执行命令前请确认用户已完成 cftunnel init 初始化。
添加路由时会自动创建 DNS CNAME 记录，删除时自动清理。
```

## 开发

```bash
# 构建
make build

# 发版（推送 tag 自动触发 GitHub Actions）
git tag v0.1.0
git push --tags
```

## License

MIT
