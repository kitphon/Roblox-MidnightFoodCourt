# Test evidence and remaining verification

## Two-way bridge — 2026-10-24
- 11 automated filesystem/Git-index reconciliation tests passed.
- Actual Studio: disk→Studio, Studio→disk, conflict refusal with both versions preserved, recovery and fresh audit passed.
- Actual pre-commit blocked on conflict, then pre-commit/pre-push passed after cleanup.
- A main-repo temporary-index test could not stage due sandbox object-database permissions; stale-index rejection was instead verified in an isolated real Git repository.
- Actual Play pause/Stop resume and reversible scene-edit guard passed.
- CMD launcher and Python server restart passed; no execution-policy setting altered.
- Final Rojo XML build and all 29 source round-trip checks passed; known Terrain warning unchanged.
- Persistent plugin restart-autoload not verified. Full scene/asset equality remains outside script sync.
- No gameplay-profile persistence, paid purchase, Git commit or Roblox Publish performed.
Updated 2026-10-24.

Reports are historical evidence. New changes can invalidate earlier results; read each report's scope. Compilation is not gameplay verification, sandbox grants are not paid checkout, and one client is not multiplayer.

| Evidence directory under outputs/ | Scope |
|---|---|
| Handoff_QA_2026-10-23 | Cooking/pour, quests, courier, stars/ranks and initial checks |
| Readiness_2026-10-23 | Touch controls, guards, save/design/receipt-related checks |
| Coop_5Clients_QA | Five actual Studio clients, 41 assertions, roles/pass/kick/Visitor/cook/serve/owner succession |
| Device_Emulator_QA_2026-10-23 | Phone/tablet layout issues identified |
| Mobile_UI_Fixes_2026-10-23 | Responsive HUD and touch layout fixes |
| Cloud_Save_QA_2026-10-23 | Isolated real Studio DataStore fixture persistence/idempotence; fixture cleaned |
| Auto_Gameplay_Save_QA | Actual client cook/serve, two Studio sessions and save reload; restored test profile |
| Monetization_Setup_2026-10-23 | Marketplace metadata checks for 14 configured items, not paid fulfillment |
| Studio_Purchase_Simulation | 14 free sandbox command checks and fresh-session reset |
| Shop_UX_2026-10-24 | Store UI/ownership/equip presentation |
| Menu_Consolidation_2026-10-24 | 38 navigation/catalog/wiring checks; selected screenshots |
| Ctrl_Lock_2026-10-24 | Shift camera toggle and focus/modal-related controls; note test clone differences |
| Menu_Expansion_2026-10-24 | All themes/unlocks/recipe icon references; bundle logic; real single-client cooking/serving set |

## Latest checks
- Latest source set: 29 scripts compiled in Edit mode.
- Six recipes in all 11 themes; valid stations/stocks/icons, level counts 3/4/5/6.
- Pure bundle state tests: either order, partial completion, duplicate rejection and clear.
- Actual sandbox cook/serve: Pork Dumplings + Lemon Iced Tea. Bank 500 stayed 500 after first item, became 575 after second; Served 1; relevant Front stocks each 3→2.
- Confirmed client receives set names/icons; six board models present; screenshot inspected.
- Crew panel absent and gameplay UI loads.
- Replicated held model reached a client; clearing worked. Second-client visibility still pending.
- No new errors observed during latest play; ConfigService missing-key warnings remain.
- Temporary latest QA bridge/script removed by stopping Play.

## Next checks (not completed)
- Two real clients for E transfer and visible held dishes, including empty/full hands, distance, death and respawn.
- Two real clients cook different items concurrently and deliver in both orders; one payout only.
- Set shortage/menu alternative, timeout, cancellation/reopen, special NPCs/events and owner succession.
- Device Emulator for new set card and six-recipe Journey.
- Per-theme visual QA of all new variants and expanded board.
- Live deployed build validation after Publish/new-server join.
- Real Robux receipt/pass purchase flow remains untested; do not spend without authorization.
- Real phone hardware and cross-server leaderboard behavior.

## Safe testing modes
- Free Studio purchases: StudioPurchaseSimulation=true. Stop + Play resets.
- Studio DataStore QA: turn simulation off, keep StudioUsesDataStore=true, use isolated fixtures and restore/clean them.
- Live Player: simulation flags do not grant free paid items.
- Never use an owner's automatic pass ownership as proof of first-time purchase fulfillment.
- Do not disable server purchase/ownership checks merely to make a UI test pass.
- Multiplayer changes should get actual multi-client tests; mocks cannot prove replication.


## Repository export/build — 2026-10-24
- Confirmed PlaceId/UniverseId before read-only export.
- Exported 29 scripts and 33 assets; validated 62 mapped file paths and binary model headers.
- Rojo 7.7.1 binary and XML builds succeeded; source text/classes/paths match for every script.
- Terrain CountCells=0; unsupported VoxelGridAssetContentMap warning documented in DEVELOPMENT.md.
- Separate Studio session playtest of generated build NOT performed. Existing gameplay results refer to original place.
- Migration details: outputs/Repository_Migration_2026-10-24/report.md. SHA-256 checksums also verified; staging is blocked only in agent environment by .git/index.lock permissions.

## Rojo live-sync preflight — 2026-10-24
- Environment: filesystem validation plus the connected Studio Edit DataModel; no Play session and no publication.
- Confirmed PlaceId 120399989321685 and UniverseId 10772566896, Studio PlaceVersion 16.
- Baseline SHA-256 validation passed for 29 scripts and 33 binary assets; 62 Rojo paths were present.
- XML build succeeded in `.codex-preflight/`; all 29 sources round-tripped with exact normalized text, class and path. The documented Terrain `VoxelGridAssetContentMap` warning remains.
- Compared all 29 maintained Studio scripts with repository files using normalized byte length and CRC32; every path/class/content matched before starting `rojo serve`.
- Rojo 7.7.1 server started on localhost:34872. Automated Studio-window capture timed out twice, so plugin connection/change-preview acceptance was not claimed or automated.
- No gameplay, multiplayer, paid checkout, Save or Publish test was performed.
