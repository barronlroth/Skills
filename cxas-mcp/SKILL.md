---
name: cxas-mcp
description: Build, manage, and deploy agents on Google Cloud CX Agent Studio via the MCP server over HTTP. Use when asked to create CXAS agents, add sub-agents, configure tools, run evaluations, update instructions, deploy to channels, or manage any CXAS resource programmatically. Also use when asked about CXAS architecture, agent hierarchy, or the CES API.
---

# CX Agent Studio MCP

Interact with Google Cloud CX Agent Studio (CXAS) via its MCP server over raw HTTP.

## Authentication

Get a fresh access token before every batch of calls. Tokens expire after ~1 hour.

```bash
TOKEN=$(gcloud auth application-default print-access-token)
```

If gcloud ADC is not configured, the user must run:
```bash
gcloud auth application-default login
```

## Making MCP Calls

All calls are JSON-RPC 2.0 POSTs to the MCP endpoint:

```bash
curl -s -X POST "https://ces.us.rep.googleapis.com/mcp" \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-goog-user-project: PROJECT_ID" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"METHOD","params":PARAMS,"id":1}'
```

### Methods

- `initialize` - Handshake (call once per session if needed)
- `tools/list` - List all available MCP tools and their schemas
- `tools/call` - Call a specific tool: `{"name":"TOOL_NAME","arguments":{...}}`

### Response Parsing

Results come in `result.content[0].text` as a JSON string. Parse it:

```bash
| python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(json.loads(d['result']['content'][0]['text']),indent=2))"
```

Errors also come in `result.content[0].text` as a plain string starting with an exception class name (e.g., `com.google.apps.framework.request.BadRequestException:`).

## Resource Hierarchy

```
Project
└── Location (always "us" for now)
    └── App (top-level container)
        ├── Agents (root + sub-agents in a tree)
        │   ├── instruction (XML-structured with <role>, <persona>, <taskflow>)
        │   ├── tools (references to tool resources)
        │   ├── childAgents (references to sub-agent resources)
        │   └── callbacks (before/after agent, model, tool)
        ├── Tools (Python functions, OpenAPI, MCP, data stores, widgets)
        ├── Toolsets (groups of tools)
        ├── Guardrails
        ├── Deployments (web widget, telephony, API)
        ├── Evaluations & Datasets
        └── Versions (immutable snapshots)
```

### Resource Name Format

All resources follow: `projects/{PROJECT_ID}/locations/{LOCATION}/apps/{APP_ID}/...`

Example: `projects/my-project/locations/us/apps/abc-123/agents/my-agent`

## Common Workflows

### Create an App

```json
{"name":"create_app","arguments":{
  "parent":"projects/PROJECT/locations/us",
  "app":{"displayName":"My Agent","description":"..."}
}}
```

Returns an async operation. The app is usually ready within seconds. List apps to confirm.

### Create an Agent

```json
{"name":"create_agent","arguments":{
  "parent":"projects/PROJECT/locations/us/apps/APP_ID",
  "agentId":"my-agent-id",
  "agent":{
    "displayName":"Agent Name",
    "description":"...",
    "instruction":"<role>...</role>\n<persona>...</persona>\n<taskflow>...</taskflow>",
    "tools":["projects/.../tools/TOOL_ID"],
    "childAgents":["projects/.../agents/CHILD_ID"]
  }
}}
```

**Agent ID constraints:** Must match `[a-zA-Z0-9][a-zA-Z0-9-_]{4,35}` (5-36 chars, alphanumeric start).

**Instruction format:** Use XML-structured instructions:
- `<role>` - What the agent is
- `<persona>` - How it behaves
- `<taskflow>` - Step-by-step logic, use `{@AGENT: Display Name}` and `{@TOOL: function_name}` references

### Set Root Agent

Update the app to point to the root agent:

```json
{"name":"update_app","arguments":{
  "app":{
    "name":"projects/.../apps/APP_ID",
    "displayName":"App Name",
    "rootAgent":"projects/.../agents/ROOT_AGENT_ID"
  }
}}
```

### Create a Python Tool

```json
{"name":"create_tool","arguments":{
  "parent":"projects/.../apps/APP_ID",
  "tool":{
    "pythonFunction":{
      "name":"function_name",
      "pythonCode":"def function_name(param: str) -> dict:\n    \"\"\"Docstring.\"\"\"\n    return {'result': param}"
    }
  }
}}
```

**Key constraints:**
- Only stdlib modules available (`urllib`, `json`, `re`, etc.). No `requests`, no `pip`.
- Use `urllib.request` for HTTP calls.
- Function name in `pythonFunction.name` must match the def in the code.
- `displayName` is read-only (auto-derived). Do NOT set it.

### Create a Guardrail

```json
{"name":"create_guardrail","arguments":{
  "parent":"projects/.../apps/APP_ID",
  "guardrail":{
    "displayName":"Safety Guardrail",
    "instruction":"Never discuss competitor brands negatively..."
  }
}}
```

### Deploy

```json
{"name":"create_deployment","arguments":{
  "parent":"projects/.../apps/APP_ID",
  "deployment":{
    "displayName":"Web Widget",
    "channelProfile":{"channelType":"WEB_UI"}
  }
}}
```

Channel types: `WEB_UI`, `API`, `TWILIO`, `GOOGLE_TELEPHONY_PLATFORM`, `CONTACT_CENTER_AS_A_SERVICE`, `FIVE9`

### Export/Import (for version control)

```json
{"name":"start_export_app","arguments":{"name":"projects/.../apps/APP_ID"}}
{"name":"start_import_app","arguments":{"parent":"projects/.../locations/us","appContent":"..."}}
```

## Gotchas

1. **Async operations.** `create_app` and `update_app` return `{"done":false}`. List the resource to confirm creation.
2. **No `requests` module.** Python tools run in a restricted sandbox. Use `urllib.request` for HTTP.
3. **Tool `displayName` is read-only.** It's auto-derived from the tool type. Don't set it in create/update calls.
4. **Agent ID format.** Must be 5-36 chars, start with alphanumeric. `root` is too short.
5. **US region only.** Location is always `us` for now.
6. **Token refresh.** gcloud ADC tokens expire after ~1h. Re-fetch before long sessions.
7. **Large responses.** Agent/app GET responses can be huge. Pipe through python to extract what you need.
8. **etag for updates.** If concurrent editing is a concern, include the etag from the GET response in your update call.

## Full Tool Reference

For the complete list of 60+ MCP tools with parameters, see [references/tools.md](references/tools.md).
