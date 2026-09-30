# API 与事件标准

## HTTP API

- 使用 HTTPS、JSON、OpenAPI 3.1 和 `/v1` 主版本路径。
- 资源 ID 是不透明字符串；客户端不得解析 ID 结构。
- 列表使用游标分页，响应包含 `items` 和可空 `next_cursor`，不承诺总数。
- 错误使用 `application/problem+json`，包含稳定 `type`、`title`、`status`、`code`、`trace_id`，字段错误可附 `errors`。
- POST 类重试安全操作接受 `Idempotency-Key`；服务保存请求指纹和结果，键与不同请求体复用时返回冲突。
- 时间使用 RFC 3339 UTC，哈希标明算法，媒体类型使用 IANA 标准值。

## 认证与授权

- OIDC access token 通过 issuer、audience、signature、expiry 和 scope 全部验证。
- 浏览器和公开客户端使用 Authorization Code + PKCE；服务间使用 Client Credentials。
- 每个操作在契约中声明所需 scope，业务服务继续验证资源所有权和状态。
- 禁止令牌出现在 URL、日志或错误消息中。

## 兼容性

- 增加可选字段和新 endpoint 通常是向后兼容；删除/重命名字段、收紧约束或改变语义属于破坏性变更。
- 破坏性变更必须发布新主版本、迁移指南、双写/双读或明确停机迁移方案。
- 公共契约先变更并通过审查，再实现服务和 SDK；实现 CI 必须验证与锁定契约版本一致。

## 事件

- 名称格式为 `<domain>.<action>.v<major>`，例如 `resource.published.v1`。
- 统一信封包含 event ID、type、occurred_at、producer、subject、correlation ID、schema version 和 data。
- 生产者使用事务发件箱；消费者按 event ID 幂等，允许重复和乱序，不假设 exactly-once。
