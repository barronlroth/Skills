---
name: cxas-chat
description: Deploy and embed CXAS web widget chat on external websites. Covers deployment creation via MCP, widget embed code, and all known gotchas with positioning, versioning, and CSS conflicts.
---

# CXAS Web Widget (Chat Embed)

Deploy a CX Agent Studio agent as a floating chat widget on any website.

## Prerequisites

- A CXAS app with at least one agent (use `cxas-mcp` skill to build one)
- `gcloud auth application-default login` configured
- The target website must be publicly accessible (or localhost for testing)

## Step 1: Create a Deployment

Use the MCP `create_deployment` tool. **Do NOT pass `appVersion`** — omitting it defaults to draft, which is what you want during development.

```bash
TOKEN=$(gcloud auth application-default print-access-token)
curl -s -X POST "https://ces.us.rep.googleapis.com/mcp" \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-goog-user-project: PROJECT_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": "1",
    "method": "tools/call",
    "params": {
      "name": "create_deployment",
      "arguments": {
        "parent": "projects/PROJECT_ID/locations/us/apps/APP_ID",
        "deployment": {
          "displayName": "Web Widget",
          "channelProfile": {
            "channelType": "WEB_UI",
            "webWidgetConfig": {
              "modality": "CHAT_ONLY",
              "theme": "LIGHT",
              "webWidgetTitle": "Your Chat Title",
              "securitySettings": {
                "enablePublicAccess": true,
                "enableOriginCheck": false
              }
            }
          }
        }
      }
    }
  }'
```

Save the deployment `name` from the response — you need the full resource path.

### Gotchas — Deployment

- **Do NOT use `versions/-` for draft** — the API rejects `-` as an invalid resource ID despite docs saying otherwise. Just omit `appVersion`.
- **`enablePublicAccess: true`** is required for unauthenticated visitors. Without it, the widget renders but chat fails silently.
- **`parent` must be the full resource path** — `projects/{project}/locations/{location}/apps/{app}`, not just the app ID.
- **There is no `list_versions` MCP tool** — you cannot discover pinnable versions programmatically. Use the console UI to create a version, then reference it by ID.

## Step 2: Embed the Widget

### In `<head>`:

```html
<!-- IMPORTANT: Use v1.12, NOT v1. The v1 path silently fails. -->
<script defer src="https://www.gstatic.com/ces-console/fast/chat-messenger/prod/v1.12/chat-messenger.js"></script>
<link rel="stylesheet" href="https://www.gstatic.com/ces-console/fast/chat-messenger/prod/v1.12/themes/chat-messenger-default.css">

<!-- DO NOT include chat-messenger-layout.css for floating bubble mode.
     It sets bottom: -10438px and pushes the widget offscreen. -->

<style>
chat-messenger {
  z-index: 9999;
  position: fixed !important;
  bottom: 20px !important;
  right: 90px !important;  /* NOT 20px — see "Zero Width" gotcha below */
}
</style>
```

### At end of `<body>`:

```html
<script>
window.addEventListener("chat-messenger-loaded", () => {
  chatSdk.registerContext(
    chatSdk.prebuilts.ces.createContext({
      deploymentName: "projects/PROJECT_ID/locations/us/apps/APP_ID/deployments/DEPLOYMENT_ID",
      tokenBroker: {
        enableTokenBroker: true,
        enableRecaptcha: false,
      },
    }),
  );
});
</script>

<chat-messenger url-allowlist="*">
  <chat-messenger-chat-bubble
    chat-title="Your Chat Title"
    enable-audio-input
  >
  </chat-messenger-chat-bubble>
</chat-messenger>
```

## Critical Gotchas — Embed

### 1. Version: Use v1.12, NOT v1
The public docs reference `v1/chat-messenger.js`. This version loads (HTTP 200) but **does not register the custom element or expose `chatSdk`**. Zero console errors. The widget silently does nothing. Always use `v1.12`.

### 2. Component: `chat-bubble` vs `chat-container`
- **`chat-messenger-chat-bubble`** — Floating FAB button (64x64) in bottom-right, expands to chat dialog on click. This is what you want for most external websites.
- **`chat-messenger-container`** — Inline/slide-in panel. Renders with 0x0 dimensions by default. Needs layout CSS and specific positioning. Used for embedded-in-page experiences.

The CXAS console UI generates `chat-messenger-container` by default. For a floating bubble, swap it to `chat-messenger-chat-bubble`.

### 3. Zero Width Problem
`chat-messenger` renders with **width: 0px**. The 64x64 bubble button overflows *leftward* from the element's right edge. With `right: 20px`, the element sits 20px from the viewport edge but the button extends 64px to the left, potentially getting clipped by `overflow-x: hidden` on `<body>` (extremely common CSS pattern).

**Fix:** Set `right: 90px` (or more) to push the zero-width anchor far enough from the edge that the overflowing button is fully visible.

### 4. Do NOT Include Layout CSS
The embed code from the UI includes:
```html
<link rel="stylesheet" href=".../chat-messenger-layout.css">
```
**Remove this for floating bubble mode.** It sets `bottom: -10438px` and hides the widget completely. It's only for slide-in panel (`chat-messenger-container`) mode.

### 5. No Error Feedback
When the widget fails (wrong version, wrong component, CSS clipping), there are:
- Zero console errors
- Zero console warnings
- Zero visual indicators

Debug by checking: `document.querySelector('chat-messenger').shadowRoot` — if null, the JS didn't initialize. If exists but inner elements have 0 dimensions, it's a CSS/positioning issue.

### 6. Event Listener Order
The `chat-messenger-loaded` event listener **must be registered before** the JS loads. Put the `<script defer>` in `<head>` and the `addEventListener` in `<body>`. If you put both in the body without defer, the event may fire before the listener is attached.

## Debugging Checklist

1. **Widget not rendering at all?**
   - Check JS version (must be v1.12)
   - Check `document.querySelector('chat-messenger').shadowRoot` exists
   - Check `typeof window.chatSdk` — should be "object"
   - Check `customElements.get('chat-messenger')` — should be defined

2. **Widget renders but not visible?**
   - Check `getBoundingClientRect()` on the entry point button inside shadow DOM
   - Check if `overflow-x: hidden` on body is clipping it
   - Check if layout CSS is setting negative bottom position
   - Increase `right` value to account for zero-width overflow

3. **Widget visible but chat doesn't work?**
   - Check `enablePublicAccess: true` in deployment security settings
   - Check deployment exists: `get_deployment` via MCP
   - Check browser network tab for 403/401 errors to CES API

## Modality Options

- `CHAT_ONLY` — text chat only
- `VOICE_ONLY` — voice input only
- `CHAT_AND_VOICE` — both (adds microphone button)

## Theme Options

- `LIGHT` — light background
- `DARK` — dark background
