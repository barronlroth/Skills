---
name: gemini-maps-grounding
description: "Use for all location questions and place recommendations. Maps-grounded restaurants, cafes, shops, attractions, local events and itineraries."
version: 2.0.0
---

# Gemini Maps Grounding

## Mandatory routing

Load this skill whenever the user asks about a location, nearby places, restaurants, cafes, bars, hotels, shops, attractions, local recommendations, dish/restaurant comparisons, event venues, itineraries, or where to go. It is the entry point even for exact geographic questions. Do not answer recommendations from memory or generic web search alone.

For place recommendations/discovery, ALWAYS enable Google Maps grounding using the Gemini API CLI below. For exact addresses, contact details, open-now, travel times, directions and routes, use direct Maps tools (`goplaces` / Maps APIs) as the precise execution path after consulting this skill. Do not ask generative Gemini to invent a route ETA or replace transactional availability checks. Non-geographic uses of "location" (such as a file path) do not trigger this skill.

## Default execution: Gemini API CLI

Use `scripts/maps_cli.py`, which calls `gemini-api generate` and preserves raw provider JSON plus citations. No model pin or Search-on default is applied.

```bash
python3 <skill-dir>/scripts/maps_cli.py \
  "Best quiet warm cafe near Dolores Park for a laptop afternoon; one winner, two backups, tradeoffs and Maps links" \
  --lat 37.7599 --lng -122.4269

# A date-specific event / current-policy query:
python3 <skill-dir>/scripts/maps_cli.py \
  "Find a dated event in SF for October 31, 2026 plus dinner nearby; verify year/date from official sources; label unknown availability" \
  --lat 37.7599 --lng -122.4269 --with-search
```

- Use the CLI's DEFAULT model. Do not set `--model` or a `model` field unless the user specifically requests it. Tested CLI v0.4.4 default is `gemini-3.8-flash`; this is an observation, not a permanent pin.
- Maps grounding is always enabled. Search is opt-in via `--with-search`.
- Supply both `--lat` and `--lng`, or neither. There is NO silent home-location default: ground the location from the request/current trusted context, and do not use stale OwnTracks as current location. Name a neighborhood/city in the query even with coordinates.
- `--dry-run` previews without a live request. `--out-dir` preserves a named artifact bundle. `--timeout` defaults to 180s.
- Auth uses `GEMINI_API_KEY` (or `GOOGLE_API_KEY`) from the environment. Never print credentials or pass them in CLI arguments. Uses the Gemini Developer API; billing and quotas apply.
- Calls set `store:false`. Raw JSON can still contain private query details: keep local and do not publish it.

Direct equivalent for advanced use:

```json
{"input":"Your query","tools":[{"type":"google_maps","latitude":37.7599,"longitude":-122.4269}],"store":false}
```

Run `gemini-api generate --body @request.json --stream=false --output-format json`. To add Search, add `{"type":"google_search"}` to `tools`. Do not put `stream` in the body as well as the CLI flag (duplicate keys fail). The response uses `steps`, not `outputs`: extract `model_output` text and its `place_citation` / `url_citation` annotations. Keep raw results for evidence, but never dump thought steps or opaque signatures into chat.

## Grounding policy, informed by paired tests

**Maps-only by default:** evergreen taste/vibe, dishes, nearby cafes, romantic restaurants, neighborhood discovery, walkable itineraries. A special occasion alone does not require Search: "romantic anniversary dinner" can be Maps-only.

**Add Search when a current/date-specific fact could change the recommendation:**
- Dated events, performances, festivals, seasonal experiences or special holiday menus.
- Recent openings, closures, renovations, ownership changes.
- Official policies: laptop rules, accessibility, age restrictions, minimum spend, cancellation terms.
- Exact product inventory, current menus/prices/packages, or an explicitly requested official booking link.

If Maps-only surfaces a decisive uncertain policy or closure, make a targeted Search+Maps follow-up rather than repeating an unrestricted discovery sweep. If the API rejects the combination, keep Maps, then verify current facts with web_search/official pages. Do not silently remove Maps or treat this as a reason to abandon grounded recommendations.

**Search is discovery, not verification.** Open the decisive official source; check actual year/date, terms and applicable offering. A homepage, search snippet or citation does not prove tickets are available. Use the venue/booking system for real availability. Say unknown when not verified. Check actual tool calls/grounding counts: tools enabled does not mean both were used.

Paired tests showed the same cafe winner in both modes; Search added event-specific candidates but also unsupported availability claims. This is a four-request exploratory comparison, not a general accuracy benchmark. Evidence: `references/cli-grounding-evaluation.md`.

## Recommendation quality

Read `references/recommendation-query-playbook.md` for taste-sensitive queries; apply its taste/evidence guidance, but this file overrides its older transport, model or Search defaults.

Include occasion, budget, dietary needs, area, vibe, anti-preferences and desired output shape in the query. Ask for one decisive top pick, meaningful backups and tradeoffs. Return a compact linked comparison; link every named recommendation directly to its returned Google Maps URL. No quota of unnecessary alternatives.

Separate Maps/review evidence from culinary or atmosphere inference. Purported quotes are Gemini-reported unless per-review provenance is exposed and checked. A model labeling a claim "verified" is not verification. Do not inflate a few reviews into consensus. Do not infer open-now from evergreen hours, reopening from a working reservation page, or stock from a retailer's existence. Show conflicts rather than averaging them into confident prose.

For exact restaurant/dish comparisons, name restaurants, addresses and dishes, ask for dish-specific evidence and a decisive winner. If supporting review text is unavailable, say so and label the comparison as inference. For best near home, let quality select candidates, then use direct routing to break close ties.

## Day planning and route chains

1. Check all relevant calendars, preserving creator/attendee metadata; Other attendees’ events are not necessarily the user's obligations.
2. Resolve destinations from actual calendar/context evidence; label assumptions. Do not expose home address unnecessarily.
3. Use direct Maps directions with intended departure time for each leg, not neighborhood intuition.
4. Include parking, changing, check-in and arrival buffers separately from travel time.
5. Park once and walk when stops are adjacent. Return the decisive departure time first and a compact timeline when requested.

## Retail/product sourcing

Use exact product web pages to verify stock, price, model/vintage, pickup/shipping and ordering terms. Use Maps grounding to find plausible local shops, not to claim inventory. Separate verified available listings from stores to call and sold-out/pre-arrival pages.

## Operational boundaries

Discovery does not authorize bookings, purchases, external sends or infrastructure changes. Use transactional tools only within the user's authorization. Grounding does not replace the travel/dining skills' source-of-truth and preference rules.
