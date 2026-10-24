# Midnight Food Court — Current handoff
Current root: D:/Roblox-game/Midnight_Food_court. Two-way script sync is now active; read SYNC.md. This supersedes the old unconnected Rojo server notes below.
Updated 2026-10-24, Asia/Bangkok. Read alongside FEATURES, CHANGELOG and TESTING.
Evidence combines the user's earlier handoff, saved QA reports, and current Studio source inspection. Historical reports describe the state at their date; this document takes precedence for current navigation.

## Identity and current state
- Main test experience: Midnight Food Court [TEST].
- UniverseId 10772566896; PlaceId 120399989321685.
- Game: https://www.roblox.com/games/120399989321685/Midnight-Food-Court
- Creator Dashboard: https://create.roblox.com/dashboard/creations/experiences/10772566896/overview
- The similarly named private experience on the Studio home screen is a different experience. Do not switch to it.
- Current Studio source inspected on 2026-10-24: 29 Lua source containers in ServerScriptService, StarterPlayerScripts and MidnightStyle.
- User previously published monetization and saw a purchase/Buy Robux popup. Latest crew interaction, held-dish replication and menu expansion edits have NOT been verified published. Saving the .rbxl file is also not verified.
- Flags on ServerScriptService.MidnightCityModules: StudioUsesDataStore=true, StudioPurchaseSimulation=true.
- Simulation overrides Studio cloud profiles; Stop + Play resets sandbox purchases. Live Roblox Player ignores this simulation flag.
- Current access/early-tester list must be read from Dashboard; do not infer it from old Private/Playtesters/Limited badges.

## Latest completed work
1. Removed Kitchen Crew popup, replaced PassMeal button with a local ProximityPrompt on eligible teammates.
   - Hold E for .25s, 7-stud range; same kitchen, empty-handed/non-cooking receiver.
   - Mobile tap / gamepad Y. Existing server validation remains authoritative.
   - Sender: Dish passed to [name]; receiver: Dish received from [name].
2. ServerScriptService.MidnightHeldDishes creates a replicated welded dish on the character from MidnightState.Held.
   - Removed the local-only world clone from MidnightCityHUD.
   - Clears/replaces on state changes, death, respawn and departure.
3. Expanded 11 themes to 6 recipes each (66 themed recipes + Signature Chicken Rice).
   - Start 3; additional dishes at restaurant levels 2/3/4.
   - Reuses existing kit categories and cooking stations; variants reuse canonical geometry.
   - Journey shows unlock levels; FeatureDish supports 6 menu indices.
   - Menu board uses 3 columns x 2 rows; station props avoid overlapping duplicate dishes.
4. MealBundles introduces main + drink sets after level 2 and training.
   - Eligible non-party main-dish visits, visit count mod 3 = 1.
   - Both items may be cooked and delivered in either order; customer waits for both.
   - One complete set counts as one served order; base reward multiplier 2.2.
   - HUD shows both items and delivered checks.
   - See outputs/Menu_Expansion_2026-10-24/report.md for test evidence.

## Source map
ServerScriptService:
- MidnightCityServer: startup, remotes/rate limits, ProcessReceipt.
- MidnightHeldDishes: replicated character-held food visuals.
- MidnightCityModules:
  - ShopService: primary shop state, game loop, cook/serve/customer/crew router and sync.
  - Profiles: persistence, copy-on-mutate, session locks, receipt idempotence, sandbox.
  - Catalog: prices/upgrades/staff/default ConfigService lookups.
  - Inventory: Front/Back/Transit, kits, restock/purchases/refunds/cancel cooking.
  - Experience: ranks, customer types/reviews/popularity, tutorial, timing, stars/goals.
  - MealBundles: set order state, pending dishes, station selection and acceptance.
  - CustomerFlow: NPC arrival/queue/party/departure.
  - StyleService, ShopSaves: cosmetics/passes/design save.
  - WorkerVisuals, PreparedMeals: NPC staff and ready meal presentation.
  - City, Transit, Courier: city life/events, bus and visitor deliveries.
  - Quests, Leaderboards: retention and rankings.
ReplicatedStorage.MidnightStyle:
- RecipeCatalog, FoodFactory, FoodDetails: canonical recipes and shared models.
- StyleCatalog, StyleRenderer, MonetizationConfig.
StarterPlayer.StarterPlayerScripts:
- MidnightCityHUD creates ScreenGui MidnightHUD; audio/order/carrying/stock/targets.
- MidnightGameplay: progression/timing/tutorial/reviews, teammate dish prompts.
- MidnightManagement: Kitchen navigation and management.
- MidnightStyleShop: purchases/equip/photo mode.
- MidnightCtrlLock: despite its legacy name, toggles with LeftShift/RightShift.

## Data and extension contracts
- Profiles.Mutate(player, callback) is required for persisted edits; it uses a copy.
- Player.MidnightState attributes drive HUD, including Held, Cooking, Order, ShopId, stock, RestaurantTier.
- New set attributes: BundleItems (pipe-separated IDs), BundleDelivered, BundleDone, OrderExtra.
- Server state shop.Bundle: Items, Done, Count, Score, Quality. MealBundles owns its transitions.
- ReplicatedStorage.MidnightNetwork: Snapshot / Command RemoteFunctions, Notice / OpenPanel events.
- ReplicatedStorage.MidnightFeedback handles audio/UI cues.
- New services can register service.CommandHandlers and service.SnapshotExtras during Start.
- Snapshot(false) omits static catalog; client caches it.
- Profile has Coins/Gems/Owned/Equipped, Shop.Bank/Stock/Upgrades/Workers/Career, Quests/Login/Stats, pack and save entitlements.

## Studio MCP pitfalls
- list_roblox_studios first; IDs are session-specific.
- execute_luau require cache differs from normally running game scripts. For actual service state use a temporary normal server Script and a BindableFunction bridge; clean up.
- Never equate fake table-player tests with real Players services or two actual clients.
- ProximityPrompt InputHoldBegin/End needs distance, camera visibility and a short settle after teleport.
- Check sounds on Client; server IsPlaying is not sufficient.
- MaxPlayers is read-only through script (configured value historically 30).
- execute_luau destruction may not be undoable through Ctrl+Z.
- Native Roblox Player capture previously failed repeatedly. Studio MCP screen_capture worked. Do not assume external Player screenshots were verified.

## Priorities for the next session
1. Test latest E give-dish interaction with two real clients, including transfer feedback and receiver-full/too-far cases.
2. Confirm replicated held dishes are seen by a second client through cooking, transfer, serving and respawn.
3. Two-client set-meal test: cook main/drink concurrently, deliver drink first, avoid duplicate payouts, verify client HUD sync.
4. Set-meal edge cases: sold-out second item, menu change, timeout, closing/reopening, blackout/shadow, party/reviewer/regular behavior, owner transfer.
5. Review all six-dish board visuals and recipe variants per theme; visual inspection so far was not exhaustive.
6. Device Emulator check of set order card and Journey cards on narrow screens.
7. Balance set payout 2.2 and unlock pacing using real player feedback.
8. Save and Publish the reviewed build; join a new server and record the exact deployed verification.
9. Paid checkout remains untested; prefer no-cost tests until user explicitly authorizes any spend.

## Documentation maintenance
After a session update current state, features, change history and test evidence. Reports under outputs are dated evidence, not automatic proof of current behavior. This documentation does not update itself outside an agent session that follows AGENTS.md.


## Repository migration — 2026-10-24
- Latest source exported into src/ (29 files) with assets/ (33 binary models), default.project.json, pinned Rojo, checksums and validation tooling.
- See DEVELOPMENT.md for the maintained filesystem workflow. Studio MCP edits must be mirrored back to disk.
- Binary/XML builds and exact source-to-build round-trip checks pass. Rebuilt file still needs separate Studio playtest.
- Original Terrain has 0 cells; Rojo warns about unsupported VoxelGridAssetContentMap. Original Terrain.rbxm retained.
- Local Git initialized on main; remote/push not configured. Commit depends on user Git identity.

## Rojo live-sync state — 2026-10-24
- Added `tools/start_rojo_sync.ps1`, which blocks on unresolved Git conflicts/conflict markers, repository verification failure or a Rojo version other than 7.7.1.
- Before serving, all 29 Studio scripts matched `src/` by path, class, normalized byte length and CRC32; the exported SHA-256 baseline and exact XML round-trip also passed.
- A Rojo server was started on localhost:34872. Studio plugin connection/change-preview acceptance remains manual because Windows capture timed out; do not claim the Studio plugin connected until its UI confirms it.
- No Save or Publish was performed.

## Two-way script sync — 2026-10-24
- Installed tools/sync_bridge.py, Studio Bridge/Bootstrap local plugin, setup/start tools, Start Development.cmd, and pre-commit/pre-push Git hooks.
- Active service at localhost:34875; active Studio bridge was bootstrapped through MCP. Source changes flow in both directions with shared-base conflict protection.
- Current 29 scripts acknowledged by Studio. Live bidirectional, conflict, hook blocking, Play pause/resume, scene warning, server restart and CMD startup tests passed.
- Persistent plugin built/installed; automatic plugin startup after a Studio restart remains unverified.
- Scene/model asset round-trip remains manual/reviewed. See SYNC.md for exact limits.
- No commit or Publish. Original export EOF blank lines were canonicalized, so historical --baseline hashes are not the current code baseline.
