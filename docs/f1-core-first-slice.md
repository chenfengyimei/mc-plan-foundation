# F1 Core 第一可运行切片

状态：Approved for implementation after the F1 architecture gate closes

## 可观察结果

第一切片建立一个可独立构建和启动的 Core 进程：启动时验证配置和数据库迁移状态，暴露私有探针，输出结构化日志与 OpenTelemetry 入口，并通过可替换的 OIDC 验证端口验证受信任 issuer 的测试令牌。它不创建业务用户、不实现公共 Profile/PAT/积分接口，也不依赖 Community 或 Skin。

请求链路为：

```text
HTTP probe / OIDC boundary test
  -> NestJS adapter
  -> application port
  -> config / Prisma PostgreSQL / OIDC verifier adapter
  -> structured result + trace
```

这条链路证明工程结构、依赖方向、配置失败、数据库连接、迁移、认证边界、日志、追踪和测试基础真实可运行；下一切片才能在锁定的 Contracts 版本上实现 IdentityLink 与 `/v1/me`。

## 工程边界

- `platform/config`：启动时用显式 Schema 验证环境变量；未知危险默认值和缺少必需值都失败退出。
- `platform/database`：只连接 Core PostgreSQL；Prisma migration 由显式命令执行，应用多实例启动时不得自动迁移。
- `platform/health`：`/health/live` 只表示进程事件循环可用；`/health/ready` 检查配置、Core 数据库连接和迁移版本。Redis 在尚未承载必需任务前不得成为 readiness 的虚假依赖。
- `platform/observability`：结构化 JSON 日志、稳定事件名、trace ID 和 OpenTelemetry 初始化；不得输出 token、完整邮箱、连接串或秘密。
- `identity-link`：先定义 token claims 与 `IdentityProviderVerifier` 端口，测试适配器使用本地签名材料；生产 Keycloak issuer、audience、JWKS 与时钟偏差全部由配置注入。首切片不持久化用户。
- HTTP/CLI 等入站适配器只调用应用端口；基础设施适配器实现端口；领域模块不能导入 NestJS、Prisma 或其他仓库源码。

## 配置与运行输入

首切片只接受不含生产值的键名契约：运行环境、监听地址/端口、Core 数据库 URL、OIDC issuer/audience/JWKS 获取策略、日志级别和 OpenTelemetry exporter 开关。秘密通过运行时注入；仓库只提供 `.example` 文档值。真实镜像、端口、探针和迁移命令确定后，Ops 才能生成组合配置。

## 测试与验收

工程初始化时必须在 Core 的 `AGENTS.md` 与开发计划中写入真实存在的命令，并至少提供：

1. lint 与格式检查；
2. TypeScript typecheck；
3. 配置、依赖规则、OIDC claims 验证的单元测试；
4. 使用隔离 PostgreSQL 的 Prisma migration 与 readiness 集成测试；
5. 使用本地测试 issuer/JWKS 的过期 token、错误 audience、未知 issuer 和有效 token 边界测试；
6. 从进程启动到 liveness/readiness 的端到端测试；
7. 锁定 Contracts 文件的只读验证，证明首切片没有复制或漂移公共类型；
8. 依赖和秘密扫描的可执行入口。

不得用计划中的脚本名冒充通过。Keycloak 真实 realm 联调、IdentityLink 持久化和 `/v1/me` 属于后续切片，必须分别提供集成与契约证据。

## 迁移、发布与回退

- 首次迁移只建立真实拥有的数据结构；禁止空业务表占位。迁移提交与 Prisma Schema 同步，验证从空库和上一受支持版本升级。
- 应用回退只允许回到仍兼容当前数据库结构的版本。Schema 收缩采用 expand/migrate/contract；已写入的身份、账本和审计数据不得通过自动 down migration 丢弃。
- readiness 失败时不接流量；liveness 不检查外部网络，避免依赖抖动造成重启风暴。
- 本地/Test 可销毁重建；Staging/Production 必须备份并验证恢复。破坏性数据变化只做前向修复。
- 首切片没有消费者、特性开关或业务数据迁移；若实现中发现需要新增公共字段、scope、错误或事件，立即停止该部分并拆到 Contracts 主工作流。
