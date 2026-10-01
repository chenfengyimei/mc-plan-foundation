# 身份与访问控制

## 责任分工

Keycloak 保存凭证、执行邮箱验证、密码找回、多因素认证和 OIDC 协议。Core 不接收或保存密码，只维护业务用户、资料、角色、开发者应用、授权 scope、个人令牌元数据和审计。

Core 为每个外部身份建立唯一映射：

```text
IdentityLink(issuer, subject) -> McPlanUserId
```

这样可以在不修改业务外键的情况下新增第三方登录、合并身份或更换身份提供者。

`issuer` 必须来自显式 allowlist 并按 OIDC discovery 元数据规范化，`subject` 只按不透明字符串比较。首次映射要求 token 的 signature、issuer、audience、expiry 全部通过，并要求受信任 issuer 给出已验证邮箱声明；Core 不把邮箱保存为跨服务键，也不因邮箱相等自动合并账号。完整生命周期见 ADR-0008。

## 停用、重绑与迁移

- Keycloak 停用、会话撤销和签名密钥轮换负责认证层；Core 的 `active/suspended/closed/security_hold` 等业务状态负责业务入口。受保护请求必须同时满足有效 token 和允许的 Core 状态。
- 身份重绑或添加第二身份要求现有身份重新认证，或进入有人工核验、双人授权和审计的恢复流程。操作完成后撤销旧会话，旧映射不得被静默复用。
- 更换身份提供者使用 issuer 双信任窗口和显式映射迁移，保持 MC Plan 用户 ID 不变；未经验证的新 issuer 不得触发自动迁移。
- Core 只保存验证决策所需的最小快照和审计引用。邮箱变更、验证邮件、密码找回和 MFA 始终由 Keycloak 执行。

## 客户端类型

- Web 与自部署公开客户端：Authorization Code + PKCE，不保存 client secret。
- 可信后端：Authorization Code 的服务端会话，密钥仅在服务端安全存储。
- 服务间调用：Client Credentials，每个工作负载独立客户端与 scope。
- 自动化脚本：可撤销、可过期、按 scope 限制的 Personal Access Token；数据库只保存哈希与标识前缀。

禁止 Implicit Flow、Resource Owner Password Flow、永不过期令牌和多个服务共享同一个客户端密钥。

PAT 明文只在创建时显示一次；哈希必须使用适合高熵 token 的带密钥或抗离线比对方案，并记录 token ID、前缀、scope、创建者、到期、撤销和最后使用时间。PAT 不得拥有创建者当前不具备的 scope；高风险创建、扩权和撤销写入审计，泄露响应可以按 token、用户或开发者应用批量撤销。Q-007 决定默认最长期限前，不得硬编码永久或产品默认值。

## 初始角色与 scope

业务角色：`user`、`creator`、`developer`、`moderator`、`admin`。角色用于粗粒度能力，资源所有权和操作条件由业务服务继续判断。

初始 scope 命名：`profile:read`、`profile:write`、`credits:read`、`credits:consume`、`skin:write`、`resource:read`、`resource:write`、`upload:write`、`moderation:write`。新增 scope 属于公共契约变更。

## 安全默认值

- Access token 短期有效，refresh token 轮换并可撤销。
- 所有生产回调地址精确匹配 HTTPS，不允许通配生产域名。
- 管理员和审核员启用 MFA。
- 账号、客户端、scope、令牌和角色变化写入不可变审计日志。
- 邮箱只在必要服务中处理，不传播到 Community 或 Skin 展示模型。
