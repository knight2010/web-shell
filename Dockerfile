FROM ubuntu:22.04

# 避免 apt 安装过程中的交互式配置中断
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# 合并安装基础工具、运行时、编译依赖与 ttyd Web Shell
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    iputils-ping \
    jq \
    net-tools \
    nodejs \
    npm \
    python3 \
    python3-pip \
    tmux \
    ttyd \
    vim-nox \
    wget \
    tar \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 设置默认工作目录
WORKDIR /root

# 安装与配置 spf13-vim 编辑器发行版
# 1. 拉取 spf13-vim 仓库与 Vundle 插件管理器
# 2. 建立配置文件软链接
# 3. 非交互式预装基础插件
RUN git clone -b 3.0 --depth=1 https://github.com/spf13/spf13-vim-3-0.git /root/.spf13-vim-3 \
    && ln -sf /root/.spf13-vim-3/.vimrc /root/.vimrc \
    && ln -sf /root/.spf13-vim-3/.vimrc.bundles /root/.vimrc.bundles \
    && mkdir -p /root/.vim/bundle \
    && git clone --depth=1 https://github.com/gmarik/vundle.git /root/.vim/bundle/vundle \
    && TERM=xterm vim -E -s -u /root/.vimrc.bundles +BundleInstall! +BundleClean! +qall || true

# 复制启动入口脚本与后台任务脚本
COPY entrypoint.sh /entrypoint.sh
COPY my_script.sh /root/my_script.sh

# 赋予执行权限
RUN chmod +x /entrypoint.sh /root/my_script.sh

# 声明端口环境变量（Render 默认通过环境变量 PORT 注入）
EXPOSE 10000

# 容器启动主入口
CMD ["/entrypoint.sh"]
