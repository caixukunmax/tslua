# 脚本使用说明

本目录包含项目的所有管理脚本，用于简化开发和部署流程。

## 脚本列表

### 1. 开发调试脚本

#### `run_node.sh` - Node.js 调试模式
```bash
./scripts/run_node.sh
```
- **用途**: 在 Node.js 环境下运行项目（用于 Windows 调试）
- **功能**: 
  - 自动检查并安装依赖
  - 启动 Node.js 调试模式
- **适用场景**: 需要在 Windows 上进行断点调试时使用

#### `watch_ts.sh` - 监听 TS 文件自动编译
```bash
./scripts/watch_ts.sh
```
- **用途**: 监听 TypeScript 文件变化并自动编译到 Lua
- **功能**: 
  - 文件修改后自动触发 TSTL 编译
  - 实时查看编译结果
- **适用场景**: 开发过程中需要频繁修改代码时使用

---

### 2. Skynet 服务器脚本

#### `run_skynet.sh` - 一键启动 Skynet
```bash
./scripts/run_skynet.sh
```
- **用途**: 自动编译 TS 并启动 Skynet 服务器
- **功能**: 
  1. 执行 TS → Lua 翻译
  2. 启动 Skynet 服务器
- **适用场景**: 日常开发中启动服务器的标准方式

#### `stop_skynet.sh` - 停止 Skynet
```bash
./scripts/stop_skynet.sh
```
- **用途**: 优雅停止 Skynet 服务器
- **功能**: 
  - 查找 Skynet 进程
  - 优雅停止（SIGTERM）
  - 如有残留则强制停止（SIGKILL）
- **适用场景**: 需要停止服务器时使用

#### `build_skynet_engine.sh` - 编译 Skynet 引擎
```bash
./scripts/build_skynet_engine.sh
```
- **用途**: 编译 Skynet C 代码本身
- **功能**: 
  - 检测操作系统（Linux/Windows MinGW）
  - 执行对应的 make 命令
- **适用场景**: 
  - 首次部署时编译 Skynet 引擎
  - 更新 Skynet 源码后重新编译
  - WSL 环境下需要重新编译时

---

### 3. 编译脚本

#### `ts2lua.sh` - TS 到 Lua 编译
```bash
./scripts/ts2lua.sh
```
- **用途**: 将 TypeScript 代码翻译成 Lua 代码
- **功能**: 
  - 执行 TSTL 编译
  - 输出编译结果到 `dist/lua/`
- **适用场景**: 只需要编译不需要启动服务器时使用

---

### 4. 清理脚本

#### `clean_all.sh` - 清理所有生成文件
```bash
./scripts/clean_all.sh
```
- **用途**: 清理所有编译产物和生成文件
- **功能**: 
  - 删除 `dist/` 目录（TS 编译产物）
  - 清理 Skynet 编译产物（.so 文件）
  - 执行 Skynet make clean
- **适用场景**: 
  - 准备提交代码前清理
  - 遇到编译缓存问题时
  - 重新开始完整编译前

---

## 典型工作流

### 开发流程（Windows + WSL）

1. **初次环境搭建**
   ```bash
   # 1. 编译 Skynet 引擎（仅需一次）
   ./scripts/build_skynet_engine.sh
   
   # 2. 安装 Node.js 依赖（仅需一次）
   npm install
   ```

2. **日常开发**
   ```bash
   # 方式一：在 Node.js 下调试（Windows 环境，可断点）
   ./scripts/run_node.sh
   
   # 方式二：直接在 Skynet 下运行（真实环境）
   ./scripts/run_skynet.sh
   ```

3. **持续开发模式**
   ```bash
   # 终端 1: 监听 TS 文件自动编译
   ./scripts/watch_ts.sh
   
   # 终端 2: 启动 Skynet（不需要 ts2lua，直接启动）
   cd skynet
   ./skynet config.tslua
   ```

4. **停止服务**
   ```bash
   ./scripts/stop_skynet.sh
   ```

5. **清理重建**
   ```bash
   # 清理所有产物
   ./scripts/clean_all.sh
   
   # 重新编译并启动
   ./scripts/run_skynet.sh
   ```

---

## 注意事项

1. **所有脚本都应该在项目根目录调用**，脚本内部会自动处理路径
2. **首次使用前**需要执行 `build_skynet_engine.sh` 编译 Skynet C 代码
3. **WSL 环境**下建议使用 `run_skynet.sh` 一键启动
4. **开发调试**时推荐使用 `run_node.sh` 在 Windows 上进行断点调试
5. **持续开发**时可以使用 `watch_ts.sh` 实现自动编译

---

## 脚本设计理念

- **职责单一**: 每个脚本只做一件事，易于理解和维护
- **路径无关**: 所有脚本自动处理工作目录，可从任何位置调用
- **错误处理**: 编译失败时自动中止，避免启动错误的代码
- **清晰输出**: 使用分隔线和提示信息，便于追踪执行过程
