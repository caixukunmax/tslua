# =============================================================================
# Skynet 运行时镜像
# 使用项目内纯净的 skynet/ 目录作为构建物料
# 不修改任何 Skynet 源码，保持原生
# =============================================================================

FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# 安装编译依赖（不安装 git，因为直接从本地 COPY）
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 从项目目录 COPY 纯净的 skynet 源码
# 这样避免了每次构建都重新 clone，且保证版本可控
WORKDIR /build
COPY ./docker/skynet /build

# 编译 Skynet（使用原生 Makefile，不做任何修改）
RUN make linux

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

# 从 builder 复制 Skynet
COPY --from=builder /build/skynet /skynet/skynet
COPY --from=builder /build/lualib /skynet/lualib
COPY --from=builder /build/service /skynet/service
COPY --from=builder /build/cservice /skynet/cservice
COPY --from=builder /build/luaclib /skynet/luaclib

# 创建服务目录
RUN mkdir -p /skynet/service-ts /skynet/logs \
    && chown -R skynet:skynet /skynet

# 复制默认配置文件（保底配置，确保镜像能独立运行）
# 生产环境可通过 volume 挂载 /skynet-config/config.tslua 覆盖
COPY config.tslua /skynet/config.tslua

# 复制编译好的 Lua 服务代码（生产模式）
# 开发模式可通过 volume 挂载覆盖
COPY service-ts/ /skynet/service-ts/

# 暴露端口（根据需要调整）
EXPOSE 8888 9999

# 创建启动脚本（支持动态配置路径）
RUN echo '#!/bin/bash\n\
# 优先使用环境变量指定的配置，否则使用默认配置\n\
CONFIG_FILE="${SKYNET_CONFIG:-/skynet/config.tslua}"\n\
\n\
# 检查配置是否存在\n\
if [ ! -f "$CONFIG_FILE" ]; then\n\
    echo "ERROR: Config file not found: $CONFIG_FILE"\n\
    echo "Available configs:"\n\
    ls -la /skynet/*.tslua 2>/dev/null || echo "  (none in /skynet/)"\n\
    ls -la /skynet-config/*.tslua 2>/dev/null || echo "  (none in /skynet-config/)"\n\
    exit 1\n\
fi\n\
\n\
echo "Starting Skynet with config: $CONFIG_FILE"\n\
exec ./skynet "$CONFIG_FILE"' > /skynet/start.sh \
    && chmod +x /skynet/start.sh

# 切换用户
USER skynet

# 启动命令（可通过环境变量指定配置路径）
CMD ["./start.sh"]