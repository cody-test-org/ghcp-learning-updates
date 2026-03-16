---
description: >
  Researches the latest GitHub Copilot announcements, features, and documentation updates.
  Compares findings against the current presentation and creates a PR with updates or
  a research issue summarizing gaps.

on:
  schedule: daily around 9:00
  workflow_dispatch:
    inputs:
      focus_area:
        description: "Optional focus area to prioritize research (e.g., 'coding agent', 'MCP', 'CLI hooks')"
        required: false
        type: string

permissions:
  contents: read
  issues: read
  pull-requests: read
  actions: read

tools:
  edit:
  bash: ["echo", "ls", "cat", "head", "tail", "grep", "wc", "sort", "uniq", "date", "git:*", "diff"]
  github:
    toolsets: [repos, issues, pull_requests]
  web-fetch:

safe-outputs:
  create-pull-request:
    title-prefix: "[docs-update] "
    labels: [documentation, automated, copilot-updates]
    draft: true
  create-issue:
    title-prefix: "[research] "
    labels: [research, copilot-updates]
    max: 1
    close-older-issues: true

network:
  firewall: true
  allowed:
    - defaults
    - github.blog
    - www.github.blog
    - devblogs.microsoft.com
    - learn.microsoft.com
    - docs.github.com
    - code.visualstudio.com
    - github.github.com
    - githubnext.com

engine: copilot

timeout-minutes: 30
---

# GitHub Copilot Documentation Research & Update Agent

## Purpose

Research the latest GitHub Copilot announcements, features, and documentation updates. Compare findings against the current presentation content and either create a PR with updates or create a research issue summarizing gaps.

## Step 1: Analyze Current Presentation

Read `hackathon.html` and extract the list of topics currently covered. Build an internal inventory of:

- Every section and slide topic
- Key features and capabilities mentioned
- Specific versions, dates, or release references
- Any areas that appear incomplete or outdated

The presentation currently covers these major sections:

| Section | Slides | Topics |
|---------|--------|--------|
| Intro | 1 | Feature matrix overview |
| Skills | 2–7 | Skills vs custom instructions, creating skills, how Copilot uses skills, custom instructions overview, prompt file techniques, custom agents |
| MCP | 9–11 | Core concepts (parts 1 & 2), generating custom instructions |
| Coding Agent | 13–16 | What is the coding agent, agent mode vs coding agent, custom agents for the coding agent, agent architecture |
| Agent Management | 18–21 | Single vs multiple sessions, sequential orchestration, parallel orchestration, workflows & handoff documents |
| CLI | 23–24 | Why GitHub Copilot CLI, adoption trends |
| CLI Customization | 26–31 | Hooks overview, hooks lifecycle, hooks use cases (parts 1 & 2), plugins overview, plugin structure |
| Thank You | 32 | Closing slide |

## Step 2: Research Latest Updates

Search for recent GitHub Copilot updates from these sources:

1. **GitHub Blog** (github.blog) — Look for posts about Copilot features, releases, and announcements
2. **GitHub Docs** (docs.github.com) — Check for updated documentation on Copilot CLI, coding agent, custom agents, skills, MCP
3. **Microsoft DevBlogs** (devblogs.microsoft.com) — Search for Visual Studio and Copilot announcements
4. **Microsoft Learn** (learn.microsoft.com) — Check for updated training content on Copilot
5. **VS Code Docs** (code.visualstudio.com) — Check for Copilot extension and agent mode updates
6. **GitHub Next** (githubnext.com) — Check for experimental features and research projects

### Focus areas to research

- New Copilot features or capabilities not in the presentation
- Updates to existing features (agent mode, coding agent, CLI, MCP, skills)
- New model availability (GPT-5, Claude Sonnet 4.5+, etc.)
- **Agentic Workflows (gh-aw)** — this is a major new capability not yet in the presentation
- Copilot Extensions and plugin ecosystem changes
- Enterprise and organization-level features
- Code review capabilities
- Security and compliance features
- Pricing or plan changes
- Integration updates (VS Code, JetBrains, CLI, GitHub.com)

If a `focus_area` input is provided via workflow_dispatch, prioritize researching that specific area: "${{ github.event.inputs.focus_area }}"

## Step 3: Gap Analysis

Compare research findings against the current presentation. Identify:

- **Missing topics** — Important capabilities not covered at all
- **Outdated content** — Slides with stale information
- **New sections needed** — Major new feature areas that deserve their own section
- **Enhancement opportunities** — Existing slides that could be enriched

Rank each finding by impact:
- 🔴 **High** — Major missing feature or significantly outdated content
- 🟡 **Medium** — Useful addition that would improve the presentation
- 🟢 **Low** — Nice-to-have or minor enhancement

## Step 4: Create Output

### Option A: Create a PR (if concrete updates found)

If you find specific, factual updates that can be added to the presentation:

1. Create a new branch named `docs-update/<date>-<topic>` (e.g., `docs-update/2025-01-15-agentic-workflows`)
2. Edit `hackathon.html` to add new slides or update existing ones following the existing HTML/CSS patterns
3. Follow the existing slide structure:
   - Section dividers use `<section class="slide" data-section="..." data-title="...">` with `<h1 class="section-title">`
   - Content slides use `<h2 class="slide-title">` with card layouts using `.card`, `.card-accent`, `.card-blue`, `.card-green`, `.card-orange`
   - Use the existing CSS classes and design patterns — do not add new styles
4. Update the navigation and slide count if new slides are added
5. Create a PR with:
   - A clear title describing what was added/updated
   - A description listing each change with source links
   - Labels: `documentation`, `automated`, `copilot-updates`

### Option B: Create a Research Issue (if updates need human review)

If updates require human judgment or are too complex for automated changes:

1. Create a well-structured issue with the title format: `Copilot Updates Research — <date>`
2. Organize findings by category:
   - 🆕 **New Features** — Capabilities not in the presentation
   - 🔄 **Updates** — Changes to existing features
   - ⚠️ **Deprecations** — Features being removed or replaced
   - 📋 **Action Items** — Specific suggested changes with slide references
3. Include source links for every finding
4. Prioritize findings by relevance to the audience
5. Suggest where in the presentation each finding should go (section name + after which slide)

### Decision Criteria

Choose **Option A** (PR) when:
- Changes are factual and well-sourced
- Updates fit cleanly into existing slide structure
- No subjective editorial decisions needed

Choose **Option B** (Issue) when:
- Multiple significant new sections would need to be added
- Content requires editorial judgment about scope or emphasis
- Research found conflicting or unconfirmed information
- Changes would significantly restructure the presentation

## Constraints

- Only include factual, verifiable information with source links
- Do not fabricate feature announcements or release dates
- Maintain the existing presentation style and formatting
- New slides should follow the exact same HTML structure as existing slides
- Focus on content that helps people learn about Copilot capabilities they may not be using
- Be specific — "Copilot now supports X" is better than "Copilot has improvements"
- Keep slide content concise and scannable — use bullet points and cards, not paragraphs
- Preserve all existing content unless it is demonstrably incorrect
