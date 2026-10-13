# ADR-0017：F2 官方 OAuth 接入的有界 Core 前置工作

状态：Accepted
日期：2026-10-13

## 背景与授权

所有者2026-10-13要求临时人工审核并继续全项目逐模块开发，优先Core与社区。ADR-0016的人工审核与alpha.3预览已经由MCP-F2-COMMUNITY-002实现、实测、关闭。当前Core Developer App/PAT使用同一六scope目录，Keycloak辅助scope仅subject/email/Core audience；官方登记客户端无法获准既有Community resource/upload scope和双audience。这是现有F2出口“自部署OAuth发布”的工程前置。

## 决策

全局主方向保持F2/Community，在可写辅助集合中允许Core，仅用于已锁Community scope的官方开发者应用接入前置。每工作流仍唯一主仓、至多两个可写辅助仓，按锁和依赖串行切片。Core可为该前置的主仓，Contracts先锁定公开委托目录/语义，随后Core生产者、SDK/真实消费者、Ops验收；不能合成同时写四仓的任务。

用户OAuth公开客户端继续S256/精确回调，Community仍逐请求从Core解析活动业务ID，不共享源码或数据库。实现须区分Developer App与PAT目录；PAT和服务专用权限限制保持，不能因增加Community接入让PAT获得审核、服务或profile:write权限。审核员moderation:review保持ADR-0016的realm指定用户授权，不进入普通开发者应用/PAT委托白名单。Community audience仅随获准相关业务scope接入，并验证收窄/撤销/核对与失败补偿。

本ADR只开放必要技术前置，不新增scope名、不代定权限/价格/法律值、不授权生产部署、付费生成或远端推送。每项公开变化须独立Contracts-first契约和真实权限/撤销/failure测试。

## 后果与变更条件

原Community主方向无需停止即可依次完成对象存储/恢复、官方OAuth与消费者；Core完成前置后继续只作为业务身份/权益/账本权威，不拥有Community作品。超出本范围的Core功能、完整F4管理员权限或新的凭证授权须依产品决策另开工作流；方向变化再以新ADR记录。
