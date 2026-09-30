# 系统架构

## 仓库与运行时边界

```text
Browser / Third-party client
        |
        | OIDC Authorization Code + PKCE
        v
Keycloak ---------> Core API
  |                  | profiles / roles / apps / credits / audit
  |                  |
  +---- tokens ------+-----------------------+
                     |                       |
                     v                       v
                Skin API/Worker ------> Community API/Worker
                     |                       |
                     v                       v
              AI provider adapter     S3-compatible storage
                                             |
                                             v
                                       Community Web
```

Nginx 只负责 TLS、域名路由、基础限流和请求尺寸保护，不承担业务授权。Keycloak 负责凭证和 OIDC；Core 负责 MC Plan 业务用户与全局权益；Community 负责公开资源与社区关系；Skin 负责创作会话和生成流程。

## 数据所有权

| 数据 | 权威系统 | 其他系统允许保存 |
|---|---|---|
| 密码、登录会话、OIDC 客户端凭证 | Keycloak | 令牌验证所需的公开密钥与短期缓存 |
| MC Plan 用户 ID、资料、角色、开发者应用 | Core | 不带敏感字段的用户引用或展示缓存 |
| 积分、每日额度、账本、审计 | Core | 幂等消费请求与结果引用 |
| 资源、版本、文件、许可、互动、审核 | Community | 资源 ID、发布结果和展示链接 |
| 对话、候选、生成任务、模型调用元数据 | Skin | Community 只接收最终成品及必要来源信息 |
| 二进制作品文件 | Community 配置的对象存储 | 临时候选由 Skin 的隔离前缀保存 |

## 通信规则

- 用户请求携带短期 OIDC access token；浏览器客户端使用 PKCE。
- 服务间任务使用独立 Client Credentials 和最小 scope。
- 需要代表用户发布时保留用户主体，不能只用无归属的平台主密钥。
- 命令与查询优先使用同步 HTTPS API；跨服务通知使用事务发件箱产生的版本化事件。
- 所有写入接口定义幂等行为；重试不能产生重复积分、版本或互动。
- 禁止跨库查询和跨仓源码依赖。

## 初始技术形态

Core、Community 和 Skin 均采用模块化单体，而不是提前拆微服务。模块边界、数据所有权和事件契约必须清楚，使高负载模块未来可以独立拆分而不改变外部语义。

## 可扩展路径

单机首发时可共享 PostgreSQL 集群和 Redis 主机，但使用不同数据库、用户、密钥空间和备份策略。增长后依次外置数据库与缓存、增加无状态应用节点、独立 worker，最后才评估容器编排平台。
