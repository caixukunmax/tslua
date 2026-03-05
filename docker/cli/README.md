# TS-Skynet Docker 远程管理工具

在 Windows 命令行中管理远程 Linux 服务器上的 Docker 容器。

## 特点

- ✅ **无需额外依赖** - 纯 Node.js 实现
- ✅ **彩色界面** - 清晰的命令行菜单
- ✅ **一键同步** - TS 编译后一键同步到远程容器
- ✅ **实时日志** - 查看容器日志
- ✅ **SSH 直连** - 支持密钥/密码登录

## 界面预览

```
╔════════════════════════════════════════════════════════════╗
║          TS-Skynet Docker 远程管理器                       ║
╠════════════════════════════════════════════════════════════╣
║  服务器: 192.168.1.100                                     ║
║  容器: tslua-skynet                                        ║
║  状态: Up 2 hours                                          ║
╠════════════════════════════════════════════════════════════╣
║  1. 启动容器          5. 查看日志（实时）                  ║
║  2. 停止容器          6. 构建镜像                          ║
║  3. 重启容器          7. 进入容器 Shell                    ║
║  4. 同步代码 →        8. 执行自定义命令                    ║
╠════════════════════════════════════════════════════════════╣
║  9. 编辑配置            0. 退出                            ║
╚════════════════════════════════════════════════════════════╝

请选择操作:
```

## 快速开始

### 1. 初始化配置

```bash
npm run docker:init
```

或

```bash
cd docker/cli
node index.js --init
```

### 2. 编辑配置

编辑 `docker/cli/config.json`：

```json
{
  "remote": {
    "host": "192.168.1.100",
    "port": 22,
    "username": "root",
    "privateKey": "C:/Users/你的用户名/.ssh/id_rsa"
  },
  "docker": {
    "containerName": "tslua-skynet",
    "imageName": "tslua-skynet-runtime",
    "remoteLuaPath": "/skynet/lua",
    "localLuaPath": "../../server/dist/lua"
  }
}
```

### 3. 启动管理器

```bash
npm run docker:manage
```

## 工作流程

### 日常开发流程

```bash
# 1. 编译 TypeScript → Lua
npm run build:ts

# 2. 启动管理器
npm run docker:manage

# 3. 在菜单中选择 4. 同步代码
# 4. 选择 5. 查看日志 观察效果
```

### 完整菜单功能

| 选项 | 功能 | 说明 |
|------|------|------|
| `1` | 启动容器 | 启动远程 Docker 容器 |
| `2` | 停止容器 | 停止远程 Docker 容器 |
| `3` | 重启容器 | 重启远程 Docker 容器 |
| `4` | **同步代码** | 本地 Lua → 远程容器（最常用） |
| `5` | 查看日志 | 显示最近 50 条日志 |
| `6` | 构建镜像 | 提示手动构建命令 |
| `7` | 进入 Shell | SSH 进入容器内部 |
| `8` | 自定义命令 | 在远程服务器执行命令 |
| `9` | 编辑配置 | 打开配置文件编辑器 |
| `0/q` | 退出 | 退出管理器 |

## 集成命令

在根目录可以直接使用：

```bash
# 启动管理器
npm run docker:manage

# 初始化配置
npm run docker:init
```

## 配置说明

### SSH 密钥配置

Windows 生成 SSH 密钥：

```powershell
ssh-keygen -t rsa -b 4096
```

将公钥复制到远程服务器：

```powershell
ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.1.100
```

### 密码登录（不推荐）

如果不想用密钥，可以修改配置：

```json
{
  "remote": {
    "host": "192.168.1.100",
    "port": 22,
    "username": "root",
    "password": "你的密码"
  }
}
```

然后修改 `simple.js` 中的 SSH 命令逻辑。

## 故障排除

### 连接失败

1. 检查 SSH 是否能正常连接：
   ```bash
   ssh root@192.168.1.100
   ```

2. 检查配置文件路径是否正确

3. Windows 下私钥路径使用正斜杠或双反斜杠：
   ```json
   "privateKey": "C:/Users/xxx/.ssh/id_rsa"
   ```

### 同步代码失败

1. 确保本地 Lua 文件已编译：
   ```bash
   npm run build:ts
   ```

2. 检查 `localLuaPath` 路径是否正确

3. 检查远程容器是否正在运行
