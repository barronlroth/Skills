# cxas CLI Command Reference

All commands are run from `/Users/barron/Developer/cxas/`:
```bash
cxas <command> [options]

# Or during development:
npm run cxas -- <command> [options]
npx tsx bin/cxas.ts <command> [options]
```

## auth

Verify gcloud ADC authentication and test CXAS API connectivity.

```bash
cxas auth
cxas auth --json
```

**Prereq:** `gcloud auth application-default login` must have been run.

**Output:**
```
Authenticated via gcloud ADC
  Project: gen-lang-client-0380732956
  Account: user@example.com
```

**Errors:**
- "Failed to get access token" → Run `gcloud auth application-default login`
- "Failed to get project" → Run `gcloud config set project <PROJECT_ID>`
- "Token is valid but CXAS API call failed" → Check project has CXAS enabled

---

## list

List all apps in the current project.

```bash
cxas list
cxas list --json
cxas list --project my-other-project
```

**Output:**
```
  NAME                     ID                                    CREATED
  Ferrari Customer Support 99d5fa35-aa58-4f65-ae6c-f56afd087780  2026-02-21
  My Other App             abc12345-...                          2026-03-01
```

---

## get

Show app details including agents, tools, and deployments.

```bash
cxas get 99d5           # UUID prefix
cxas get "Ferrari"      # Display name (partial match)
cxas get 99d5 --json    # Full JSON output
```

**Output:**
```
Ferrari Customer Support
  Root Agent: ferrari-concierge
  Agents: 5 (Formula 1 Specialist, Ferrari Concierge, ...)
  Tools: 10 (get_model_specs, lookup_vehicle, ...)
  Deployments: 1 (Ferrari Test Widget)
```

**Errors:**
- "Ambiguous app ID" → Multiple apps match; shows list of matches
- "App not found" → No match; suggests `cxas list`

---

## pull

Export an app to local files.

```bash
cxas pull 99d5                    # Auto-names directory
cxas pull 99d5 --out my-app       # Custom output directory
cxas pull "Ferrari Customer"      # By display name
```

**What happens:**
1. Calls `start_export_app` → returns async operation
2. Polls operation until done (exponential backoff, 500ms → 5s, 2min timeout)
3. Decodes base64 zip from `response.appContent`
4. Extracts files, stripping the top-level app directory name
5. Writes `.cxas` context file

**Output:**
```
Pulling Ferrari Customer Support...
Exported to ./ferrari-customer-support/
```

---

## push

Push local changes to the cloud. Syncs agents, tools, guardrails, and app settings.

```bash
cxas push ./ferrari-customer-support/     # Push to original app
cxas push ./my-app/ --to "Other App"      # Push to different app
cxas push .                               # Push current directory
cxas push . --delete                      # Also delete cloud-only resources
```

**What happens:**
1. Reads `.cxas` to determine target app
2. Reads all local files (app.yaml, agents, tools, guardrails)
3. Fetches current cloud state (agents, tools, guardrails)
4. Syncs each resource type:
   - **Agents**: matched by display name → update existing, create new
   - **Tools**: matched by function name → update existing, create new
   - **Guardrails**: matched by display name → update existing, create new
   - **App settings**: syncs rootAgent, model, language, timezone, guardrail assignments
5. With `--delete`: removes cloud resources not present locally (system tools like `end_session` are never deleted)

**What it syncs per agent:**
- `displayName`, `instruction` (from `.txt` file), `description`

**What it syncs per tool:**
- `pythonFunction.name`, `pythonFunction.pythonCode` (from `.py` file)

**What it syncs per guardrail:**
- `displayName`, `enabled`, `action`, `instruction`, `llmPromptSecurity`, `modelSafety`

**What it syncs for app settings:**
- `rootAgent`, `modelSettings`, `languageSettings`, `audioProcessingConfig`, `timeZoneSettings`, `toolExecutionMode`, `defaultChannelProfile`, `loggingSettings`, `errorHandlingSettings`, `guardrails`

**Output:**
```
Pushing to Ferrari Customer Support (99d5fa35-...)...
  Updating agent: Ferrari Concierge
  Creating agent: New Specialist
  Updating tool: get_model_specs
  Creating tool: new_lookup
  Updating guardrail: Safety Guardrail
  Updating app settings
Push complete.
  Test at: https://console.cloud.google.com/gen-app-builder/...
```

**`--delete` flag:**
When provided, removes cloud-only resources:
```
  Deleting agent: Removed Agent
  Deleting tool: old_tool
  Deleting guardrail: Old Guardrail
```

---

## create

Create a new empty app.

```bash
cxas create "My New Agent"
cxas create "My New Agent" --description "A test agent"
```

**What happens:**
1. Calls `create_app` → returns async operation
2. Polls operation until complete
3. Lists apps filtered by displayName to find the new app ID

**Output:**
```
Creating app My New Agent...
Created app: My New Agent (d6b93032-fd85-4ef5-b138-5d377e632eb8)
  Ready for: cxas push ./local-agent/ --to My New Agent
```

---

## branch

Create a full copy of an existing app.

```bash
cxas branch 99d5                          # Auto-name
cxas branch 99d5 --name my-experiment     # Custom name
cxas branch "Ferrari Customer Support"    # By display name
```

**Auto-naming:** `{app-name-lowercased}-dev-{gcloud-username}`
Example: `ferrari-customer-support-dev-barron`

**What happens:**
1. Pulls the source app to a local directory (named after the branch)
2. Packs the local files into a zip
3. Calls `start_import_app` **without appId** → creates a new app
4. Polls until complete
5. Finds the new app (most recently created matching source display name)
6. Renames to branch name via `update_app` (includes `rootAgent` to avoid clearing it)
7. Updates `.cxas` with new app ID and source app reference

**Output:**
```
Branching Ferrari Customer Support...
Pulling Ferrari Customer Support...
Exported to ./my-experiment/
Creating branch app via import...
Branch created: my-experiment (e1ef310e-5d3f-4cad-b857-b4207ba51a26)
  Local copy: ./my-experiment/
```

**After branching, push targets the branch:**
```bash
# Edit files in ./my-experiment/
cxas push ./my-experiment/   # Pushes to branch, not source
```

---

## Common Error Patterns

| Error | Cause | Fix |
|-------|-------|-----|
| "Failed to get access token" | gcloud ADC not configured | `gcloud auth application-default login` |
| "Failed to get project" | No default project set | `gcloud config set project <ID>` |
| "App already exists" | Bulk import to existing app | Normal — CLI falls back to CRUD |
| "App root agent () not found" | `update_app` without `rootAgent` | Always include `rootAgent` in updates |
| "Ambiguous app ID" | Multiple apps match prefix | Use a longer prefix or full UUID |
| "Operation timed out" | Export/import took too long | Retry; check network connectivity |
| "MCP request failed: 400" | Invalid API request | Use `--verbose` to see request details |
