# Web Shell with spf13-vim & Automation Suite

基于 Ubuntu 22.04 构建的高性能公网 Web Shell 容器，预置了极客风格的 **spf13-vim** 编辑器全套插件套件、常用网络诊断工具、Node.js/Python 运行时，并支持后台任务常驻及 GitHub Actions 自动化构建与镜像发布。

---

## 包含组件与特性

* **Web 终端**：基于 C 语言高性能 `ttyd` + Xterm.js，支持全屏、自适应分辨率与快捷键映射。
* **安全鉴权**：强制 HTTP Basic Auth 访问认证，防止公网未授权渗透。
* **spf13-vim 编辑器**：预装 Steve Francia's Vim Distribution，自带 NERDTree（文件树）、CtrlP（模糊搜索）、Syntastic、Surround 等经典插件体系。
* **完整运行时**：内置 `Node.js 20`、`npm`、`python3`、`pip`、`tmux`、`git`、`curl`、`jq`。
* **CI/CD 自动化**：包含 GitHub Actions 工作流，代码推送后自动编译镜像并发布至 `ghcr.io`（GitHub Packages）。
* **开箱即用适配**：原生兼容 Render、Railway、Fly.io、云服务器 Docker 部署。

---

## 仓库文件结构

```text
.
├── Dockerfile                      # 深度合并优化的镜像构建文件
├── entrypoint.sh                   # 容器入口：拉起后台脚本与 ttyd 鉴权服务
├── my_script.sh                    # 示例后台自动化常驻任务
├── .dockerignore                   # 忽略不必要文件以加速镜像构建
├── .github/
│   └── workflows/
│       └── docker-publish.yml      # 自动打包并上传 GHCR 镜像的 CI/CD
└── README.md                       # 说明文档
```

---

## 快速部署指南

### 1. 本地构建与运行

```bash
# 构建镜像
docker build -t web-shell-spf13 .

# 启动容器并映射到宿主机 10000 端口
docker run -d \
  -p 10000:10000 \
  -e PORT=10000 \
  -e SHELL_USER=admin \
  -e SHELL_PASS=MySecretPassword123 \
  --name web-shell \
  web-shell-spf13
```
打开浏览器访问 `http://localhost:10000` 即可登录进入终端。

---

### 2. 部署到 Render 平台

1. 将本仓库完整代码上传至你的 GitHub。
2. 登录 [Render Dashboard](https://dashboard.render.com/)，点击 **New +** $\rightarrow$ **Web Service**。
3. 选择连接该 GitHub 仓库，Runtime 选择 **Docker**，Instance Type 选择 **Free**。
4. 在 **Environment Variables** 增加以下变量：
   * `SHELL_USER`: 登录用户名（如 `dev`）
   * `SHELL_PASS`: 登录密码（请设置高强度密码）
5. 点击 **Create Web Service** 完成部署上线。

---

### 3. GitHub Actions 自动打包发布镜像

本项目默认配置将镜像推送至 **GitHub Container Registry (GHCR)**：

1. 代码推送到 `main` 分支后，GitHub Actions 会自动触发构建。
2. 无需额外申请 Docker Hub Token，Actions 借由内置的 `secrets.GITHUB_TOKEN` 直接完成签名上传。
3. 构建完成后，前往 GitHub 仓库主页右侧的 **Packages**，即可找到类似 `ghcr.io/<你的用户名>/<仓库名>:latest` 的成品镜像。
4. 若需要拉取该公开镜像：
   ```bash
   docker pull ghcr.io/<你的用户名>/<仓库名>:latest
   ```

---

## spf13-vim 常用快捷指令

在终端中输入 `vim <文件名>` 即可直接体验 spf13-vim 环境：

| 快捷键 | 功能描述 |
| :--- | :--- |
| `\` 或 `,` | 预设 Leader 键 |
| `Ctrl + e` | 快速开关左侧 **NERDTree** 项目文件树 |
| `Ctrl + p` | 唤起 **CtrlP** 文件全盘模糊搜索 |
| `Ctrl + h/j/k/l` | 跨分屏（Split Windows）快速移动光标 |
| `,ig` | 一键开关缩进对齐参考线（Indent Guides） |
| `:BundleInstall` | 在 Vim 内部更新或安装配置的新插件 |
