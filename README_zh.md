<div align="center">

# TQ-Claw

[![GitHub 仓库](https://img.shields.io/badge/GitHub-仓库-black.svg?logo=github)](https://github.com/iwanglei1/TQ-Claw)
[![Python 版本](https://img.shields.io/badge/python-3.10%20~%20%3C3.14-blue.svg?logo=python&label=Python)](https://www.python.org/downloads/)
[![许可证](https://img.shields.io/badge/license-Apache%202.0-red.svg?logo=apache&label=%E8%AE%B8%E5%8F%AF%E8%AF%81)](LICENSE)

[[English](README.md)]

<p align="center">
  <img src="https://img.alicdn.com/imgextra/i2/O1CN014TIqyO1U5wDiSbFfA_!!6000000002467-2-tps-816-192.png" alt="TQ-Claw Logo" width="120">
</p>

<p align="center"><b>稳定优先，可靠至上</b></p>

</div>

## 关于 TQ-Claw

TQ-Claw 是一个个人 AI 助手，**优先追求稳定性而非新功能**。本项目修改自 [CoPaw](https://github.com/agentscope-ai/coagent-copaw)。

### 项目理念

与专注于快速功能开发的上游 CoPaw 项目不同，TQ-Claw 采取**保守策略**：

- **稳定优先** — 我们优先保证代码库的稳定性和可靠性，而非追逐最新特性
- **谨慎测试** — 所有变更在合并前都经过充分测试
- **专注修复** — 我们专注于修复 Bug 和提升可靠性
- **保守更新** — 新功能只有在上游证明稳定后才会被采纳

## 致谢

本项目是 [CoPaw](https://github.com/agentscope-ai/coagent-copaw) 的分支，CoPaw 是一个优秀的开源个人 AI 助手项目。

特别感谢：
- [AgentScope 团队](https://github.com/agentscope-ai) 创建了 CoPaw
- 所有 CoPaw 贡献者的出色工作
- 开源社区

## 功能特性

TQ-Claw 继承了 CoPaw 的所有优秀功能：

- **多频道支持** — 钉钉、飞书、QQ、Discord、iMessage、Telegram 等
- **本地与云端模型** — 支持云端大模型（DashScope、OpenAI 等）和本地模型（Ollama、llama.cpp、MLX）
- **技能系统** — 可扩展的自定义能力
- **记忆管理** — 长期记忆和上下文管理
- **桌面应用** — 跨平台桌面应用可用

## 快速开始

### pip 安装

```bash
pip install tqclaw
tqclaw init --defaults
tqclaw app
```

然后在浏览器打开 **http://127.0.0.1:8088/**。

### 使用 Docker

```bash
docker pull iwanglei1/tqclaw:latest
docker run -p 127.0.0.1:8088:8088 \
  -v tqclaw-data:/app/working \
  -v tqclaw-secrets:/app/working.secret \
  iwanglei1/tqclaw:latest
```

## 文档

完整文档请参考 [CoPaw 原版文档](https://copaw.agentscope.io/)。

## 参与贡献

我们欢迎符合稳定优先理念的贡献：
- Bug 修复和稳定性改进
- 文档改进
- 来自上游的经过充分测试的功能移植

## 许可证

TQ-Claw 采用 [Apache License 2.0](LICENSE) 开源协议，与原版 CoPaw 项目相同。

---

## 为什么选择 TQ-Claw？

TQ-Claw 代表了我们对提供**稳定可靠**的个人 AI 助手的承诺。虽然我们非常欣赏上游 CoPaw 项目中的创新，但我们理解有些用户更喜欢保守的方式。

如果你想要最新功能，请使用 [CoPaw](https://github.com/agentscope-ai/coagent-copaw)。

如果你想要一个稳定、经过充分测试的助手，**TQ-Claw 适合你**。
