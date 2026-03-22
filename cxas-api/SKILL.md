---
name: cxas-api
description: |
  How to call the CX Agent Studio MCP API directly for operations beyond what the cxas CLI covers.
  Use this skill when the user needs to create/update/delete individual agents, tools, guardrails,
  toolsets, deployments, or evaluations via the API. Also use when troubleshooting API errors,
  building automation around CXAS, or when the cxas CLI doesn't cover the needed operation
  (e.g., managing guardrails, deployments, evaluations, app versions). Triggers on mentions of
  the CES/CXAS API, MCP endpoint, JSON-RPC calls to CXAS, or any CXAS resource management
  that goes beyond pull/push/branch.
---

# CX Agent Studio MCP API

The CXAS MCP API is a JSON-RPC 2.0 endpoint that provides full CRUD access to all
CX Agent Studio resources. The `cxas` CLI wraps this API for common workflows, but
for operations like managing guardrails, deployments, evaluations, or fine-grained
resource manipulation, you can call the API directly.

## Authentication

```bash
TOKEN=$(gcloud auth application-default print-access-token)
```

Tokens expire after ~1 hour. Always get a fresh token before a batch of calls.

## Making Calls

All calls are POST requests to:
```
https://ces.us.rep.googleapis.com/mcp
```

**Headers:**
```
Authorization: Bearer $TOKEN
x-goog-user-project: $PROJECT_ID
Content-Type: application/json
```

**Body format (JSON-RPC 2.0):**
```json
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "TOOL_NAME",
    "arguments": { ... }
  },
  "id": 1
}
```

**Response parsing:**
- Success: `result.content[0].text` contains a JSON string — parse it
- Error: `result.isError` is true and `result.content[0].text` has the error message
- The HTTP status may be 400 even for parseable JSON-RPC error responses

**Shell example:**
```bash
curl -s -X POST "https://ces.us.rep.googleapis.com/mcp" \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-goog-user-project: $PROJECT_ID" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"list_apps","arguments":{"parent":"projects/'$PROJECT_ID'/locations/us"}},"id":1}'
```

Or use the helper script at `/Users/barron/.agents/skills/cxas-mcp/scripts/cxas_call.sh`:
```bash
bash cxas_call.sh $PROJECT_ID list_apps '{"parent":"projects/'$PROJECT_ID'/locations/us"}'
```

## Resource Hierarchy

```
projects/{PROJECT_ID}/locations/us/apps/{APP_ID}/
├── agents/{AGENT_ID}
├── tools/{TOOL_ID}
├── toolsets/{TOOLSET_ID}
├── guardrails/{GUARDRAIL_ID}
├── deployments/{DEPLOYMENT_ID}
├── evaluations/{EVALUATION_ID}
└── versions/{VERSION_ID}
```

Location is always `us`.

## Common Operations

### Apps
| Tool | Purpose |
|------|---------|
| `list_apps` | List all apps. Args: `{parent}` |
| `get_app` | Get app details. Args: `{name}` |
| `create_app` | Create app (async). Args: `{parent, app: {displayName}}` |
| `update_app` | Update app. Args: `{app: {name, displayName, rootAgent}}` |
| `delete_app` | Delete app (async). Args: `{name}` |

**Critical:** `update_app` MUST include `rootAgent` or it gets cleared to empty string.

### Agents
| Tool | Purpose |
|------|---------|
| `list_agents` | List agents in app. Args: `{parent: "...apps/{APP_ID}"}` |
| `get_agent` | Get agent. Args: `{name}` |
| `create_agent` | Create agent. Args: `{parent, agentId, agent: {displayName, instruction, tools, childAgents}}` |
| `update_agent` | Update agent. Args: `{agent: {name, displayName, instruction}}` |
| `delete_agent` | Delete agent. Args: `{name}` |

Agent ID constraints: 5-36 chars, `[a-zA-Z0-9][a-zA-Z0-9-_]{4,35}`, alphanumeric start.

Instruction format uses XML tags: `<role>`, `<persona>`, `<taskflow>`.
Reference other agents with `{@AGENT: Display Name}`, tools with `{@TOOL: function_name}`.

### Tools
| Tool | Purpose |
|------|---------|
| `list_tools` | List tools. Args: `{parent}` |
| `get_tool` | Get tool. Args: `{name}` |
| `create_tool` | Create tool. Args: `{parent, tool: {pythonFunction: {name, pythonCode}}}` |
| `update_tool` | Update tool. Args: `{tool: {name, pythonFunction: {name, pythonCode}}}` |
| `delete_tool` | Delete tool. Args: `{name}` |

**Important:** `displayName` is read-only for tools (auto-derived). Don't set it.

### Guardrails
| Tool | Purpose |
|------|---------|
| `list_guardrails` | List guardrails. Args: `{parent}` |
| `create_guardrail` | Create guardrail. Args: `{parent, guardrail: {displayName, instruction}}` |
| `update_guardrail` | Update. Args: `{guardrail: {name, displayName, instruction}}` |
| `delete_guardrail` | Delete. Args: `{name}` |

### Deployments
| Tool | Purpose |
|------|---------|
| `list_deployments` | List deployments. Args: `{parent}` |
| `create_deployment` | Create deployment. Args: `{parent, deployment: {displayName, channelProfile: {channelType}}}` |
| `delete_deployment` | Delete. Args: `{name}` |

Channel types: `WEB_UI`, `API`, `TWILIO`, `GOOGLE_TELEPHONY_PLATFORM`, `FIVE9`

### App Versions
| Tool | Purpose |
|------|---------|
| `create_app_version` | Snapshot current state. Args: `{parent, appVersion: {displayName}}` |
| `list_app_versions` | List versions. Args: `{parent}` |
| `restore_app_version` | Restore to a version. Args: `{name}` |

### Evaluations
| Tool | Purpose |
|------|---------|
| `create_evaluation` | Create eval. Args: `{parent, evaluation: {displayName, golden/scenario}}` |
| `run_evaluation` | Run evals (async). Args: `{app, evaluations: [...], displayName}` |
| `list_evaluation_runs` | List runs. Args: `{parent}` |
| `get_evaluation_result` | Get result. Args: `{name}` |

### Export / Import
| Tool | Purpose |
|------|---------|
| `start_export_app` | Export (async). Args: `{projectId, locationId, appId}` |
| `start_import_app` | Import (async). Args: `{projectId, locationId, content}` (no appId = new app) |

### Operations (for async calls)
| Tool | Purpose |
|------|---------|
| `get_operation` | Poll async operation. Args: `{name: "...operations/..."}` |

## Async Operations

`create_app`, `delete_app`, `start_export_app`, `start_import_app`, and `run_evaluation`
return operation objects. Poll with `get_operation` using exponential backoff:

```
Poll: 500ms → 1s → 2s → 4s → 5s (capped)
Timeout: 2 minutes
Check: op.done === true
Result: op.response (success) or op.error (failure)
```

## Key Gotchas

1. **`update_app` clears `rootAgent`** if not included in the request body.
   Always fetch the app first and include `rootAgent` in updates.

2. **`start_import_app` with `appId` fails** with "App already exists."
   The MCP endpoint doesn't expose conflict resolution. To update an existing app,
   use individual CRUD calls instead of bulk import.

3. **Tool `displayName` is read-only.** Auto-derived from the tool type. Setting it
   in create/update calls causes errors.

4. **Agent IDs must be 5-36 chars.** `root` is too short. Use something like `root-agent`.

5. **Python tool runtime is sandboxed.** Only stdlib modules. Use `ces_requests` (globally
   available, don't import) for HTTP. No `requests`/`httpx`. Parameter defaults of `None`
   on typed params fail — use `str = ""` instead.

For the complete list of all 42+ tools with full parameter specs, see
`/Users/barron/.agents/skills/cxas-mcp/references/tools.md`.
