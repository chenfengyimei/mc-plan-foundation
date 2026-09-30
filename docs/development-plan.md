# Foundation 开发计划

状态：Active

当前职责：MC Plan 治理、架构、组合状态、标准、ADR、模板和协作 Skill

## 固定顺序

1. 明确提案目标、所有权、成功标准和受影响仓库。
2. 检查宪法与现有 ADR；持久跨仓选择先新增 ADR。
3. 更新架构、标准、注册表、路线图或模板中的唯一真相。
4. 只有真实反复工作流才进入 Skill；确定性规则进入脚本。
5. 执行协调、链接、JSON、Skill、命名和跨仓一致性验证。

## 契约与辅助仓库

Foundation 不拥有产品接口。公共语义变化由 Foundation/ADR 先决定，再以 Contracts 为主仓库建立独立工作流。Foundation 治理任务通常没有辅助仓库；读取其他仓库不产生锁。

## 验收命令

```powershell
pwsh -File .\mc-plan-foundation\scripts\validate-workspace.ps1
pwsh -File .\mc-plan-foundation\scripts\test-coordination.ps1
```

Skill 变更还必须运行官方 `quick_validate.py`、安装/版本漂移测试和行为用例静态检查。

## 完成条件

- 长期决策、组合状态、接口和单仓状态分别写入正确真相源。
- 机器记录可解析，活动锁无冲突，链接和仓库地图一致。
- 没有业务源码、秘密、生产值或重复 Skill 副本。

## 不得提前实现

Foundation 不初始化 Next.js、NestJS、Prisma、SDK 或生产部署，不替业务仓库决定未获得证据的字段和厂商。
