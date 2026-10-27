# Recommendation queries

Ask for the user's actual audience, occasion, area, budget, dietary constraints, preferred vibe and travel radius. Do not assume a home location or personal taste defaults.

Prompt template:

```text
Task: <recommendation task>
Location: <city/neighborhood/anchor>
Audience and occasion: <provided context>
Preferences and anti-preferences: <provided taste>
Constraints: <budget/diet/time/mobility>
Return one clear winner plus meaningful backups, tradeoffs and Google Maps links.
Distinguish review evidence from inference. State unknown policies or availability.
```

Lead with an opinionated top pick and a compact linked comparison. Do not treat high ratings as a substitute for fit, dump every cited place as a recommendation, or invent reviewer consensus. Verify exact current hours, route times, inventory and booking availability through appropriate direct sources. The main skill defines when to add Search grounding.
