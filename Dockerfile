FROM ubuntu:22.04

# 避免 apt 安装过程中的交互式配置中断
ENV DEBIAN_FRONTEND=noninteractive

# 1. 安装基础系统工具、网络工具、Python/Node 运行时及必要依赖
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
    tar \
    tmux \
    ttyd \
    unzip \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 设置默认工作目录
WORKDIR /root

# 2. 安装 superfile (替代原 spf13-vim)
RUN bash -c "$(curl -sLo- https://superfile.dev/install.sh)"

# 3. 复制启动脚本与后台任务脚本
COPY entrypoint.sh /entrypoint.sh
COPY my_script.sh /root/my_script.sh
COPY argosbx.sh /root/argosbx.sh

# 统一赋予执行权限
RUN chmod +x /entrypoint.sh /root/my_script.sh 

# 暴露端口 (Render 默认使用 $PORT)
EXPOSE 10000

# 容器启动主入口
CMD ["/entrypoint.sh"]