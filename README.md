<div align="center">
<h1>风风记账</h1>
<img src="entry/src/main/resources/base/media/icon.png" width="128" />
</div>

## 项目介绍

风风记账 是一个运行于 Harmony OS 3.1+ 操作系统上，使用 ArkUI 框架开发的一款开源账单记录软件。
采用木兰许可证签署许可。

部分图标来源： [iconFont](https://www.iconfont.cn/)

## 开发环境

- Windows 11 2H2 Build.22621.2134
- DevEco Studio 6.1.1.268
- SDK API9 3.2.12.5 Release

## 测试环境

- DevEco Studio 6.1.1.268
- Pura 90 - OpenHarmony

## 已实现功能

- **记账**：支持支出/收入分类选择、自定义备注、日期选择
- **AI 记账**：在新增账单页输入一句话，自动识别金额/收支/分类/日期并回填（支持本地规则解析 + LLM 增强）
- **AI 图片识别**：从图库选择账单截图，AI 自动识别金额/收支/分类/日期/商户名称并回填
- **年度账单汇总**：查看年度收入、支出、结余概览，按月明细统计
- **经济图表**：月度收支趋势折线图、支出分类占比饼图、收入分类占比饼图、经济分析
- **编辑账单**：长按账单列表项进入编辑，修改金额/分类/备注/日期
- **删除账单**：长按账单列表项弹出确认删除对话框
- **数字键盘计算器**：记账时支持加、减、乘计算后填入金额
- **开源信息页面**：展示项目开源许可信息

## AI 记账配置（可选）

AI 解析支持"本地规则解析 + 可选 LLM 增强"。如果你有自己的 `apikey` 和 `baseurl`（OpenAI 兼容 `chat/completions` 接口），可在以下文件中本地配置（不要提交真实密钥）：

- entry/src/main/ets/ai/AiBillingConfig.ts

示例：

- `baseUrl`: `https://api.openai.com/v1/chat/completions`
- `apiKey`: 你的 key
- `model`: 你的模型名

不用配置也能使用基础规则解析（中英文口语、简单日期/金额/收支）。

## 待开发功能

- 暂无

## 待优化功能

- 记账
    - 新增拍照选项（直接拍照，从图库选择已支持）

## 软件截图
<img src="screenshots/20260509_154113.png" width="128" />


<img src="screenshots/20260509_160957.png" width="128" />
<img src="screenshots/20260509_161110.png" width="128" />
<img src="screenshots/20260509_161010.png" width="128" />


<img src="screenshots/20260509_160742.png" width="128" />
<img src="screenshots/20260509_160717.png" width="128" />

<img src="screenshots/20260509_162352.png" width="128" />


## 项目来源
https://gitee.com/ericple/oh-bill

## 版权声明

- Copyright © 2023 Ericple
- Copyright © 2025 兑泽含光 (2025124051@chd.edu.cn)

本项目基于 **木兰宽松许可证 (Mulan PSL v2)** 签署许可。

## 捐助

风风记账 是一个免费开源的项目，它将会有一些功能依赖于网络。它的开发和维护也需要投入大量精力，
如果您愿意赞助该项目或为我买一杯咖啡，那将会是对本项目最好的支持！

<img src="wechat.jpg" width="128" />
<img src="Alipay.jpg" width="128" />