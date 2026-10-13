# ADR-0018：管理员后台授权模型与 F4 管理端有界先行

状态：Accepted
日期：2026-10-13

## 背景

项目所有者于 2026-10-13 派工：在既有开发之外完善管理员后台，方便管理员登录后台查看、查询或修改管理整个 MC 计划。当前方向仍为 F2/Community（目标 S3、对象版本、门户消费者等出口项未完），F4 管理端线（W16—W21）尚未开启。所有者同日四项 ask_user 实答：①第一阶段只读先行；②管理员授权 = realm 指定用户 + 新 userOAuth scope `admin:read`；③管理台 Web 放 mc-plan-core 仓内 `apps/admin`；④治理 = 有界例外（F2 保持 active）。

现有业务基础：业务角色 `ADMIN` 已在身份模型（[identity-and-access](../docs/identity-and-access.md)）与积分存储内部原语中存在——`adjustment`（人工调整，事务内校验 actor.role=ADMIN）与 `refund`（按原消费补偿、防超退）已实现但无公共 API 暴露；Community 人工审核面（[ADR-0016](0016-community-local-manual-moderation.md)）已交付。缺的是管理端公共契约、查询 producer、realm 管理员配置与管理台 UI。

## 决策

- **有界先行**：F2 保持 active、出口项不变；管理端第一切片按方向例外注册为首个 F4 线记录（预计 `MCP-F4-CORE-001`），不宣称 F2/F4 完成。
- **只读先行**：第一切片仅交付 `admin:read` 只读查询面（用户检索/详情、积分账本、权益记录、审计日志、outbox 投递状态）。所有改操作（人工积分调整/退款、PAT 撤销、开发者应用撤销、用户状态变更）后置为独立切片，逐项经所有者决策并补齐审计设计后才暴露。
- **管理员授权模型**：新增 userOAuth scope `admin:read`，由身份 realm（Keycloak）仅授予指定管理员用户，与 `moderation:review` 完全同型；Core 校验 = 令牌 scope `admin:read` + 业务角色 `ADMIN` + 用户状态 `ACTIVE` 三者同时满足；MFA 按 `docs/identity-and-access.md` 既有要求为 realm 侧职责；PAT 目录不含 `admin:read`（运行时 `UNKNOWN_SCOPE`，同 `profile:write` 先例）；服务令牌（client_credentials）不可调用管理端操作。
- **管理台归属**：管理台 Web 为 mc-plan-core 仓内 `apps/admin` 工作区包（PKCE 登录 + 查询页面，直调 REST API）；SDK 暴露 admin 操作需待 producer 证据后另开 Contracts 切片；F4 正式期可再评估独立仓库。
- **Q-010 门槛不变**：Community 待审队列、双人复核、申诉与社区管理员权限细分仍按 Q-010 在 F4 管理端实现前决策；本 ADR 只开 Core 域只读管理面，不代决。

## 后果

- 实施顺序（契约先行）：本 ADR → Contracts 锁定 Core `0.1.0-alpha.9` 只读管理操作 → Core producer → Ops realm 管理员配置与真实验收 → `apps/admin` 管理台。
- `memory/current/direction.json` 的 entry_gate 追加本 ADR 有界例外；F2 出口项不受影响、不宣称完成。
- 无价格、法律、审核政策变更；不新增外部依赖与数据传输面。

## 变更条件

需要管理改操作、待审队列端点、双人复核或管理台独立仓库时，重开本决策（新 ADR 或按 Q-010 门槛逐项决策）；在此之前不得暴露任何 admin 写操作端点。
