<div align="center">
<h1>易记账</h1>
<img src="entry/src/main/resources/base/media/icon.png" width="128" />
</div>

## 项目介绍

Open-Bill 是一个运行于Harmony OS 3.1+操作系统上，使用ArkUI框架开发的一款开源账单记录软件。
采用木兰许可证签署许可。

部分图标来源： [iconFont](https://www.iconfont.cn/)

## 开发环境

- Windows 11 2H2 Build.22621.2134
- DevEco Studio 3.1 Release
- SDK API9 3.2.12.5 Release

## 测试环境

- DevEco Virtual Device phone-x86-api9 3.1.0.306
- Oneplus 6T - fajita - OpenHarmony v3.2.14.6

## 已实现功能

- 记账
- 年度账单汇总
- AI 记账（新增）：在新增账单页输入一句话，自动识别金额/收支/分类/日期并回填

## AI 记账配置（可选）

AI 解析支持“本地规则解析 + 可选 LLM 增强”。如果你有自己的 `apikey` 和 `baseurl`（OpenAI 兼容 `chat/completions` 接口），可在以下文件中本地配置（不要提交真实密钥）：

- entry/src/main/ets/ai/AiBillingConfig.ts

示例：

- `baseUrl`: `https://api.openai.com/v1/chat/completions`
- `apiKey`: 你的 key
- `model`: 你的模型名

不用配置也能使用基础规则解析（中英文口语、简单日期/金额/收支）。

## 待开发功能

- 经济图表
- 账单详情

## 待优化功能

- 记账
    - 新增图片选项（拍照或从图库选择，随账单信息一同存入数据库）

## 软件截图

<img src="screenshots/Screenshot_2023-08-12T220024.png" width="128" />
<img src="screenshots/Screenshot_2023-08-12T215958.png" width="128" />
<img src="screenshots/Screenshot_2023-08-12T220035.png" width="128" />
<img src="screenshots/Screenshot_2023-08-12T171125.png" width="128" />

## 捐助

OpenBill是一个免费开源的项目，它将会有一些功能依赖于网络。它的开发和维护也需要投入大量精力，
如果您愿意赞助该项目或为我买一杯咖啡，那将会是对本项目最好的支持！

<img src="qrc-ali.jpg" width="128" />
<img src="qrc-wec.jpg" width="128" />