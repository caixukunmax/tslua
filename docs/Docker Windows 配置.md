# Docker Windows 版配置文件

> 适用于 Docker Desktop Windows 版本的 `daemon.json` 配置

## 配置文件位置

```
%USERPROFILE%\.docker\daemon.json
```

或 Docker Desktop 设置中通过 UI 配置：
**Settings > Docker Engine**

---

## 推荐配置

```json
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "experimental": false,
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://dockerproxy.com",
    "https://docker.mirrors.ustc.edu.cn",
    "https://docker.nju.edu.cn",
    "https://mirror.baidubce.com"
  ]
}
```

---

## 配置项说明

### builder.gc - 构建缓存垃圾回收

| 字段 | 值 | 说明 |
|------|-----|------|
| `defaultKeepStorage` | `"20GB"` | 保留的缓存空间上限 |
| `enabled` | `true` | 启用自动垃圾回收 |

**作用**：限制 Docker BuildKit 构建缓存占用的磁盘空间，防止无限增长。

### experimental

| 值 | 说明 |
|-----|------|
| `false` | 关闭实验性功能（推荐稳定环境使用） |
| `true` | 开启实验性功能 |

### registry-mirrors - 镜像加速

国内镜像源列表，按优先级排序：

| 镜像地址 | 提供商 | 备注 |
|---------|--------|------|
| `https://docker.m.daocloud.io` |  DaoCloud | 推荐，速度快 |
| `https://dockerproxy.com` | Docker Proxy | 社区维护 |
| `https://docker.mirrors.ustc.edu.cn` | 中科大 | 高校镜像，稳定 |
| `https://docker.nju.edu.cn` | 南京大学 | 高校镜像 |
| `https://mirror.baidubce.com` | 百度云 | 百度出品 |

---

## 应用配置

### 方法 1：通过 Docker Desktop UI

1. 打开 Docker Desktop
2. 点击右上角 **Settings**（齿轮图标）
3. 选择 **Docker Engine**
4. 将 JSON 配置粘贴到编辑框
5. 点击 **Apply & Restart**

### 方法 2：直接修改配置文件

1. 打开文件：`C:\Users\<你的用户名>\.docker\daemon.json`
2. 粘贴上述配置内容
3. 重启 Docker Desktop

---

## 验证配置

```powershell
# 查看当前配置
docker info

# 查看镜像源是否生效（在 Registry Mirrors 部分）
docker info | findstr "Registry"

# 测试拉取速度
docker pull nginx:alpine
```

---

## 故障排查

### 配置后 Docker 无法启动

```powershell
# 检查配置文件语法是否正确
# JSON 格式错误会导致 Docker 无法启动

# 重置配置
Remove-Item "$env:USERPROFILE\.docker\daemon.json"
```

### 镜像源不生效

- 确认 JSON 格式正确（特别是逗号、引号）
- 重启 Docker Desktop
- 部分镜像源可能已失效，尝试更换其他源

---

## 相关文件

- 本地备份：`docker/daemon.json`
