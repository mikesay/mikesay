---
title: VS Code + Continue + Ollama：全栈私有化 AI 辅助编程环境搭建指南
tags:
  - LLM
  - AI Coding Agent
toc: true
category_bar: true
categories:
  - AI辅助编程
date: 2026-04-09 21:53:00
---

在上一篇文章[《AI辅助编程：从“复制粘贴”到“氛围编程 (Vibe Coding)”》](https://www.mikesay.com/2026/04/08/vibe-coding/#more?t=1775724599864)中，我们探讨了AI如何改变开发者的心智模型。所谓的 **氛围编程 (Vibe Coding)**，本质上是让开发者从繁琐的语法细节中抽离，通过自然语言驱动 AI 完成复杂的逻辑构建。  
<!-- more -->

要实现这种“行云流水”的体验，一个成熟的 **AI Coding Agent** 必须具备以下核心能力：  

*   **LLM 语义理解**：深度理解代码意图，而非简单的字符补全。
*   **项目结构解读**：具备 RAG 能力，能扫描工程目录并建立上下文索引（@Codebase）。
*   **多文件编辑与生成**：能够自动创建文件并跨文件协同重构。
*   **内联编辑 (Inline Edit)**：支持代码行间的 Diff 对比与一键采纳。
*   **工具调用 (Tool Use)**：自动运行终端命令或读取系统文件。  

# 1. 商业战场的博弈：能力强大但“金钱”驱动

目前市场上的商业级 AI 编程工具主要由 SaaS 服务驱动，依托闭源大模型提供服务。  

| AI Coding Agent | License | CLI | VS Code | 其他 IDE | Ollama 支持 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **GitHub Copilot** | Commercial | ✅ | ✅ | JetBrains, Vim | ✅ |
| **Claude Code** | Commercial | ✅ | ✅ | Terminal | ✅ |
| **Cursor** | Commercial | ❌ | ✅ | Standalone | ✅ |
| **Droid** | Commercial | ✅ | ✅ | Slack | ✅ |

*   **优势**：依托云端顶级模型，不占用本地资源，响应逻辑强。
*   **缺点**：按月订阅收费；代码隐私存在风险；如果不是合理使用会造成额度浪费。  

# 2. 极客的选择：在 Apple Silicon Mac 上构建私有“大脑”

如果你手中有一台搭载 Apple 芯片（M1/M2/M3/M4 系列）的 Mac，其独特的统一内存架构（Unified Memory）将是运行中大型本地模型的“性能怪兽”。相比于按月付费的 SaaS 订阅，利用开源工具搭建本地工作台，不仅能榨干芯片的每一点算力，更能为你的代码资产提供物理级的数据隔离与安全防护。  

> 注：本文实测环境基于 MacBook Pro (M3 Chip)，但在其他 Apple Silicon 机型上同样具备极佳参考价值。  

## (1) 底层引擎的选择：为什么是 Ollama？
在本地运行 LLM 的工具链中，虽然有 LM Studio, vLLM 等选择，但 **Ollama** 依然是目前的最佳实践：  

*   **极致的本地化体验**：一行命令 `ollama run` 即可部署，完全不依赖外部网络。
*   **资源调度优化**：针对 Apple Silicon 的 GPU 进行了深度优化，加载 32B 模型也能实现极低延迟。
*   **标准的 API 接口**：提供兼容 OpenAI 格式的本地 HTTP 接口，让前端 Agent 插件（如 Continue）能够无缝对接。  

## (2) 交互层的对比：AI Coding Agent 哪家强？
在开源社区中，有几个备受瞩目的 AI Coding Agent 方案，我们对其进行了横向对比：  

| 开源 Agent 项目 | License | CLI | VS Code | 核心特色与推荐理由 |
| :--- | :--- | :--- | :--- | :--- |
| **OpenCode** | Open Source | ✅ | ✅ | 轻量极客风，对 NeoVim 用户极其友好。 |
| **Aider** | Open Source | ✅ | 🛠️ | **终端交互战神**。擅长复杂重构，支持 Git 自动提交变更。 |
| **Cline** | Open Source | ✅ | ✅ | **功能激进**。支持 Agent 模式直接执行终端指令和读写文件。 |
| **Continue** | **Open Source** | **✅** | **✅** | **全能选手**。插件生态成熟，上下文索引强大，能完美适配 Ollama。 |. 

**最终选择：Continue**  
经过权衡，我最终选择了 **Continue**。它的优势在于高度的自定义自由度，能够灵活配置不同的本地模型（Chat 用大模型，补全用小模型），且其 UI 交互与 **GitHub Copilot Chat** 高度一致，是目前手搓 AI 工作台的“满分”底座。  

### Continue 与 GitHub Copilot Chat 的详细比较
我们可以从以下三个维度来拆解它们的关系：  

1. **核心功能的“平替”**：在侧边栏对话 (`Cmd+L`)、内联编辑 (`Cmd+I`) 和代码自动补全上，Continue 完全复刻了 Copilot Chat 的核心体验。  
2. **Continue 的“降维打击”**：Copilot 只能用 OpenAI 的模型，而 Continue 让你实现“模型自由”——用 **Qwen 30B** 搞深度思考，用 **DeepSeek 16B** 做代码重写。同时，它的 `@` 体系（如 `@Codebase`）提供了 Copilot 难以触及的精准本地上下文。  
3. **与 Cursor/Cline 的区别**：不同于魔改整个 IDE 的 Cursor 或频繁执行系统指令的 Cline，Continue 保持了插件的纯粹性，不改变你的 IDE 习惯，仅作为超强增强包存在。  

# 3. 落地实践：手把手配置你的 AI 工作台
在 Mac M3 环境下，我们将使用 **Ollama** 作为后端，结合 **Qwen3 Coder 30B**（高性能大模型）与 **DeepSeek Coder V2 16B**。  

## (1) 安装 Ollama 与模型准备
首先，通过 Homebrew 安装 Ollama 并将其设为后台服务。  

```bash
# 安装 Ollama
brew install ollama

# 将 Ollama 设为 brew service 后台运行
brew services start ollama

# 下载并运行模型进行测试
ollama run qwen3-coder:30b

# 下载备用模型及向量索引模型
ollama pull deepseek-coder-v2:16b
ollama pull nomic-embed-text  
```
  
## (2) 安装 VS Code Continue 插件并配置
安装Continue插件后，修改配置文件 `~/.continue/config.yaml` 如下：  

```yaml
name: Local Ollama Config
version: 1.0.0
schema: v1

models:
  # Primary Model (Default for Chat and Edit)
  - name: Qwen3 Coder 30B
    provider: ollama
    model: qwen3-coder:30b
    contextLength: 32768
    roles:
      - chat
      - edit
    apiBase: http://localhost:11434

  # Secondary Model (Available in dropdown)
  - name: DeepSeek Coder V2 16B
    provider: ollama
    model: deepseek-coder-v2:16b
    contextLength: 32768
    roles:
      - chat
      - edit
    apiBase: http://localhost:11434

  # Dedicated Autocomplete Model
  - name: Qwen3 Autocomplete
    provider: ollama
    model: qwen3-coder:30b
    roles:
      - autocomplete

  # Embeddings Model (for @codebase)
  - name: Nomic Embed
    provider: ollama
    model: nomic-embed-text
    roles:
      - embed

context:
  - provider: currentFile 
  - provider: file        
  - provider: folder   
  - provider: open        
    params:
      onlyPinned: false
  - provider: code        
  - provider: terminal    
```

## (3) 开启 Vibe Coding：实战演练
配置完成后，你可以通过Continue的侧边栏或快捷键进入“氛围编程”模式。核心技巧在于利用 **@ 符号** 精确喂给 AI 上下文，以及让它跨越当前文件去创造新内容。  

**实战场景示例：使用 Vibe Coding 创建一个简单的命令行工具**
我们以创建一个简单的命令行工具为例，目标是让 AI 帮你完成从项目初始化到代码生成的全过程，无需你懂任何编程知识。
*   **第一步：初始化项目**  
    在 Continue 侧边栏（`Cmd + L`）中输入：  
    > 帮我创建一个空的命令行工具项目，使用python语言作为主编程语言，使用 `uv` 管理项目和依赖，项目名称叫 `my_cli`，这一步不要生成代码。  

    AI 会自动运行 `uv init my_cli_tool` 命令，并生成项目目录结构和 `pyproject.toml` 文件。  

*   **第二步：生成主程序文件**  
    在 Continue 侧边栏中输入：  
    > @my_cli 编辑 `main.py` 文件，修改功能为打印‘Hello, World!。自动将代码应用到main.py里。  

    AI 会自动编辑 `main.py` 文件，生成一个完整的命令行程序，你可以点击“应用”按钮保存更改。  

    你可能会遇到生成的代码有问题，所以在Continue侧边栏中继续输入：  
    > @my_cli 修复代码main.py中的问题  

    AI会自动修复有问题的代码。  

*   **第三步：内联编辑与修改**  
    打开 `main.py` 文件，选中main函数中的代码，按下 `Cmd + I` 唤起内联编辑框，输入：  
    > 修改这个程序，让它在运行时提示用户输入名字，并打印‘Hello, [名字]!’。  

    AI 会自动更新程序代码，增加用户输入功能，并生成相应逻辑。  

*   **第四步：生成测试文件**  
    在 Continue 侧边栏中输入：  
    > 请创建并编辑 `test_main.py` 文件，生成一个基本的测试文件，测试 `main` 函数是否能正常运行。  

    AI 会生成一个完整的测试文件，包含基本的测试用例，方便你验证程序功能。  

*   **第五步：一键调试**  
    在 Continue 侧边栏输入：
    > @Terminal 帮我调试代码，要求覆盖单元测试和主程序运行。  

    AI 将自动执行测试并运行代码，如遇报错，会循序渐进地引导你修复。  

*   **第六步：生成打包配置**  
    在 Continue 侧边栏输入：
    > @my_cli 为该 Python 项目生成打包配置并测试安装。  

    AI 会自动完成配置编写、安装测试，并根据结果进行迭代优化。  

*   **第七步：配置 CI/CD 流水线**  
    在 Continue 侧边栏输入：
    > @my_cli 基于 GitHub Actions 生成流水线，将 Python 包发布至内部 Artifactory。  

    AI 将分步引导你完成自动化部署环境的搭建。  

# 总结
借助 Continue 与 Ollama，我们利用 Mac 本地算力构建了一个全封闭的 AI 开发环境。这不仅解决了云端 AI 潜在的隐私泄露风险，还通过本地化部署获得了零延迟的反馈体验。  
所谓的“氛围编程(Vibe Coding)”，核心在于开发者意图的无缝传递。只需简单的指令描述，AI 就能在你的项目范围内快速生成、调试代码，大幅缩短从构思到上线的工作流。  