FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 安装基础系统工具、运行时及 nginx 反向代理
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    iputils-ping \
    jq \
    net-tools \
    nginx \
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

WORKDIR /root

# 安装 superfile
RUN bash -c "$(curl -sLo- https://superfile.dev/install.sh)"

# 复制脚本
COPY entrypoint.sh /entrypoint.sh
COPY my_script.sh /root/my_script.sh
COPY argosbx.sh /root/argosbx.sh

RUN chmod +x /entrypoint.sh /root/my_script.sh

EXPOSE 80 8080 10000

CMD ["/entrypoint.sh"]