# Maps vs Maps + Search: bounded local comparison

Four live requests, two paired prompts, gemini-api v0.4.4 default generation model (`gemini-3.8-flash`), no explicit model field. Each pair had identical prompts and location; only `google_search` was added. Single samples, not a benchmark or proof of consistent accuracy. Raw responses were retained privately for the evaluation; no private artifacts are included here.

| Scenario | Maps only | Maps + Search | Interpretation |
|---|---|---|---|
| Warm quiet laptop cafe near Dolores Park | 25.8s, 3065 total tokens, 2 Maps grounding uses; Maxfield's top, Dolores Park Cafe/Binge backups | 28.5s, 3235 total tokens, 1 Maps + 2 Search grounding uses; same winner, SPRO/Dolores Park Cafe backups | No demonstrated top-pick benefit from Search. Both discuss Wi-Fi/noise/tradeoffs; changed backups are not proof of superiority. |
| Halloween date-night event + nearby dinner, 2026-10-31 | 35.1s, 3131 total tokens, 5 Maps grounding uses; evergreen ghost tour/Alcatraz options, unsupported assumption tickets had not opened | 41.3s, 3238 total tokens, 4 Maps + 6 Search grounding uses; dated Symphony and BOOs Cruise candidates, official-looking URLs, but overclaimed verified ticket availability | Search broadens event discovery; still requires opening official pages and verifying date/year and ticket state. |

Independent source spot-check: Blue & Gold Fleet's special-events page lists BOOs Cruise starting at $33 and links to `/halloween-cruise`; the fetched overview did NOT independently establish the proposed date/time. The proposed Symphony deep link failed extraction, so its date/program/price/availability remain unverified. Do not recommend these exact event details as confirmed based on this test.

Policy: Maps always for place recommendations. Default Maps-only for evergreen taste/vibe discovery. Add Search for dated events, seasonal menus/experiences, current policies, recent changes/closures, exact product inventory or official booking terms that could change the choice. A special occasion alone (romantic anniversary dinner) does not mandate Search; a date-specific special menu/show does. Independently verify decisive current claims through official sources/transactional tools. Both tools being enabled is insufficient: inspect actual tool calls/grounding counts and citations.
