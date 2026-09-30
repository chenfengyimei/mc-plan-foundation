# 身份与访问控制

## 责任分工

Keycloak 保存凭证、执行邮箱验证、密码找回、多因素认证和 OIDC 协议。Core 不接收或保存密码，只维护业务用户、资料、角色、开发者应用、授权 scope、个人令牌元数据和审计。

Core 为每个外部身份建立唯一映射：

```text
IdentityLink(issuer, subject) -> McPlanUserId
```

这样可以在不修改业务外键的情况下新增第三方登录、合并身份或更换身份提供者。

## 客户端类型

- Web 与自部署公开客户端：Authorization Code + PKCE，不保存 client secret。
- 可信后端：Authorization Code 的服务端会话，密钥仅在服务端安全存储。
- 服务间调用：Client Credentials，每个工作负载独立客户端与 scope。
- 自动化脚本：可撤销、可过期、按 scope 限制的 Personal Access Token；数据库只保存哈希与标识前缀。

禁止 Implicit Flow、Resource Owner Password Flow、永不过期令牌和多个服务共享同一个客户端密钥。

## 初始角色与 scope

业务角色：`user`、`creator`、`developer`、`moderator`、`admin`。角色用于粗粒度能力，资源所有权和操作条件由业务服务继续判断。

初始 scope 命名：`profile:read`、`profile:write`、`credits:read`、`credits:consume`、`skin:write`、`resource:read`、`resource:write`、`upload:write`、`moderation:write`。新增 scope 属于公共契约变更。

## 安全默认值

- Access token 短期有效，refresh token 轮换并可撤销。
- 所有生产回调地址精确匹配 HTTPS，不允许通配生产域名。
- 管理员和审核员启用 MFA。
- 账号、客户端、scope、令牌和角色变化写入不可变审计日志。
- 邮箱只在必要服务中处理，不传播到 Community 或 Skin 展示模型。
