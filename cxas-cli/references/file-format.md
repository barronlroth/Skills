# CXAS Export File Format Reference

## Directory Structure

```
app-name/
├── .cxas                                          # CLI context file
├── app.yaml                                       # App-level configuration
├── environment.json                               # Environment variables for toolsets
├── agents/
│   └── Agent_Display_Name/                        # One directory per agent
│       ├── Agent_Display_Name.yaml                # Agent config
│       └── instruction.txt                        # Agent instruction/prompt
├── tools/
│   └── tool_function_name/                        # One directory per tool
│       ├── tool_function_name.yaml                # Tool config
│       └── python_function/
│           └── python_code.py                     # Python implementation
└── toolsets/
    └── Toolset_Name/                              # One directory per toolset
        ├── Toolset_Name.yaml                      # Toolset config
        └── open_api_toolset/
            └── open_api_schema.yaml               # OpenAPI spec (if applicable)
```

## .cxas (Context File)

JSON file tracking which cloud app this directory maps to. Created by `pull` and `branch`.

```json
{
  "project": "my-gcp-project-id",
  "location": "us",
  "appId": "99d5fa35-aa58-4f65-ae6c-f56afd087780",
  "sourceAppId": null,
  "pulledAt": "2026-03-05T19:15:00.000Z"
}
```

- `sourceAppId` is set when created via `branch` (tracks the original app)
- `push` reads this to know where to push (unless `--to` overrides)

## app.yaml

Top-level app configuration.

```yaml
displayName: Ferrari Customer Support
rootAgent: Ferrari Concierge          # Display name of the root agent
audioProcessingConfig:
  synthesizeSpeechConfigs:
    en-US: {}
loggingSettings: {}
modelSettings:
  model: gemini-3.0-flash-001
languageSettings:
  defaultLanguageCode: en-US
defaultChannelProfile: {}
timeZoneSettings:
  timeZone: America/Los_Angeles
toolExecutionMode: PARALLEL
```

`rootAgent` references the root agent by **display name**, not by ID.

## Agent Files

### Agent YAML (`agents/Agent_Name/Agent_Name.yaml`)

```yaml
displayName: Ferrari Concierge
description: Root agent for Ferrari customer support. Routes inquiries to specialized sub-agents.
instruction: agents/Ferrari_Concierge/instruction.txt
childAgents:
- Formula 1 Specialist
- Ownership Experience
- Sales Consultant
- Service Advisor
```

- `instruction` is a relative path to the `.txt` file
- `childAgents` and `tools` reference by **display name**

### Agent Instruction (`agents/Agent_Name/instruction.txt`)

XML-structured prompt. This is the main file you'll edit for agent behavior changes.

```xml
<role>
You are the Ferrari Customer Concierge, the first point of contact for Ferrari owners.
</role>

<persona>
Speak with warmth and sophistication. Use Italian flourishes sparingly.
</persona>

<taskflow>
- Greet the caller warmly and identify their need
- When the caller asks about Formula 1, delegate to {@AGENT: Formula 1 Specialist}
- When the caller needs vehicle service, delegate to {@AGENT: Service Advisor}
- When the caller asks about a Ferrari model, delegate to {@AGENT: Sales Consultant}
</taskflow>
```

References to other agents use `{@AGENT: Display Name}` syntax.
References to tools use `{@TOOL: function_name}` syntax.

## Tool Files

### Tool YAML (`tools/tool_name/tool_name.yaml`)

```yaml
pythonFunction:
  name: get_model_specs
  pythonCode: tools/get_model_specs/python_function/python_code.py
  description: |-
    Get detailed specifications for a Ferrari model.

    Args:
        model: Ferrari model name (e.g., SF90 Stradale, 296 GTB).

    Returns:
        dict with model specifications.
displayName: get_model_specs
```

- `pythonCode` is a relative path to the `.py` file
- `description` is the docstring the LLM sees when deciding whether to call the tool
- `displayName` is auto-derived — don't change it manually

### Python Code (`tools/tool_name/python_function/python_code.py`)

Standard Python function. The function name must match `pythonFunction.name` in the YAML.

```python
def get_model_specs(model: str) -> dict:
    """Get detailed specifications for a Ferrari model.

    Args:
        model: Ferrari model name (e.g., SF90 Stradale, 296 GTB).

    Returns:
        dict with model specifications.
    """
    # Implementation here
    return {"model": model, "specs": {...}}
```

**Runtime constraints:**
- Only stdlib modules available (`json`, `re`, `datetime`, `urllib`, etc.)
- `ces_requests` is globally available for HTTP calls (don't import it)
- No `requests`, `httpx`, or third-party libraries
- `urllib.request` imports but DNS may fail in sandbox — prefer `ces_requests`
- Parameter defaults of `None` are not supported for typed params (use `str = ""` instead)

## Toolset Files

### Toolset YAML

```yaml
displayName: OpenF1 API
openApiToolset:
  openApiSchema: toolsets/OpenF1_API/open_api_toolset/open_api_schema.yaml
  ignoreUnknownFields: true
description: Real-time Formula 1 data from the OpenF1 API.
```

### OpenAPI Schema

Standard OpenAPI 3.0 spec. The `servers.url` field uses `$env_var` placeholder —
the actual URL is provided via `environment.json`.

## environment.json

Maps toolset environment variables (like API base URLs).

```json
{
  "toolsets": {
    "OpenF1 API": {
      "openApiToolset": {
        "url": "https://api.openf1.org/v1"
      }
    }
  }
}
```

## Agent YAML with Tools

When an agent has assigned tools, they're listed by display name:

```yaml
displayName: Service Advisor
description: Handles vehicle service, maintenance scheduling, and repair inquiries.
instruction: agents/Service_Advisor/instruction.txt
tools:
- lookup_vehicle
- check_service_availability
- get_recall_info
```

## Naming Conventions

- Agent directories use underscored display names: `Ferrari_Concierge/`
- Tool directories use the function name: `get_model_specs/`
- Toolset directories use underscored display names: `OpenF1_API/`
- All cross-references (rootAgent, childAgents, tools) use **display names**, not IDs
