# 热更新架构说明

本项目采用**分层架构**设计，支持业务逻辑的热更新，无需重启服务器。

## 架构设计

### 三层结构

```
┌─────────────────────────────────────┐
│   入口层 (index.ts)                 │  ← 服务启动，消息分发
│   - 服务启动                         │  ← 支持热更新命令
│   - 消息路由                         │
└──────────┬──────────────────────────┘
           │ 依赖注入
           ↓
┌─────────────────────────────────────┐
│   逻辑层 (logic.ts)                 │  ← 业务逻辑，可热更新
│   - 无状态                           │  ← 所有状态从 store 获取
│   - 纯逻辑处理                       │  ← 频繁修改
└──────────┬──────────────────────────┘
           │ 访问数据
           ↓
┌─────────────────────────────────────┐
│   数据层 (store.ts)                 │  ← 数据持久化，不热更
│   - 管理状态                         │  ← 保证数据不丢失
│   - 数据操作                         │  ← 很少修改
└─────────────────────────────────────┘
```

### 关键特性

#### 1. 数据层（store.ts）
- **不会被热更新**，保证运行时状态不丢失
- 负责数据的 CRUD 操作
- 提供状态导出/导入接口（用于未来的状态迁移）

#### 2. 逻辑层（logic.ts）
- **可以被热更新**，修改业务逻辑无需重启
- 通过依赖注入获取数据层实例
- 无状态设计，所有数据从 store 获取

#### 3. 入口层（index.ts）
- 持有数据层实例（不变）
- 持有逻辑层实例（可替换）
- 提供热更新接口

## 使用方法

### 开发流程

#### 1. 修改业务逻辑
```bash
# 编辑 logic.ts
vim src/app/services/gateway/logic.ts
```

#### 2. 编译并热更新
```bash
# 方式一：使用热更新脚本（推荐）
./scripts/hotfix_service.sh gateway :01000002

# 方式二：手动执行
./scripts/ts2lua.sh                    # 编译
# 然后在 Skynet 控制台执行：
# call :01000002 hotfix
```

### 热更新命令

服务支持以下热更新相关命令：

#### `hotfix` - 热更新逻辑层
```lua
-- 在 Skynet 控制台执行
call <service_address> hotfix
```

#### `get_state` - 查询当前状态
```lua
-- 查看服务的运行状态
call <service_address> get_state
```

### 示例场景

#### 场景 1：修改连接处理逻辑

1. 修改 `logic.ts` 中的 `handleConnect` 方法
2. 执行 `./scripts/hotfix_service.sh gateway :01000002`
3. 新的连接会使用新逻辑，已有连接数据不丢失

#### 场景 2：添加新功能

1. 在 `logic.ts` 中添加新方法
2. 在 `index.ts` 中添加对应的命令处理
3. 编译并热更新
4. 新功能立即生效

## 热更新原理

### Lua 层面

```lua
-- 1. 清除模块缓存
package.loaded['app.services.gateway.logic'] = nil

-- 2. 重新 require
local new_logic = require('app.services.gateway.logic')

-- 3. 创建新实例（注入旧的 store）
logic = new_logic.GatewayLogic(store)
```

### TypeScript 层面

```typescript
async function hotfixLogic(): Promise<void> {
  // 1. 清除 Lua 模块缓存
  _G.package.loaded['app.services.gateway.logic'] = null;
  
  // 2. 重新导入
  const { GatewayLogic: NewLogic } = await import('./logic');
  
  // 3. 替换实例（保持 store 不变）
  logic = new NewLogic(store);
}
```

## 注意事项

### ✅ 可以热更新的内容

- 业务逻辑方法实现
- 算法优化
- 错误处理逻辑
- 日志输出内容
- 消息转发规则

### ❌ 不能热更新的内容

- 数据结构定义（Connection 接口）
- 数据层方法签名
- 依赖的框架代码
- 入口层的消息分发逻辑

### ⚠️ 热更新最佳实践

1. **修改前备份**：确保可以快速回滚
2. **小步迭代**：每次只改一个功能
3. **验证测试**：热更后立即测试新功能
4. **保持兼容**：不要修改数据结构
5. **记录变更**：清楚知道改了什么

## 故障排查

### 热更新失败

```bash
# 1. 检查编译是否成功
./scripts/ts2lua.sh

# 2. 检查 Lua 文件是否生成
ls -l dist/lua/app/services/gateway/logic.lua

# 3. 查看 Skynet 日志
tail -f skynet/logs/error.log
```

### 状态丢失

如果热更新后状态丢失：
```lua
-- 查询状态
call <service_address> get_state

-- 如果状态为空，可能是数据层也被热更了
-- 解决方案：重启服务恢复
```

## 高级功能

### 状态迁移

未来可以实现跨版本的状态迁移：

```typescript
// 在新版本中
async function migrateState(oldState: any): Promise<void> {
  // 1. 导出旧状态
  const state = store.exportState();
  
  // 2. 转换数据格式
  const newState = transformState(state);
  
  // 3. 导入新状态
  store.importState(newState);
}
```

### 批量热更新

对于多个相同类型的服务：

```bash
# 获取所有 gateway 服务地址
# 批量执行热更新
./scripts/batch_hotfix.sh gateway
```

## 性能影响

- **热更新时间**：< 100ms
- **内存开销**：仅增加一个逻辑层实例
- **运行性能**：热更后性能与重启后相同
- **状态保持**：100% 保持原有数据

## 与其他服务的集成

Gateway 服务已完成热更新改造，其他服务（Login, Game）可以参考相同的模式进行改造。

建议按以下顺序改造：
1. ✅ Gateway（已完成）
2. Login（待改造）
3. Game（待改造）
