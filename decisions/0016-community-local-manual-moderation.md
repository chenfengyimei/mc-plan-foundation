# ADR-0016：Community 正式审核采用本地人工审核放行（Q-009 决议）

状态：Accepted
日期：2026-10-13

## 背景

Q-009（机器审核提供商与降级策略）自 [ADR-0014](0014-community-local-resource-engineering.md) 起保持未决：生产者实现中运行审核 disabled、fail-closed——未配置、超时或失败一律保持 `pending_moderation`，无静默放行。F2 资源闭环（`MCP-F2-COMMUNITY-001`，community `70e55a1` + 固定镜像 `mcp-f2-community-001-779803e`）与门户前置 preview 契约（`MCP-F2-CONTRACTS-003`，Community `0.1.0-alpha.3`）相继关闭后，审核方案成为 F2 发布闭环预发布前的最后一块所有者门槛。

项目所有者于 2026-10-12 决策（06 总控会话 ask_user 收集）：**正式审核 = 本地人工审核放行（方案 A），拒绝指定机器审核提供商**。无外部审核 API、无审核数据传出。

## 决策

- **形态**：审核由本地人工完成。不采购、不集成任何机器审核提供商；不存在审核数据出域。任何升级到机器/外部审核服务的路径须以新 ADR 重开本决策。
- **fail-closed 不变**：未获授权、未配置、超时或失败一律保持待审；任何调用方声明不能代替审核决定；决议前已存在的资源保持待审，不追认放行（ADR-0014 语义原样保留）。
- **审核员授权**（所有者 2026-10-13 D1 实答）：新增 userOAuth scope `moderation:review`，由身份 realm（Keycloak）仅授予指定审核员用户；Community 只验证令牌 scope，不复制身份真相，与既有 `resource:write`/`upload:write` 鉴权完全同型；撤销审核员资格 = realm 侧收回该 scope，零 Core 契约变化。
- **审核操作面**（所有者 2026-10-13 D2-D4 实答）：
  - 单决定端点 `POST /v1/resources/{resourceId}/versions/{versionId}/review`，请求体字段封闭 `{decision: approve|reject, reason?: string}`，必填 `Idempotency-Key`；
  - 仅 `pending_moderation` 候选可审；approve 复用既有放行语义（review_state=APPROVED + published_at + resources.state=published + current_version_id + `resource.published.v1` outbox）；reject → REJECTED 且已发布老版本保持可见；
  - 单人放行即可（任一在授权审核员），全部决定留审计痕；双人复核留作 F4 管理端强化项；
  - 本轮不新增待审队列端点，审核员经现有视图按 resource/version ID 直审，队列列表属后续 F4 管理端。
- **实施顺序**（契约先行）：本 ADR（审核语义落档）→ Contracts 审核面契约（预计 Community `0.1.0-alpha.4`，`moderation:review` scope + review 决定端点）→ Community 生产者本地人工审核 adapter（替换 UnavailableModeration 运行入口，同样 fail-closed）→ 真实故障验收（缺员/超时/失败保持待审）。
- **Q-009 就此关闭**（`memory/open-questions.md` 已按 Q-015 先例登记）；Q-010 的其余细分（最小权限目录、双人复核、申诉职责、审计威胁模型、F4 管理端）仍按原门槛保留，本 ADR 不代决。

## 后果

- 契约侧下一步可立即启动：community.yaml alpha.4 锁定审核面（错误语义沿用既有 400/401/403/404/409 目录，审核决定审计按生产者既有审计机制）。
- 生产者侧：审核员令牌经真实身份 realm 签发；`MODERATION_MODE` 的运行入口切换为本地人工模式，未配置审核员/无授权令牌时保持待审。
- 不引入任何外部依赖与数据传输面；备份、恢复与审计保留门槛（Q-005/Q-016）不受本 ADR 影响。

## 变更条件

升级到任何机器审核或外部审核服务、或需要双人复核/队列管理端时，重开本决策（新 ADR）并按 `memory/open-questions.md` 的 Q-010 门槛逐项决策；在此之前不得采购审核服务或写入自动放行默认值。
