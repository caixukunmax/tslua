# =============================================================================
# Skynet 运行时镜像
# 使用项目内纯净的 skynet/ 目录作为构建物料
# 使用 Skynet 自带的 Lua 5.4 编译 lua-protobuf
# =============================================================================

FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# 安装编译依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    git \
    && rm -rf /var/lib/apt/lists/*

# 从项目目录 COPY 纯净的 skynet 源码
WORKDIR /build
COPY ./skynet /build

# 编译 Skynet（使用原生 Makefile）
RUN make linux

# 编译 lua-protobuf（使用 Skynet 自带的 Lua）
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/starwing/lua-protobuf.git \
    && cd lua-protobuf \
    && gcc -O2 -fPIC \
        -I/build/3rd/lua \
        -c pb.c -o pb.o \
    && gcc -O2 -shared \
        -o pb.so pb.o \
    && cp pb.so /build/luaclib/ \
    && cp protoc.lua /build/lualib/

# =============================================================================
# 运行时镜像
# =============================================================================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 只安装运行时必需的依赖
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 创建非 root 用户
RUN useradd -m -s /bin/bash skynet

WORKDIR /skynet

# 从 builder 复制 Skynet（包含编译好的 lua-protobuf）
COPY --from=builder /build/skynet /skynet/skynet
COPY --from=builder /build/lualib /skynet/lualib
COPY --from=builder /build/service /skynet/service
COPY --from=builder /build/cservice /skynet/cservice
COPY --from=builder /build/luaclib /skynet/luaclib

# 创建服务目录
RUN mkdir -p /skynet/lua /skynet/logs \
    && chown -R skynet:skynet /skynet

# 复制默认配置文件
COPY ./skynet-runtime/config.tslua /skynet/config.tslua

# 复制编译好的 Lua 服务代码
COPY lua/ /skynet/lua/

# 复制原生 Lua 脚本（启动引导、全局对象注入等）
COPY native/ /skynet/lua/native/

# 暴露端口
EXPOSE 8888 9999

# 创建启动脚本
RUN echo '#!/bin/bash\n\
CONFIG_FILE="${SKYNET_CONFIG:-/skynet/config.tslua}"\n\
if [ ! -f "$CONFIG_FILE" ]; then\n\
    echo "ERROR: Config file not found: $CONFIG_FILE"\n\
    exit 1\n\
fi\n\
echo "Starting Skynet with config: $CONFIG_FILE"\n\
exec ./skynet "$CONFIG_FILE"' > /skynet/start.sh \
    && chmod +x /skynet/start.sh

USER skynet

CMD ["./start.sh"]
