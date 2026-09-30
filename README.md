# MC Plan Foundation

MC Plan（MC 计划）的治理与架构真相仓库。这里保存跨项目长期有效的愿景、边界、标准、决策、项目状态、模板和 Codex 协作 Skill，不包含业务实现代码。

## 仓库地图

- `docs/`：项目宪法、系统架构、产品策略、数据流、隐私和路线图。
- `standards/`：所有仓库共同遵守的工程标准。
- `decisions/`：不可覆盖的架构决策记录（ADR）；被替代时新增 ADR。
- `memory/`：跨仓当前状态、活动计划、交接、风险和待决事项。
- `templates/`：新仓库、计划、ADR、交接和发布检查模板。
- `.codex/skills/mc-plan-development/`：MC Plan 多仓开发协作 Skill 的权威版本。

## 真相层级

1. 公共接口与数据契约以 `mc-plan-contracts` 的已发布版本为准。
2. 跨项目原则、边界和决策以本仓库文档与 ADR 为准。
3. 单仓实现细节、验收命令和局部状态以对应仓库为准。
4. 具体任务、讨论和审查以 GitHub Issue/PR 为准，不复制到多份 Markdown。

## 当前阶段

Foundation v1.0 文档基线已完成并保存在本地 Git；尚未创建远程仓库，业务代码尚未开始。当前完成范围与后续缺口见 [F0 完整性审计](docs/f0-completeness-audit.md)，后续顺序见 [路线图](docs/roadmap.md)。

## 验证

在工作区根目录运行：

```powershell
pwsh -File .\mc-plan-foundation\scripts\validate-workspace.ps1
```

该命令检查六仓必需文件、状态页、本地 Markdown 链接、JSON 解析、Schema ID、本地契约引用和 Skill 基线。

## 许可

除另有注明外，本仓库文档采用 [CC BY 4.0](LICENSE) 许可。
