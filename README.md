<div align="center">

# 🤖 GitHub Copilot — Learning & Reference Hub

**A curated collection of presentations, agents, and automation for mastering GitHub Copilot's agentic capabilities.**

[![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-Enabled-8b5cf6?logo=githubcopilot&logoColor=white)](https://github.com/features/copilot)
[![Agentic Workflows](https://img.shields.io/badge/Agentic_Workflows-Automated-58a6ff?logo=github-actions&logoColor=white)](https://github.com/features/copilot)
[![License: MIT](https://img.shields.io/badge/License-MIT-3fb950.svg)](LICENSE)
[![Slides](https://img.shields.io/badge/Slides-33-f0883e?logo=slides&logoColor=white)](#-presentation-topics)

| Environment | Link |
|-------------|------|
| 🟢 **Production** | [**View Live Presentation →**](https://ghcp-hackathon-prod-app.ambitiousbeach-052ceef7.eastus2.azurecontainerapps.io) |
| 🟡 **Dev (PR preview)** | [**View Dev Preview →**](https://ghcp-hackathon-dev-app.icybush-ed45e635.eastus2.azurecontainerapps.io) |

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
open site/hackathon.html        # macOS
start site/hackathon.html       # Windows
xdg-open site/hackathon.html    # Linux
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

## 🐳 Docker

### Build and Run Locally

```bash
# Build the image
docker build -t ghcp-hackathon .

# Run the container
docker run -p 8080:80 ghcp-hackathon

# Open http://localhost:8080
```

### Development with Docker Compose

```bash
# Start with live file mounting (no rebuild needed for content changes)
docker compose up

# Open http://localhost:8080
# Edit site/hackathon.html or site/agenda.json — refresh browser to see changes
```

---

## ☁️ Azure Deployment

The site deploys to **Azure Container Apps** (Consumption tier) with **Azure Container Registry** (Basic SKU) for ~$5-7/month.

> 🌐 **Deployed environments:**
>
> | Environment | Endpoint |
> |-------------|----------|
> | 🟢 Production | [ghcp-hackathon-prod-app](https://ghcp-hackathon-prod-app.ambitiousbeach-052ceef7.eastus2.azurecontainerapps.io) |
> | 🟡 Dev | [ghcp-hackathon-dev-app](https://ghcp-hackathon-dev-app.icybush-ed45e635.eastus2.azurecontainerapps.io) |

### Architecture

| Resource | SKU | ~Cost/mo |
|----------|-----|----------|
| Azure Container Registry | Basic | $5 |
| Azure Container Apps | Consumption | $0-2 |
| Log Analytics Workspace | Free tier | $0 |
| Application Insights | Free tier | $0 |
| **Total** | | **~$5-7** |

### Deploy with Azure Developer CLI (`azd up`)

The recommended way to deploy — handles infra provisioning, Docker build, image push, and container app update in one command:

```bash
# Prerequisites: Azure CLI, azd CLI, Docker

# Initialize the azd environment (first time only)
azd init -e ghcp-hackathon

# Deploy everything (infra + app)
azd up
```

Subsequent deploys (code changes only):
```bash
azd deploy
```

Infrastructure changes only:
```bash
azd provision
```

### Bootstrap Infrastructure (First Time)

```bash
# Deploy Azure resources (ACR, Container Apps, Log Analytics)
./infra/bootstrap.sh

# Or specify custom values
./infra/bootstrap.sh <resource-group> <location>
```

> After bootstrapping, all subsequent deployments are handled automatically by the CI/CD pipeline on PR merge.

---

## 🩺 Monitoring & Auto-Repair

The site includes automated health monitoring powered by a GitHub Agentic Workflow, an SRE-specialized Copilot agent, and Azure Application Insights.

> 📖 **[Full monitoring documentation →](docs/monitoring.md)** — Architecture diagrams, incident response flow, agent personas, setup guide, and operational runbook.

### Quick Overview

```
Site health check (every 15 min, standard curl)
  → Site healthy? → silent pass (7 sec)
  → Site down? → dispatch agentic repair workflow
    → ops-monitor agent investigates via Azure MCP
      → Auto-repairs if possible (revision restart)
        → Creates GitHub issue with full incident report
```

| Layer | Component | Details |
|-------|-----------|---------|
| **Detect** | Health Check workflow + App Insights | `curl` every 15 min + availability tests from 3 US locations |
| **Investigate** | ops-monitor agent + Azure MCP | Headless Copilot CLI queries container status & logs |
| **Repair** | Automated revision restart | Self-healing for common failures |
| **Report** | GitHub Issues | `[incident]` issues with diagnosis & recommendations |

```bash
# Manual health check
gh workflow run "Site Health Check"

# Direct repair agent trigger (for testing)
gh workflow run "Site Health Monitor & Auto-Repair Agent"
```

---

## 📁 Repository Structure

```
ghcp-learning-updates/
├── site/                                   # Static site content (served by nginx)
│   ├── hackathon.html                      # Interactive slide deck
│   └── agenda.json                         # Hackathon schedule config
├── infra/                                  # Azure infrastructure (Bicep)
│   ├── main.bicep                          # Main orchestration
│   ├── main.bicepparam                     # Default parameters
│   └── modules/
│       ├── acr.bicep                       # Container Registry
│       ├── app-insights.bicep              # Application Insights + availability test
│       ├── container-app.bicep             # Container Apps + environment
│       └── log-analytics.bicep             # Log Analytics workspace
├── docs/                                   # Extended documentation
│   ├── monitoring.md                       # Monitoring architecture & runbook
│   └── AZURE_OIDC_SETUP.md                # OIDC auth setup for CI/CD pipeline
├── .github/
│   ├── agents/                             # Custom Copilot agents
│   │   ├── agentic-workflows-builder.agent.md
│   │   └── ops-monitor.agent.md            # SRE/operations agent
│   ├── workflows/
│   │   ├── docker-ci-cd.yml                # CI/CD: build, test, push ACR, deploy dev/prod
│   │   ├── docs-research-updater.md        # Weekly docs research workflow
│   │   ├── site-health-check.yml           # Deterministic health check (every 15 min)
│   │   └── site-health-monitor.md          # Agentic repair agent (dispatched on failure)
│   ├── copilot-instructions.md             # Repo-wide Copilot instructions
│   ├── instructions/                       # Path-specific instructions
│   ├── prompts/                            # Reusable prompt templates
│   └── plugins.json                        # Plugin references
├── Dockerfile                              # nginx:alpine container
├── nginx.conf                              # Custom nginx configuration
├── docker-compose.yml                      # Local dev with live reload
├── azure.yaml                              # Azure Developer CLI (azd) project config
├── infra/bootstrap.sh                      # One-time infrastructure setup
├── AGENTS.md                               # Copilot agent instructions
└── README.md                               # This file
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
| [Azure Developer CLI (`azd`)](https://learn.microsoft.com/azure/developer/azure-developer-cli/) | `azd up` deployment |
| [Docker](https://www.docker.com/) | Container builds |
| [Azure CLI](https://learn.microsoft.com/cli/azure/) | Azure resource management |

---

## 🤝 Contributing

Contributions to keep this resource current are welcome!

### Adding or Updating Slides

1. Open `site/hackathon.html` in a text editor
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
