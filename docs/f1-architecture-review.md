# F1 架构评审结论

Tracking ID：`MCP-F1-FOUNDATION-003`

状态：通过

批准依据：MC Plan 项目所有者明确授权本工作流在不存在重大产品、法律、许可、隐私、预算或外部账户阻塞时记录人工架构评审通过。

## 十项结论与证据

1. **责任边界唯一。** Keycloak 拥有凭证、邮箱验证、会话和 OIDC；Core 拥有稳定业务用户、授权、权益、账本与审计；Contracts 拥有公共接口；Ops 拥有官方运行拓扑和恢复。证据：`docs/system-architecture.md`、ADR-0003、ADR-0004、`docs/deployment.md`。
2. **身份生命周期清楚。** `(issuer, subject)` 唯一映射、验证邮箱前置、双层停用、禁止按邮箱自动重绑、显式 IdP 迁移均已固定。证据：ADR-0008、`docs/identity-and-access.md`、`docs/data-flows.md`。
3. **模块与事务可实现。** 入站适配器依赖应用端口，领域不依赖框架；跨模块流程由显式应用编排器和 Core unit of work 协调，表仍由所属模块写入。证据：`docs/system-architecture.md`、`docs/f1-core-first-slice.md`、ADR-0002。
4. **令牌和权限边界满足最小权限。** 浏览器 PKCE、服务 Client Credentials、PAT 哈希/过期/撤销/审计分离，管理操作要求重新认证。证据：`docs/identity-and-access.md`、`standards/security.md`。
5. **账本与额度具有单一语义。** Core 是唯一写入者；请求指纹、唯一幂等键、账户/额度锁、单事务账本与 outbox、Asia/Shanghai 日界线和不累计规则明确。证据：`docs/credits-and-entitlements.md`、`standards/database.md`。
6. **契约所有权和顺序明确。** 当前 `0.1.0-draft` 已覆盖 Profile/Entitlement/Credit 骨架，Developer App/PAT/角色等仍明确为后续 F1 冻结事项。首个 Core 骨架切片不实现公共业务 API，因此评审未发现必须在该切片前修改的公共契约；任何新增 API、scope、错误或事件必须另开 Contracts 主工作流。证据：ADR-0004、`standards/api.md`、Contracts `docs/api-catalog.md` 与 `openapi/core.yaml`。
7. **数据与恢复责任明确。** Keycloak/Core 数据库、用户、迁移与备份验证分离；Redis 不是账本真相；outbox 与领域写入同事务；恢复后重放撤销/删除控制。证据：`standards/database.md`、`docs/deployment.md`、Ops `docs/backup-restore.md`。
8. **运行验收入口真实。** liveness/readiness、结构化日志、OpenTelemetry、指标、限流、秘密注入和恢复要求均以应用真实输入为前提，不提前生成 Compose/Nginx。证据：`docs/f1-core-first-slice.md`、`standards/observability.md`、Ops `docs/deployment.md`。
9. **第一切片可直接执行。** 配置验证、NestJS 进程、Prisma/PostgreSQL、私有健康探针、OIDC 验证端口、测试层级和回退方式已有明确边界。证据：`docs/f1-core-first-slice.md`、`standards/testing.md`。
10. **重大待决事项不阻塞骨架。** 奖励数值、生产域名/地域、邮件服务、PAT 最长期限、托管数据层、监控产品和正式 RPO/RTO 均有 Owner 与最迟决策点；首切片不选择这些值。证据：`memory/open-questions.md`、`memory/risks.md`。

## 契约判断

本评审没有修改 Contracts，也没有批准实现未冻结的 Developer App、PAT、角色、奖励或事件表面。`MCP-F1-CORE-001` 可在 `contract_impact: none` 的边界内建立基础工程与运行链路；首次实现 `/v1/me` 或其他公共业务能力前，必须确认 `0.1.0-draft` 是否需要锁定为预发布版本，若需要则顺序创建 Contracts 主工作流。

## 门槛结论

现有重大待决事项均不改变第一 Core 骨架切片的产品范围、法律、许可、隐私、预算或外部账户选择。完成 Foundation 校验并关闭本工作流后，F1 状态可改为 `active`，并顺序启动 `MCP-F1-CORE-001`。
