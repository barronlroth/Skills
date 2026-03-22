#!/bin/bash
# Usage: cxas_call.sh PROJECT_ID TOOL_NAME ARGUMENTS_JSON [ID]
# Example: cxas_call.sh my-project list_apps '{"parent":"projects/my-project/locations/us"}'
set -euo pipefail

PROJECT_ID="${1:?Usage: cxas_call.sh PROJECT_ID TOOL_NAME ARGUMENTS_JSON [ID]}"
TOOL_NAME="${2:?Missing tool name}"
ARGS_JSON="${3:?Missing arguments JSON}"
CALL_ID="${4:-1}"

TOKEN=$(gcloud auth application-default print-access-token 2>/dev/null)

PAYLOAD=$(python3 -c "
import json
print(json.dumps({
    'jsonrpc': '2.0',
    'method': 'tools/call',
    'params': {'name': '$TOOL_NAME', 'arguments': json.loads('$ARGS_JSON')},
    'id': $CALL_ID
}))
")

RESPONSE=$(curl -s -X POST "https://ces.us.rep.googleapis.com/mcp" \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-goog-user-project: $PROJECT_ID" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

# Parse and pretty-print the result
python3 -c "
import sys, json
d = json.loads('''$RESPONSE''')
content = d.get('result',{}).get('content',[{}])[0].get('text','')
is_error = d.get('result',{}).get('isError', False)
if is_error:
    print(f'ERROR: {content}', file=sys.stderr)
    sys.exit(1)
try:
    parsed = json.loads(content)
    print(json.dumps(parsed, indent=2))
except:
    print(content)
"
