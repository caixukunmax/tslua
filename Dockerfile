# 使用一个较新的 Ubuntu 基础镜像
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    # --- 基础工具 ---
    openssh-server \
    curl \
    wget \
    git \
    unzip \
    zip \
    sudo \
    vim \
    nano \
    htop \
    net-tools \
    telnet \
    man \
    locales \
    language-pack-zh-hans \
    # --- 版本控制 ---
    subversion \
    # --- 编译工具链 ---
    build-essential \
    # --- Python 环境 ---
    python3 \
    python3-pip \
    # --- Node.js 环境 ---
    && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    # --- 清理缓存 ---
    && rm -rf /var/lib/apt/lists/*

# --- Locale 设置 ---
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

# --- SSH 设置 ---
RUN echo 'root:123456' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN mkdir -p /var/run/sshd

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 22
CMD ["/usr/local/bin/start.sh"]
