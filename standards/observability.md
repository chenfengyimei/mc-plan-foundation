# 可观测性标准

## 日志

使用结构化 JSON 日志，至少包含 timestamp、level、service、environment、trace_id、event、result 和稳定错误码。用户 ID 只在确有排障目的时以内部 ID 记录；不得记录 access token、密码、完整邮箱、对象存储密钥或提示词正文。

## 指标

- 请求：吞吐、延迟、状态码、限流和依赖错误。
- 任务：排队时间、执行时间、重试、死信、提供商错误和单次用量。
- 业务：生成会话、有效成品率、发布成功率、审核结果、积分消费与退款。
- 存储：数据库连接、慢查询、Redis、对象存储错误、备份和清理积压。

业务指标不得把高基数用户或资源 ID 作为标签。

## 追踪与告警

使用 OpenTelemetry 传播 trace context。跨服务请求、队列任务和事件保留 correlation ID。告警必须对应用户影响或操作动作，提供 runbook，避免仅因单个瞬时指标通知。

## 健康与身份/Core 信号

- liveness 不探测数据库、Redis、Keycloak 或公网；readiness 只探测当前功能真正必需的依赖与迁移状态。
- Core 至少观测未知 issuer、签名/JWKS 失败、错误 audience、停用账号拒绝、首次映射冲突、PAT 失败/撤销、幂等冲突、余额不足、账本核对差异和 outbox 积压。
- 指标标签不得包含 user ID、subject、邮箱、PAT 前缀、幂等键或其他高基数/敏感值；排障关联使用受控日志中的内部引用与 trace ID。
- readiness、备份、恢复和迁移的告警必须指向可执行 runbook；没有真实恢复输出的“备份成功”指标不能满足验收。
