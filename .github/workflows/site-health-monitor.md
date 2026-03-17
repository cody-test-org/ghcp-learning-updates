---
description: >
  Monitors the GitHub Copilot Hackathon site health every 15 minutes. Checks HTTP availability,
  diagnoses issues using Azure MCP, attempts auto-repair via revision restart, and creates
  GitHub issues for incident tracking.

on:
  schedule: every 15 minutes
  workflow_dispatch:
    inputs:
      site_url:
        description: "Override production site URL to check (host must remain ghcp-hackathon-app.bravegrass-130ae164.eastus2.azurecontainerapps.io)"
        # NOTE: The workflow firewall only allows the production host. Overrides may change path/query only.
        required: false
        type: string

imports:
  - .github/agents/ops-monitor.agent.md

permissions:
  contents: read
  issues: read
  actions: read

tools:
  web-fetch:
  bash: ["echo", "curl", "date", "jq"]
  github:
    toolsets: [repos, issues]

mcp-servers:
  azure:
    command: "npx"
    args: ["-y", "@azure/mcp@latest", "server", "start"]
    allowed: ["*"]

safe-outputs:
  create-issue:
    title-prefix: "[incident] "
    labels: [incident, automated, site-health]
    max: 1
    close-older-issues: true
  add-comment:
    max: 3
    target: "*"

network:
  firewall: true
  allowed:
    - defaults
    - node
    - "ghcp-hackathon-app.bravegrass-130ae164.eastus2.azurecontainerapps.io"
    - "management.azure.com"
    - "login.microsoftonline.com"

engine: copilot

timeout-minutes: 10

labels: [monitoring, automation]
---

# Site Health Monitor & Auto-Repair Agent

## Purpose

Monitor the GitHub Copilot Hackathon site for availability and performance issues. When problems are detected, automatically investigate root causes using Azure infrastructure tools, attempt self-healing, and report findings.

## Site Details

- **Production URL:** https://ghcp-hackathon-app.bravegrass-130ae164.eastus2.azurecontainerapps.io
- **Resource Group:** rg-ghcp-hackathon
- **Container App:** ghcp-hackathon-app
- **Container App Environment:** ghcp-hackathon-app-env
- **ACR:** ghcphackathonacr

If a `site_url` input is provided via workflow_dispatch, use that URL instead: "${{ github.event.inputs.site_url }}"

## Step 1: Health Check

Perform these checks against the production URL:

1. **HTTP availability** — Fetch the site URL. Expect HTTP 200 status.
2. **Content verification** — Verify the response contains expected content (e.g., "GitHub Copilot" in the HTML body).
3. **Agenda endpoint** — Fetch `/agenda.json` and verify it returns valid JSON with a `days` array.
4. **Response time** — Note if the response takes longer than 5 seconds (cold start is expected on first request after scale-to-zero, but subsequent requests should be fast).

If ALL checks pass, log a brief "all healthy" status and exit — do NOT create an issue for healthy checks.

## Step 2: Investigate (only if health check fails)

If any check fails, use the Azure MCP server to investigate:

1. **Container App status** — Query the container app provisioning state and running state
2. **Revision status** — Check if the active revision is healthy, provisioned, and running
3. **Recent logs** — Pull container logs to look for errors (nginx errors, crash loops, OOM kills)
4. **Container App Environment health** — Verify the environment is operational
5. **ACR image status** — Verify the latest image exists and is accessible
6. **Resource group health** — Check if any resources are in a failed state

Document all findings with specific details — error messages, timestamps, states.

## Step 3: Auto-Repair (only if issue found)

Based on the investigation, attempt these repairs in order:

1. **If revision is unhealthy or stopped** — Attempt to restart the active revision using Azure MCP or CLI
2. **If container is crash-looping** — Note the error but do NOT attempt image rebuild (flag for human review)
3. **If environment is unhealthy** — Flag for human review (do not attempt environment-level changes)
4. **If ACR image is missing** — Flag for human review

After any repair attempt, wait 30 seconds and re-run the health check to verify the fix worked.

## Step 4: Report

### If site is DOWN and could NOT be auto-repaired:
Create an issue with:
- **Title:** `Site Down — <brief description of failure>`
- **Body:**
  - 🔴 **Status:** DOWN
  - **Failure type:** (HTTP error, timeout, content mismatch, container crash, etc.)
  - **Investigation findings:** (all details from Step 2)
  - **Repair attempts:** (what was tried, what happened)
  - **Recommended action:** (what a human should do)
  - **Timestamp:** when the issue was detected

### If site was DOWN but auto-repair SUCCEEDED:
Create an issue with:
- **Title:** `Site Recovered — <what was fixed>`
- **Body:**
  - 🟡 **Status:** RECOVERED (auto-repaired)
  - **Original failure:** (what went wrong)
  - **Repair action:** (what fixed it)
  - **Current status:** (health check results after repair)
  - **Root cause analysis:** (best guess at why it failed)

### If site is HEALTHY:
Do NOT create an issue. Simply log completion.

## Constraints

- Do NOT create issues for healthy checks — only for failures or recoveries
- Do NOT attempt destructive operations (delete resources, recreate environment)
- Do NOT modify the Docker image or Bicep infrastructure
- Keep investigation focused — don't explore unrelated Azure resources
- Rate limit: if an open incident issue already exists with the same failure type, add a comment instead of creating a new issue
- Always include timestamps in UTC
