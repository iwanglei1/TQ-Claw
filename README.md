<div align="center">

# TQ-Claw

[![GitHub Repo](https://img.shields.io/badge/GitHub-Repo-black.svg?logo=github)](https://github.com/iwanglei1/TQ-Claw)
[![Python Version](https://img.shields.io/badge/python-3.10%20~%20%3C3.14-blue.svg?logo=python&label=Python)](https://www.python.org/downloads/)
[![License](https://img.shields.io/badge/license-Apache%202.0-red.svg?logo=apache&label=License)](LICENSE)

[[中文 README](README_zh.md)]

<p align="center">
  <img src="https://img.alicdn.com/imgextra/i2/O1CN014TIqyO1U5wDiSbFfA_!!6000000002467-2-tps-816-192.png" alt="TQ-Claw Logo" width="120">
</p>

<p align="center"><b>Stability First. Reliability Always.</b></p>

</div>

## About TQ-Claw

TQ-Claw is a personal AI assistant that prioritizes **stability over new features**. This project is modified from [CoPaw](https://github.com/agentscope-ai/coagent-copaw).

### Project Philosophy

Unlike the upstream CoPaw project which focuses on rapid feature development, TQ-Claw takes a **conservative approach**:

- **Stability First** — We prioritize a stable, reliable codebase over chasing the latest features
- **Careful Testing** — All changes are thoroughly tested before being merged
- **Bug Fixes Focus** — We focus on fixing bugs and improving reliability
- **Conservative Updates** — New features are adopted only after they prove stable upstream

## Acknowledgments

This project is a fork of [CoPaw](https://github.com/agentscope-ai/coagent-copaw), an excellent open-source personal AI assistant project.

Special thanks to:
- The [AgentScope team](https://github.com/agentscope-ai) for creating CoPaw
- All CoPaw contributors for their excellent work
- The open-source community

## Features

TQ-Claw inherits all the great features from CoPaw:

- **Multi-Channel Support** — DingTalk, Feishu, QQ, Discord, iMessage, Telegram, and more
- **Local & Cloud Models** — Support for both cloud LLMs (DashScope, OpenAI, etc.) and local models (Ollama, llama.cpp, MLX)
- **Skills System** — Extensible skills for custom capabilities
- **Memory Management** — Long-term memory and context management
- **Desktop Application** — Cross-platform desktop app available

## Quick Start

### pip install

```bash
pip install tqclaw
tqclaw init --defaults
tqclaw app
```

Then open **http://127.0.0.1:8088/** in your browser.

### Using Docker

```bash
docker pull iwanglei1/tqclaw:latest
docker run -p 127.0.0.1:8088:8088 \
  -v tqclaw-data:/app/working \
  -v tqclaw-secrets:/app/working.secret \
  iwanglei1/tqclaw:latest
```

## Documentation

For full documentation, please refer to the [original CoPaw documentation](https://copaw.agentscope.io/).

## Contributing

We welcome contributions that align with our stability-first philosophy:
- Bug fixes and stability improvements
- Documentation improvements
- Well-tested feature backports from upstream

## License

TQ-Claw is released under the [Apache License 2.0](LICENSE), same as the original CoPaw project.

---

## Why TQ-Claw?

TQ-Claw represents our commitment to providing a **stable and reliable** personal AI assistant. While we deeply appreciate the innovation happening in the upstream CoPaw project, we understand that some users prefer a more conservative approach.

If you want the latest features, please use [CoPaw](https://github.com/agentscope-ai/coagent-copaw).

If you want a stable, well-tested assistant, **TQ-Claw is for you**.
