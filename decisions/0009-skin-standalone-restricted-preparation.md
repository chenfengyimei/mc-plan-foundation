# ADR-0009：F1 期间以受限准备方向提前建设 Skin Standalone

状态：Accepted
日期：2026-10-01

## 背景

Skin 完整纵向链路属于 F3，其开始条件包括正式生成提供商基准 ADR（Q-001）、3D 预览库选择（Q-011）与 Skin API 字段冻结（Q-012）。项目所有者于 2026-10-01 评估后明确授权：不依赖 Core、Community、Keycloak 的 Standalone 工程骨架与最小纵向链路可以在 F1 期间并行准备，因为这些工作与上述待决事项无耦合——不需要选择正式厂商、不需要 3D 库、不需要冻结新的公共字段，且能缩短 F3 关键路径。本 ADR 将该授权固化为可审计的治理边界。

## 决策

`mc-plan-skin` 登记为 F1 中受限的 Standalone 准备方向（`memory/current/direction.json` 的 `restricted_preparation_projects`），`mc-plan-core` 保持为 F1 全局主要项目。允许范围：

- TypeScript/pnpm workspace 工程骨架（Next.js、NestJS、BullMQ worker、PostgreSQL/Prisma、Redis、S3 兼容对象存储抽象、Vitest、Playwright、ESLint、环境变量 Schema 验证、结构化日志、健康检查）。
- Standalone 最小纵向链路：对话 → 渲染任务 → 厂商无关 ProviderAdapter（含确定性开发/测试 Fake Provider，返回仓库内已验证的 Minecraft 皮肤 fixture）→ 隔离存储 → 64×64 PNG 校验 → 候选预览（可替换 2D 组件）→ 确认 → 最终校验 → Standalone 下载。
- 数据保留清理任务与安全默认值（对话 30 天、候选和失败文件 24 小时）。

限制（违反任一项即超出本授权）：

- 不绑定 OpenAI、腾讯、阿里、智谱或任何具体正式模型厂商（Q-001 未决）；Fake Provider 不得在生产模式意外启用，不得伪装成真实 AI 能力。
- 不选择或绑定 3D 预览库（Q-011 未决）；仅使用可测试的 2D 像素预览组件并保留替换接口。
- 不发明结构化创作意图字段（Q-012 未决）；不复制或私改公共契约类型。
- 不实现 Official 登录、Keycloak、每日免费额度、积分扣减/退款、Community 自动发布、OAuth 社区授权、正式内容审核供应商。
- 不建立生产域名、不提交生产密钥或真实云资源。
- 不宣布 F3 开始，不绕过 Core、Community 的 Official 集成门槛；F3 正式开始的全部既有条件保持不变。
- 公共接口若出现 `0.1.0-draft` 契约无法表达的缺口（如候选预览、最终下载、匿名安全模式），先在 Skin 工作流记录缺口，再顺序创建以 `mc-plan-contracts` 为唯一主仓库的工作流补全契约，之后回到新的 Skin 工作流实现；不得两边各自发明接口。

## 备选方案

- **完全等待 F3 再初始化工程**：推迟关键路径，而骨架与待决事项无耦合，等待没有工程收益；未采用。
- **在独立临时仓库先行开发**：违反仓库注册表与独立交付原则，最终仍需迁移进 `mc-plan-skin`，产生双份历史；未采用。
- **授权同时实现 Official 集成**：依赖尚不存在的 Core/Community 预发布契约，且会迫使提前回答 Q-013 等未决事项；未采用。

## 后果

F3 开始时已有验证过的工程底座与 Standalone 链路，正式厂商基准可立即在真实管线上执行。代价：F1 期间 Skin 写工作流必须携带 `direction_exception`（foundation-governance）并接受锁与范围校验；Standalone 契约缺口需要额外的顺序 Contracts 工作流；两模式测试矩阵必须防止 Official 配置退化为匿名生成。本决策不改变 F1 的退出标准，也不占用 F1 的方向主仓库。

## 变更条件

出现下列任一情况时重新评估本决策：实现中出现必须绑定正式厂商、必须实现 Official 集成或必须破坏 draft 契约兼容性的需求；骨架工作流反复与 Core 主方向产生锁冲突或治理成本超过收益；项目所有者撤销提前建设授权。
