---
name: cxas-cli
description: |
  How to use the cxas CLI to manage Google Cloud CX Agent Studio apps locally.
  Use this skill whenever the user mentions CXAS, CX Agent Studio, conversational agents
  on Google Cloud, or wants to pull/push/branch/create agents from the command line.
  Also use when working with CXAS export files (app.yaml, agent instruction.txt, tool .py files),
  editing agent instructions or tool code locally, or troubleshooting cxas commands.
  Even if the user just says "pull the agent" or "push my changes" in the context of CXAS work,
  this skill applies.
---

# cxas CLI

The `cxas` CLI enables local development workflows for Google Cloud CX Agent Studio.
Instead of editing agents in the browser console, developers can pull an app to local files,
edit with their own tools, and push changes back. Think of it like `git clone` / `git push`
but for CXAS agents.

**Location:** `/Users/barron/Developer/cxas/`
**Run via:** `npm run cxas --` (from the cxas directory), or `npx tsx bin/cxas.ts`

## Quick Start

```bash
cd /Users/barron/Developer/cxas

cxas auth              # Verify auth works
cxas list              # List available apps
cxas pull abc123       # Pull an app (accepts UUID prefix)
# Edit files locally (instructions, tool code, etc.)
cxas push ./my-app/    # Push changes back
```

## Core Workflow: Pull → Edit → Push

This is the primary use case. The round-trip looks like:

1. **Pull** exports a cloud app to local YAML/txt/py files
2. **Edit** the local files — agent instructions (`.txt`), tool code (`.py`), configs (`.yaml`)
3. **Push** sends changes back to the cloud app

When pushing to an existing app, `cxas` updates each resource individually (agents, then tools)
via the CRUD API. It matches local files to cloud resources by display name. Only resources
that exist in **both** local and cloud are updated — it won't create or delete resources.

## Commands

### `cxas auth`
Verifies gcloud ADC authentication and tests the CXAS API connection.
Requires `gcloud auth application-default login` to have been run beforehand.

### `cxas list`
Lists all apps in the current GCP project. Shows name, UUID, and creation date.

### `cxas get <app-id>`
Shows details for an app — agents, tools, deployments. Accepts a UUID prefix
(e.g., `99d5` instead of the full `99d5fa35-aa58-4f65-ae6c-f56afd087780`).

### `cxas pull <app-id> [--out <dir>]`
Exports an app to local files. Creates a directory with the app's structure.
Writes a `.cxas` context file that tracks which app/project this came from.

### `cxas push [directory] [--to <app-id>] [--delete]`
Syncs local changes to the cloud. Creates new agents/tools/guardrails, updates existing ones,
and syncs app-level settings (rootAgent, model, language, etc.). Use `--to` to target a
different app. Use `--delete` to remove cloud resources not present locally.

### `cxas create <app-name> [--description <desc>]`
Creates a new empty app. Returns the new app's UUID.

### `cxas branch <source-app> [--name <branch-name>]`
Creates a full copy of an app: pulls the source, imports as a new app, renames it.
The local directory's `.cxas` tracks both the new app ID and the source app ID.

Auto-generates a branch name like `my-app-dev-barron` if `--name` isn't provided.

## Global Flags

All commands support:
- `--project <id>` — GCP project (default: from `gcloud config`)
- `--location <loc>` — CXAS location (default: `us`)
- `--json` — Output raw JSON instead of formatted text
- `--verbose` — Log MCP API requests/responses to stderr

## Local File Format

When you `pull` an app, you get this structure. See `references/file-format.md` for
the full specification with examples.

```
my-app/
├── .cxas                                    # Context (project, appId, etc.)
├── app.yaml                                 # App config
├── agents/
│   └── Agent_Name/
│       ├── Agent_Name.yaml                  # Agent config (references instruction.txt)
│       └── instruction.txt                  # The agent's prompt/instruction
├── tools/
│   └── tool_name/
│       ├── tool_name.yaml                   # Tool config (references python_code.py)
│       └── python_function/
│           └── python_code.py               # The tool's Python code
├── toolsets/                                # OpenAPI/MCP toolset configs
└── environment.json                         # Environment variables for toolsets
```

**Key files to edit:**
- `agents/*/instruction.txt` — Agent instructions (XML-structured: `<role>`, `<persona>`, `<taskflow>`)
- `tools/*/python_function/python_code.py` — Python tool implementations
- Agent and tool `.yaml` files for config changes (description, child agents, tool assignments)

## Gotchas and Troubleshooting

Read `references/commands.md` for the complete command reference with error patterns.
The most important things to know:

1. **Push syncs via CRUD APIs.** Push creates, updates, and (with `--delete`) deletes
   agents, tools, and guardrails individually. It also syncs app-level settings.
   Without `--delete`, cloud-only resources are left untouched.

2. **`update_app` clears `rootAgent` if you don't include it.** The CLI handles this
   automatically. If you use the MCP API directly, always include `rootAgent` in
   `update_app` calls.

3. **Import always creates a new app.** `start_import_app` without an `appId` creates a
   new app. With an `appId`, it fails ("App already exists"). This is why `branch` uses
   import (to create a copy) while `push` uses CRUD (to update in place).

4. **Auth tokens expire after ~1 hour.** If you get auth errors mid-session, re-run
   `gcloud auth application-default print-access-token` (or the CLI will do it automatically
   on next invocation since it caches per-session).

5. **ID prefix resolution is smart.** You can use UUID prefixes, display names, or partial
   display names. If ambiguous, it lists matches. If not found, it suggests `cxas list`.
