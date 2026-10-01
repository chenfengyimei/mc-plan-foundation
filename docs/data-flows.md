# 关键数据流

## 注册与首次登录

1. 用户在 Keycloak 完成邮箱验证和登录。
2. 客户端获得 OIDC authorization code，并通过 PKCE 换取令牌。
3. 首次访问 Core 时，Core 用 `(issuer, subject)` 幂等创建内部用户映射。
4. Core 先验证 issuer allowlist、audience、签名、有效期和已验证邮箱声明，再在唯一约束保护的事务中创建映射、最小资料、审计与 outbox。
5. 注册奖励只有在 Q-003 的规则生效后才由独立幂等账本流程发放，不能与身份映射失败形成半完成状态。
6. 业务服务只使用 Core 用户 ID，不把邮箱当作跨服务主键。

并发首次登录以 `(issuer, subject)` 唯一约束和请求指纹收敛到同一结果；同一外部身份不得产生两个 MC Plan 用户。停用时 Keycloak 阻止新认证，Core 同时拒绝非活动业务状态。重绑、恢复与身份提供者替换按 ADR-0008 执行，不允许按邮箱自动合并。

## 官方皮肤创作与发布

1. Skin 校验用户、年龄声明状态和账号验证状态。
2. Skin 向 Core 请求消费当日免费创作会话；免费额度不足时使用积分。
3. Skin 创建会话和生成任务，通过提供商适配器请求候选。
4. 候选写入隔离临时存储，仅供预览，不可作为公开资源下载。
5. 用户确认成品后，Skin 验证 PNG、64×64 尺寸、Steve/Alex 布局、透明层和内容安全。
6. Skin 获取 Community 上传会话，使用预签名 URL 上传最终文件。
7. Community 再次校验文件，创建 Resource、ResourceVersion、ResourceFile 和 LicenseSnapshot。
8. 机器审核通过后状态转为 `published`，并产生 `resource.published.v1` 事件。
9. 任一步骤失败都不得留下已扣费但不可追踪的状态；补偿或人工处理必须有审计记录。

## 自部署发布

1. Standalone Skin 的本地生成与下载不需要 MC Plan。
2. 用户选择发布时，自部署应用发起官方 OIDC PKCE 授权。
3. 用户确认 `profile:read resource:write upload:write` 等最小 scope。
4. 应用使用用户授权调用 Community API；不得内置平台管理员密钥。

## 删除与保留

1. 作者删除已发布作品后，Community 立即使其不可见并撤销新下载链接。
2. 二进制文件进入七天清理队列；备份中的副本在三十天内自然淘汰。
3. 最小化审核记录默认保留一百八十天，正式上线前接受法律复核。
4. Skin 对话三十天删除，临时候选和失败文件二十四小时删除；用户主动删除可提前触发。
