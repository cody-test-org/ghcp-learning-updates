---
description: >
  Investigates and auto-repairs the GitHub Copilot Hackathon site when health checks fail.
  Triggered by the site-health-check workflow when the site is detected as down.
  Uses Azure MCP to diagnose infrastructure issues and attempt self-healing.

on:
  workflow_dispatch:
    inputs:
      site_status:
        description: "HTTP status code from health check (e.g., 200, 503, 000 for timeout)"
        required: false
        type: string
      response_time:
        description: "Response time in seconds from health check"
        required: false
        type: string
      content_ok:
        description: "Whether the HTML content contained expected text (true/false)"
        required: false
        type: string
      agenda_ok:
        description: "Whether agenda.json returned valid JSON (true/false)"
        required: false
        type: string

permissions:
  contents: read
  issues: read
  actions: read

tools:
  bash: ["echo", "curl", "date", "jq"]
  github:
    toolsets: [repos, issues]

mcp-servers:
  azure:
    container: "mcr.microsoft.com/azure-sdk/azure-mcp"
    version: "latest"
    env:
      AZURE_TENANT_ID: "${{ secrets.AZURE_TENANT_ID }}"
      AZURE_CLIENT_ID: "${{ secrets.AZURE_CLIENT_ID }}"
      AZURE_CLIENT_SECRET: "${{ secrets.AZURE_CLIENT_SECRET }}"
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
    - "eastus2.azurecontainerapps.io"
    - "management.azure.com"
    - "login.microsoftonline.com"
    - "graph.microsoft.com"
    - "eastus2.management.azure.com"
    - "management.core.windows.net"
    - containers
    - "centralus-2.in.applicationinsights.azure.com"
    - "westus-0.in.applicationinsights.azure.com"
    - "169.254.169.254"

engine:
  id: copilot
  agent: ops-monitor

timeout-minutes: 10

labels: [monitoring, automation]
---

# Site Health Monitor & Auto-Repair Agent

## Purpose

The site-health-check workflow has detected that the GitHub Copilot Hackathon site is DOWN or degraded. Your job is to investigate the root cause using Azure infrastructure tools, attempt auto-repair, and report findings.

## Health Check Results (from the dispatcher)

The following health check data was collected by the dispatcher workflow:
- **HTTP Status:** "${{ github.event.inputs.site_status }}" (expect 200; 000 means connection timeout)
- **Response Time:** "${{ github.event.inputs.response_time }}" seconds
- **Content OK:** "${{ github.event.inputs.content_ok }}" (true = HTML contains "GitHub Copilot")
- **Agenda OK:** "${{ github.event.inputs.agenda_ok }}" (true = /agenda.json returns valid JSON)

If no inputs are provided (manual dispatch), assume the site needs investigation.

## Site Details

- **Production URL:** https://ghcp-hackathon-app.bravegrass-130ae164.eastus2.azurecontainerapps.io
- **Resource Group:** rg-ghcp-hackathon
- **Container App:** ghcp-hackathon-app
- **Container App Environment:** ghcp-hackathon-app-env
- **ACR:** ghcphackathonacr
- **Azure Subscription ID:** 2a1b501e-d398-4fb5-8680-01acff08b7d2

## Step 1: Investigate

Use the Azure MCP server to investigate the infrastructure:

1. **Container App status** — Query the container app provisioning state and running status
2. **Revision status** — Check if the active revision is healthy, provisioned, and running
3. **Recent logs** — Pull container logs to look for errors (nginx errors, crash loops, OOM kills)
4. **Container App Environment health** — Verify the environment is operational
5. **ACR image status** — Verify the latest image exists and is accessible
6. **Resource group health** — Check if any resources are in a failed state

Document all findings with specific details — error messages, timestamps, states.

## Step 2: Auto-Repair

Based on the investigation, attempt these repairs in order:

1. **If container app is deactivated or has 0 active revisions** — Use the Azure MCP `container_apps` tools to reactivate the app or create a new revision
2. **If revision is unhealthy or stopped** — Attempt to restart by deploying a new revision via Azure MCP
3. **If container is crash-looping** — Note the error but do NOT attempt image rebuild (flag for human review)
4. **If environment is unhealthy** — Flag for human review (do not attempt environment-level changes)
5. **If ACR image is missing** — Flag for human review

After any repair attempt, wait 60 seconds, then use web-fetch or bash curl to verify the site is back up:
```
curl -s -o /dev/null -w '%{http_code}' https://ghcp-hackathon-app.bravegrass-130ae164.eastus2.azurecontainerapps.io
```

## Step 3: Report

### If site could NOT be auto-repaired:
Create an issue with:
- **Title:** `Site Down — <brief description of failure>`
- **Body:**
  - 🔴 **Status:** DOWN
  - **Health check data:** (from inputs above)
  - **Failure type:** (container stopped, crash loop, environment issue, ACR image missing, etc.)
  - **Investigation findings:** (all details from Step 1)
  - **Repair attempts:** (what was tried, what happened)
  - **Recommended action:** (what a human should do)
  - **Timestamp:** when the issue was detected (UTC)

### If auto-repair SUCCEEDED:
Create an issue with:
- **Title:** `Site Recovered — <what was fixed>`
- **Body:**
  - 🟡 **Status:** RECOVERED (auto-repaired)
  - **Original failure:** (health check data + what was wrong)
  - **Repair action:** (what fixed it)
  - **Current status:** (verification result after repair)
  - **Root cause analysis:** (best guess at why it failed)

## Constraints

- Do NOT attempt destructive operations (delete resources, recreate environment)
- Do NOT modify the Docker image or Bicep infrastructure
- Keep investigation focused — don't explore unrelated Azure resources
- Rate limit: if an open incident issue already exists with the same failure type, add a comment instead of creating a new issue
- Always include timestamps in UTC
