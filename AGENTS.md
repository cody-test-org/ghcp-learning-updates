# Repository Agent Instructions

## About This Repository

This is a **learning and reference repository** for GitHub Copilot agentic workflows. It contains presentation materials and guidance covering the full spectrum of Copilot extensibility:

- **Skills & Custom Instructions** — how to create and use Copilot skills, prompt files, and custom instructions
- **Custom Agents** — building specialized agents with `.agent.md` files
- **Model Context Protocol (MCP)** — core concepts, server configuration, and tool integration
- **Coding Agent** — GitHub's autonomous coding agent, architecture, and custom agent support
- **Agent Orchestration** — single/multi-session patterns, sequential and parallel orchestration, handoff documents
- **GitHub Copilot CLI** — terminal-based agent mode, hooks, and customization

### Key Files

| File | Description |
|---|---|
| `hackathon.html` | Interactive slide deck covering all agentic workflow topics |
| `README.md` | Repository readme |
| `AGENTS.md` | This file — agent instructions for Copilot when working in this repo |

## Available Custom Agents

- **agentic-workflows-builder** — Expert agent for building GitHub Copilot agentic workflows. Installed at user profile level (`~/.copilot/agents/agentic-workflows-builder.agent.md`). Invoke with the `/agent` command or reference by name in prompts.

### How to Use the Agent

```
# In GitHub Copilot CLI or VS Code chat:
/agent agentic-workflows-builder

# Or mention in a prompt:
"Use the agentic-workflows-builder agent to scaffold a new custom agent"
```

The agent can help with:
- Creating custom agents (`.agent.md` files)
- Writing prompt files (`.prompt.md`)
- Configuring MCP servers
- Setting up agent orchestration patterns
- Building skills and custom instructions

## Quick Reference: Building Agentic Workflows

### Custom Agent (`.agent.md`)

```markdown
# Place in: .github/agents/ (repo) or ~/.copilot/agents/ (user)

---
description: "One-line description shown in agent picker"
tools: ["githubRepo", "codeSearch"]       # Optional tool access
---

# Agent Name
You are an expert in [domain]. Your role is to...

## Instructions
- Step-by-step guidance for the agent
- Include constraints and quality criteria
```

### Prompt File (`.prompt.md`)

```markdown
# Place in: .github/prompts/ (repo) or ~/.copilot/prompts/ (user)

---
description: "Reusable prompt template"
mode: "agent"                              # agent | edit | ask
tools: ["githubRepo"]                      # Optional
---

Your prompt instructions here...
```

### Custom Instructions (`.github/copilot-instructions.md`)

```markdown
# Always loaded as context for Copilot in this repository.
# Use for coding standards, conventions, and project-specific rules.

- Use TypeScript with strict mode
- Follow the repository's naming conventions
- Write tests for all new functionality
```

### MCP Server Configuration

```json
// .vscode/mcp.json (repo-level) or ~/.copilot/mcp-config.json (user-level)
{
  "servers": {
    "my-server": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@my-org/mcp-server"]
    }
  }
}
```

### Agent Orchestration Patterns

| Pattern | When to Use |
|---|---|
| **Single session** | Simple, focused tasks |
| **Sequential orchestration** | Multi-step workflows with dependencies |
| **Parallel orchestration** | Independent tasks that can run concurrently |
| **Handoff documents** | Pass context between agent sessions via markdown artifacts |

### File Placement Summary

| What | Repo Level | User Level |
|---|---|---|
| Custom Agents | `.github/agents/*.agent.md` | `~/.copilot/agents/*.agent.md` |
| Prompt Files | `.github/prompts/*.prompt.md` | `~/.copilot/prompts/*.prompt.md` |
| Custom Instructions | `.github/copilot-instructions.md` | — |
| MCP Config | `.vscode/mcp.json` | `~/.copilot/mcp-config.json` |
