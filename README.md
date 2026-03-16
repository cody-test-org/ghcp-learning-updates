<div align="center">

# 🤖 GitHub Copilot — Learning & Reference Hub

**A curated collection of presentations, agents, and automation for mastering GitHub Copilot's agentic capabilities.**

[![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-Enabled-8b5cf6?logo=githubcopilot&logoColor=white)](https://github.com/features/copilot)
[![Agentic Workflows](https://img.shields.io/badge/Agentic_Workflows-Automated-58a6ff?logo=github-actions&logoColor=white)](https://github.com/features/copilot)
[![License: MIT](https://img.shields.io/badge/License-MIT-3fb950.svg)](LICENSE)
[![Slides](https://img.shields.io/badge/Slides-33-f0883e?logo=slides&logoColor=white)](#-presentation-topics)

</div>

---

## 📖 Overview

This repository is a **learning and reference resource** for teams adopting GitHub Copilot's extensibility features — from custom agents and MCP servers to the Copilot CLI and agentic workflows.

The centerpiece is an **interactive 33-slide presentation** covering the full spectrum of Copilot capabilities: skills, custom instructions, Model Context Protocol, the autonomous coding agent, orchestration patterns, and CLI customization. It's designed for internal training, workshops, and self-paced learning.

The repo also includes an **agentic workflow** that automatically researches the latest Copilot updates and proposes content changes via pull requests — keeping the materials current without manual effort.

---

## ⚡ Quick Start

**View the presentation** — no build step or server required:

```bash
# Clone the repo
git clone <repo-url> && cd ghcp-learning-updates

# Open the slide deck
open hackathon.html        # macOS
start hackathon.html       # Windows
xdg-open hackathon.html    # Linux
```

### ⌨️ Keyboard Navigation

| Key | Action |
|-----|--------|
| `←` / `→` | Navigate between slides |
| `Esc` | Toggle overview mode (see all slides) |
| `N` | Toggle speaker notes panel |
| Section pills | Click the category buttons in the bottom nav bar |

> **Tip:** Speaker notes are editable — press `N` to open the notes panel, then type directly. Notes are saved to your browser's local storage. Use the 💾 **Export HTML with Notes** button to save a copy with your notes baked in.

---

## 🎯 Presentation Topics

The deck is organized into **7 sections** across **33 slides**:

| # | Section | Slides | Topics Covered |
|---|---------|--------|---------------|
| 1 | **Intro** | 0 – 1 | Title, Feature Matrix overview |
| 2 | **Skills & Instructions** | 2 – 7 | Skills vs Instructions, creating skills, how Copilot uses skills, custom instructions, prompt files, custom agents |
| 3 | **Model Context Protocol** | 8 – 11 | MCP core concepts (resources, prompts, tools, sampling, roots, transports), generating custom instructions with MCP |
| 4 | **Coding Agent** | 12 – 16 | What the coding agent is, agent mode vs coding agent, custom agents for coding agent, agent architecture |
| 5 | **Agent Management** | 17 – 21 | Single vs multiple sessions, sequential orchestration, parallel orchestration, workflows & handoff documents |
| 6 | **GitHub Copilot CLI** | 22 – 24 | Why use the CLI, adoption stats |
| 7 | **Customizing CLI** | 25 – 32 | Hooks (overview, lifecycle, use cases), plugins (overview, structure), closing |

---

## 🔄 Agentic Workflow — Docs Research Updater

An automated GitHub Actions workflow researches the latest Copilot updates and creates PRs with proposed content changes.

### What It Does

- **Daily schedule** — Automatically runs on a cadence to check for new Copilot features and documentation changes
- **On-demand** — Can be triggered manually via `workflow_dispatch`
- **Research sources** — Scans official GitHub blogs, Copilot docs, changelogs, and release notes
- **PR creation** — Proposes updates as pull requests for human review

### Setup

1. **Install the `gh-aw` extension** (GitHub Agentic Workflows CLI):
   ```bash
   gh extension install github/gh-aw
   ```

2. **Compile the workflow:**
   ```bash
   gh aw compile .github/workflows/docs-research-updater.md
   ```

3. **Configure secrets** — Ensure required secrets (e.g., `GITHUB_TOKEN` with appropriate permissions) are set in your repository settings.

### Manual Trigger

```bash
gh workflow run docs-research-updater
```

---

## 🛠️ Custom Agent — `agentic-workflows-builder`

An expert agent for designing, building, and deploying GitHub Copilot agentic workflows. Installed at the **user profile level** so it's available across all repositories.

### Location

```
~/.copilot/agents/agentic-workflows-builder.agent.md
```

### Usage

```bash
# In GitHub Copilot CLI or VS Code chat:
/agent agentic-workflows-builder

# Or reference by name in any prompt:
"Use the agentic-workflows-builder agent to scaffold a new custom agent"
```

### Capabilities

- Creating custom agents (`.agent.md` files)
- Writing prompt files (`.prompt.md`)
- Configuring MCP servers
- Setting up agent orchestration patterns (sequential, parallel, handoff)
- Building skills and custom instructions

---

## 📁 Repository Structure

```
ghcp-learning-updates/
├── hackathon.html                             # Interactive slide deck
├── AGENTS.md                                  # Agent instructions for Copilot in this repo
├── README.md                                  # This file
└── .github/
    └── workflows/
        └── docs-research-updater.md           # Agentic workflow definition
```

---

## ✅ Prerequisites

| Requirement | Purpose |
|------------|---------|
| **GitHub Copilot subscription** | Required for agent features and CLI |
| **Modern web browser** | Viewing the presentation |
| **[GitHub CLI (`gh`)](https://cli.github.com/)** | Running agentic workflows |
| **[`gh-aw` extension](https://github.com/github/gh-aw)** | Compiling & running agentic workflows |
| **GitHub Copilot CLI** | Using the `agentic-workflows-builder` agent in terminal |

---

## 🤝 Contributing

Contributions to keep this resource current are welcome!

### Adding or Updating Slides

1. Open `hackathon.html` in a text editor
2. Each slide is a `<section>` element — add new slides following the existing pattern
3. Update the section navigation pills if adding a new section
4. Test in a browser to verify layout and transitions

### Updating the Agentic Workflow

1. Edit `.github/workflows/docs-research-updater.md`
2. Recompile with `gh aw compile .github/workflows/docs-research-updater.md`
3. Test with a manual `workflow_dispatch` run

### General Guidelines

- Keep slides concise — use bullet points and code snippets over long paragraphs
- Test keyboard navigation after changes
- Speaker notes are a great place for detailed talking points

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">

*Built with ❤️ for teams learning GitHub Copilot*

</div>
