# async_json

异步读取课程统一数据集的本地副本（`data/books.json`），解析为 `Book` 模型并汇总输出。

## 功能

- 异步读取项目根目录的 `data/books.json`（字段：`id`、`title`、`category`、`borrowCount`）；
- 解析为 `Book` 模型，输出：图书总数、各类目数量（Map 统计）、借阅量 Top3；
- `toJson` 反向序列化并做 roundtrip 一致性验证（Book -> JSON -> Book）。
- `bin/async_json.dart` 中同时给出「嵌套回调版」与「顺序 await 版」的对照。

## 异常兜底（均可读提示，不抛崩溃堆栈）

- 文件缺失：`数据文件缺失，请检查data/books.json`
- 字段缺失：提示缺少了哪些字段
- 类型错误：提示字段类型与模型不符

## AI 使用说明

本项目中的 AI 仅用于辅助我理解概念（如 `async/await`、`Future`、空安全与异常处理）
并提供学习参考，不用于代替本人完成学习任务；所有代码均经本人理解与运行验证。
