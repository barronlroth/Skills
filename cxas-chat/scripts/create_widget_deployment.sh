#!/bin/bash
# Create a CXAS web widget deployment for an app
# Usage: ./create_widget_deployment.sh PROJECT_ID APP_ID DISPLAY_NAME [THEME] [MODALITY]
#
# Example:
#   ./create_widget_deployment.sh gen-lang-client-0380732956 553732cf-... "Ferrari Chat" DARK CHAT_ONLY

set -euo pipefail

PROJECT="${1:?Usage: $0 PROJECT_ID APP_ID DISPLAY_NAME [THEME] [MODALITY]}"
APP_ID="${2:?Missing APP_ID}"
DISPLAY_NAME="${3:?Missing DISPLAY_NAME}"
THEME="${4:-LIGHT}"
MODALITY="${5:-CHAT_ONLY}"

TOKEN=$(gcloud auth application-default print-access-token)

RESPONSE=$(curl -s -X POST "https://ces.us.rep.googleapis.com/mcp" \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-goog-user-project: $PROJECT" \
  -H "Content-Type: application/json" \
  -d "{
    \"jsonrpc\": \"2.0\",
    \"id\": \"1\",
    \"method\": \"tools/call\",
    \"params\": {
      \"name\": \"create_deployment\",
      \"arguments\": {
        \"parent\": \"projects/$PROJECT/locations/us/apps/$APP_ID\",
        \"deployment\": {
          \"displayName\": \"$DISPLAY_NAME\",
          \"channelProfile\": {
            \"channelType\": \"WEB_UI\",
            \"webWidgetConfig\": {
              \"modality\": \"$MODALITY\",
              \"theme\": \"$THEME\",
              \"webWidgetTitle\": \"$DISPLAY_NAME\",
              \"securitySettings\": {
                \"enablePublicAccess\": true,
                \"enableOriginCheck\": false
              }
            }
          }
        }
      }
    }
  }")

# Extract deployment name
DEPLOYMENT_NAME=$(echo "$RESPONSE" | python3 -c "
import json, sys
data = json.load(sys.stdin)
content = data.get('result', {}).get('structuredContent', {})
if content:
    print(content.get('name', 'ERROR: no name in response'))
else:
    text = data.get('result', {}).get('content', [{}])[0].get('text', '')
    print('ERROR: ' + text)
")

echo "Deployment: $DEPLOYMENT_NAME"
echo ""
echo "Embed snippet (add to <head>):"
echo ""
echo '<script defer src="https://www.gstatic.com/ces-console/fast/chat-messenger/prod/v1.12/chat-messenger.js"></script>'
echo '<link rel="stylesheet" href="https://www.gstatic.com/ces-console/fast/chat-messenger/prod/v1.12/themes/chat-messenger-default.css">'
echo ""
echo "Embed snippet (add to end of <body>):"
echo ""
cat << EMBED
<script>
window.addEventListener("chat-messenger-loaded", () => {
  chatSdk.registerContext(
    chatSdk.prebuilts.ces.createContext({
      deploymentName: "$DEPLOYMENT_NAME",
      tokenBroker: { enableTokenBroker: true, enableRecaptcha: false },
    }),
  );
});
</script>
<chat-messenger url-allowlist="*">
  <chat-messenger-chat-bubble chat-title="$DISPLAY_NAME" enable-audio-input></chat-messenger-chat-bubble>
</chat-messenger>
EMBED
