# Gemini Maps Grounding

A portable agent skill for Maps-grounded place recommendations, with optional Google Search for current/date-specific questions. No fixed home location or personal profile is included.

## Install

```bash
npx skills add barronlroth/Skills --skill gemini-maps-grounding
```

Install [Google's Gemini API CLI](https://github.com/google-gemini/gemini-api-cli) using its official installation instructions. Requires Python 3.10+ and `gemini-api` on PATH. Set `GEMINI_API_KEY` securely in your environment. Gemini API usage is subject to billing and quotas.

```bash
python3 scripts/maps_cli.py "Quiet laptop cafe near Dolores Park, San Francisco" --lat 37.7599 --lng -122.4269
python3 scripts/maps_cli.py "A dated event in San Francisco plus nearby dinner; verify official date and terms" --with-search
```

Uses the CLI default model, always enables Maps, and opts into Search only with `--with-search`. `--dry-run` previews without an API call. Raw results are saved locally; they may contain your queries and should not be published. No booking or purchasing is performed.
