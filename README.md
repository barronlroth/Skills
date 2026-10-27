# Skills 🎶

Custom agent skills + a portable Skillfile for setting up any machine.

## Quick setup

```bash
bash Skillfile
```

This installs all skills globally from their original source repos, plus the custom skills in this repo.

## What's here

- **`Skillfile`** — declarative script that installs all skills from source repos
- **`cxas-*`** — Custom CX Agent Studio skills (Google Cloud)
- **`eli-pm`** — concise engineer-to-PM explanation frame

- **`gemini-maps-grounding`** — Maps-grounded local recommendations using the Gemini API CLI, with optional Search grounding

## Updating

```bash
npx skills update
```

Each source repo updates independently.
