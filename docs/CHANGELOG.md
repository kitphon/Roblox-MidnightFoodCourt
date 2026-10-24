# Change history

## 2026-10-24 — Guarded two-way source synchronization
- Added localhost bridge and local Studio plugin, shared-version reconciliation, recovery copies, conflict refusal and atomic editor updates.
- Added fresh Studio audit and Git index checks to pre-commit/pre-push hooks; pause during Play and detect scene edits during active session.
- Added one-click Python/CMD startup and authenticated server restart, without changing PowerShell execution policy.
- Live Studio/file exchange and conflict tests passed; QA changes restored. No gameplay logic change or publication.
- Source EOF/line endings canonicalized; old migration checksums remain historical.
Updated 2026-10-24. Earlier entries summarize the user's handoff and dated QA reports, not every historical edit.

## 2026-10-24 — Menu expansion
- Six recipes per theme; extra recipes unlocked at levels 2/3/4.
- Added MealBundles; concurrent station work and food/drink delivery in either order.
- Combined set completion/payout, duplicate-item rejection, dual-icon/checkmark Order HUD.
- Journey locked recipes and six-position house special selection.
- Six-item menu board, one station display per ingredient category.
- Evidence: outputs/Menu_Expansion_2026-10-24/report.md.
- Not verified published.

## 2026-10-24 — Co-op interaction and visible carried dishes
- Removed Kitchen Crew panel and replaced transfer with E/.25s/7-stud teammate prompts.
- Added sender and receiver confirmation.
- Added MidnightHeldDishes server Script; removed local-only world dish clone from HUD.
- Held-dish checks covered 34 pre-expansion recipes, server-to-client replication and clearing. Full two-client test pending.
- Not verified published.

## 2026-10-24 — Menus and controls
- Simplified management and shop navigation; merged Saves/Ranks/City functions into existing sections.
- Prominent Shop/Gems shortcuts, clear Equip/Unequip states and ownership badges.
- Added camera mouse lock; final toggle is Shift, though script name still MidnightCtrlLock.
- Evidence: outputs/Menu_Consolidation_2026-10-24/report.md, outputs/Shop_UX_2026-10-24/report.md, outputs/Ctrl_Lock_2026-10-24/report.md.

## 2026-10-23 to 2026-10-24 — Monetization and persistence
- Created/configured 11 passes and 3 Gems products.
- Isolated Studio simulation for no-cost fresh purchase-state testing; real Player ignores sandbox flag.
- Verified synthetic cloud save/reload and receipt-idempotence logic.
- User reports publishing and seeing a real purchase popup; no paid purchase made.
- Evidence: outputs/Monetization_Setup_2026-10-23/report.md, outputs/Studio_Purchase_Simulation/report.md, outputs/Cloud_Save_QA_2026-10-23/report.md.

## Earlier implementation and hardening
- Built 4-shop co-op restaurant loop, world/city, workers, supplies, mall/transit, themes/cosmetics, Save Slot.
- Fixed radio/fusebox positioning, cooking messages, NPC overlap/flow, backroom access, stock shortage handling, UI layout and food models through iterative user feedback.
- Added special customers, reviews, Riley friendship and Dinner Party behavior.
- Separated Command/Snapshot rate limits; per-shop loop error isolation; profile load retries and deep copy.
- Implemented owner succession, ingredient refunds, role perks and kick cooldown.
- Added quests/login, stars/leaderboards, courier jobs and audio.
- Five-client QA found/fixed owner-departure persistence removal error.
- Mobile QA adjusted HUD, cooking/crew touch targets, tutorial spacing and scrolling.
- See TESTING.md for dated evidence and limits.

## 2026-10-24 — Handoff documentation
- Added root README, AGENTS and centralized HANDOFF/FEATURES/CHANGELOG/TESTING.
- Verified current place identity, sandbox flags and 29-script inventory through Studio MCP.


## 2026-10-24 — Git/source migration
- Exported all 29 scripts plus 33 scene/asset models directly from confirmed Studio Edit place.
- Added Rojo project, pinned local bootstrap, manifest/checksums, verifier, Git ignore/attributes and development workflow.
- Built binary/XML place and verified all sources round-trip at original class/path; no gameplay code changed.
- Git initialized locally; no remote or push. Separate Studio build playtest pending.

## 2026-10-24 — Guarded Rojo live sync
- Added `tools/start_rojo_sync.ps1` to stop before serving when Git has unresolved conflicts, conflict markers are present, repository validation fails, or the pinned Rojo version is not 7.7.1.
- Added an optional `-RequireBaseline` check for sessions that expect the original Studio export to remain byte-identical.
- The launcher leaves Studio change-preview acceptance manual so out-of-sync changes are not applied silently.
- No Save or Publish was performed.
