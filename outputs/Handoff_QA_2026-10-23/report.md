# Midnight Food Court — QA 23 October 2026

Tested in Studio sandbox (GameId/PlaceId 0), one real local client.

## Passed
- Actual Thai Tea cook/timing/serve: Perfect 98/100. Client Pour sound loaded and played; Sizzle did not overlap.
- Courier: real player used delivery prompt; simulated kitchen owner. Lowest-stock target selected, +3 back stock, +25 Coins, duplicate pickup/delivery denied. Original runtime state restored.
- Quests/Login/Legend: 11 automated server checks passed: deterministic unique dailies, unfinished claim denied, capped progress, daily/weekly payout once, day-7 login 250 Coins +15 Gems once, missed-day reset, daily/weekly rollover, star boundaries/cap, star reward once and increased meal value. Date rollover simulated with profile data.
- Sandbox rankings: personal totals 217 lifetime/17 weekly and refreshed server ranking matched. Profile restored.
- Snapshot: full 11714 bytes; lightweight 3419 bytes. Cooking command immediately after Snapshot was not rejected by Snapshot rate limiter.
- Virtual touch layout: crew and timing panels did not overlap at 844x390, 852x393, 915x412, 390x844.

## Defect found and fixed
MidnightGameplay assigned boolean false to Highlight.Adornee while ShopId=0. Changed shop lookup to return nil when no shop exists. Restarted Play and simulated client ShopId=0 for two seconds, then restored ShopId=1. No runtime errors in fresh output; only expected warning for 14 unconfigured monetization IDs.

## Usability finding
Virtual geometry gives cooking button heights ~32–34px and crew buttons ~26–27px in landscape; portrait ~21px and ~17px. These remain small. This is a virtual layout test, not a physical phone or Studio Device Emulator test.

## Not verified
- Two real clients: Kick, role assignment, co-op interaction and replication.
- Physical touchscreen interaction.
- Published cloud DataStore, cross-server OrderedDataStore, Robux purchase receipts.
- Human listening quality of sound.

Temporary QA scripts and seeded profiles were runtime-only. Play stopped after verification. Product change: only Visitor nil fix in StarterPlayerScripts.MidnightGameplay. Save the Studio file to persist that edit.

