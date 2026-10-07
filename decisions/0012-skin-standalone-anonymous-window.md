# ADR-0012：Skin Standalone 匿名窗口访问语义（不可枚举标识 + 保留期）

状态：Accepted
日期：2026-10-07

## 背景

skin.yaml 自 0.1.0-draft 起声明全局 `userOAuth`，但 Skin Standalone 生产者的事实语义是匿名访问：会话/任务/候选/成品以不可猜测的 128-bit UUID 寻址，无凭据即可操作；本地预览路由未入库（契约实现差距已记录）。项目所有者于 2026-10-07 在 W10 决策包（方案 A/B/C）中裁决采用**方案 A：不可猜测 UUID + 匿名窗口语义**，并要求以 ADR 固化机器可校验规则后，由 Contracts 将 skin.yaml 从 0.1.0-draft 升为 0.1.0-alpha.1（补齐候选预览字节、会话详情+消息、成品下载、会话删除五个缺口）。

## 决策

Skin Standalone 的公共契约采用**匿名窗口**语义：

- **会话即凭据**：所有资源（会话、任务、候选、成品）以 128-bit 随机 UUID 寻址；标识符不可枚举、不可由客户端指定；不引入按会话签发的 Bearer/PASETO 凭据对象模型。
- **保留期即边界**：会话保留 30 天、候选与失败产物保留 24 小时，到期自动清理；匿名窗口的泄露后果由保留期与删除端点（会话级 DELETE，级联清理候选与产物）部分缓解。保留期数值与删除语义进入公共契约描述并作为机器可校验对象。
- **userOAuth 保留为 Official 模式说明**：skin.yaml 的 `userOAuth` security scheme 保留，供未来 Official 模式部署按操作启用；alpha 阶段所有操作默认匿名（顶层 `security: []`），Official 收紧属后续破坏性窗口，须新 ADR。
- **协议不变**：既有四操作（createConversation/createRender/finalizeSkin/getJob）与新增四操作（getConversation/getCandidatePreview/downloadSkin/deleteConversation）形状不变，寻址模式一致。

## 被拒的替代形态

- **会话 Bearer 凭据（方案 B）**：真实的访问控制对象模型，但引入六处调用形状变更、浏览器端凭据存储问题与新的公共错误码；在 Standalone 免费自部署场景下成本高于收益。未来付费会话/多端同步（W11 重入）出现时可作为升级路径重开。
- **匿名全局无窗口承诺（方案 C）**：契约与现状最一致，但放弃了把"不可枚举 + 保留期"写成机器可校验规则的机会，回归无门。

## 后果

- Contracts 的 skin.yaml 0.1.0-alpha.1 按本语义补齐五个缺口操作并如实声明匿名窗口与保留期；Skin 生产者按契约实现公共端点（替换本地预览路由的入库差距）。
- 无凭据窗口的泄露面由"不可枚举 + 保留期 + 删除"共同约束；任何把匿名面扩展到用户私有数据的提议都超出本 ADR，须新 ADR。
- `events:consume` 式的服务专用 scope 与本语义无交集；userOAuth 在 skin.yaml 中仍仅为 Official 模式的文档性保留。

## 变更条件

出现以下任一情况须重开本决策：付费会话或多端同步需求（方案 B 重入）、External/Official 模式启用（userOAuth 实际启用）、保留期产品决策变更、或匿名窗口出现真实滥用证据需要强制门禁。
