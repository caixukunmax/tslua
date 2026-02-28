# Protocol Buffers 生成代码目录

本目录包含由 `protocols/scripts/build_proto.sh` 脚本生成的 Protocol Buffers 代码。

## 文件说明

- `proto.ts` - 手写类型定义（需要手动维护）
- `proto.js` - 由 pbjs 自动生成（编译时生成）
- `proto.d.ts` - TypeScript 类型声明（编译时生成）

## 编译协议

```bash
# 从项目根目录运行
npm run build:proto

# 或从 server 目录运行
cd server && npm run build:proto
```

## 源文件位置

Protocol Buffers 源文件位于：`../../protocols/proto/`
