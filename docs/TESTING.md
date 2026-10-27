# Test evidence and remaining verification

## Sync audit — 2026-10-27
- Environment: connected `Midnight Food Court [TEST]` Studio, Edit mode (Play already stopped). Confirmed PlaceId 120399989321685 / UniverseId 10772566896.
- Scripts: bridge `synced`, pending [], all 29 acknowledged. First check hit `paused-play` just as Play ended; re-check found only the scene guard.
- Scene: SceneDirty=true. Exported all 33 mapped Edit assets to `.sync/scene-review/assets` (old staging moved to `assets.prev-20261027`; MidnightCityModules exported with scripts stripped), receiver stopped. Normalized compare vs `assets/`: **0 differences** — no scene asset change to promote.
- Rojo .rbxl/.rbxlx build + `verify_repository.py --xml` OK (29/33/62).
- **Checkpoint incomplete:** clearing the plugin SceneDirty flag via MCP was denied by the tool permission classifier, so `sync_bridge.py check` still reports the scene commit guard. Remaining step: user acknowledges SceneDirty (review shows 0 differences) or restarts the bridge per SYNC.md. No source/assets changed. No Save/Publish.
- Follow-up after the user restarted Studio + bridge (new Studio connection ID): the fresh session reported SceneDirty=false, then true again within ~1 minute with no user-reported edit. Re-exported all 33 assets (old staging kept at `assets.prev-20261027b`): **0 differences**. A read-only 15 s Changed/AttributeChanged/DescendantAdded/Removing probe over all watched asset roots (11,820 hooks) saw 0 changes, so the flag likely came from a one-time load-time property event (e.g. asset/sound load), not a scene edit — cause not confirmed. Check still blocked only by the SceneDirty guard; scripts synced (29), no pending/conflicts. No Save/Publish.

## Waiter role bonus + kick block expiry — 2026-10-27
- Environment: same 5-player Studio Local Server (sandbox), Shop1 owner Player1. Temporary server Script wrapped `Experience.Reward` in memory to record the pre-role amount; the wrapper was removed and the original function restored and confirmed (`rewardRestored=true`). Local multi-client Studio test, not a live server.
- Kick block expiry: Player3's ban in Shop1 had expired (-154 s) → `Join` 1 succeeded ("Joined shop 1", Role Crew).
- Waiter role: owner assigned Player2 Waiter. Player2 cooked and served Thai Tea via the real prompts: pre-role 49 → total 53 (+floor(4.9)=4, LastSale.Total 53). Player4 (Technician role) served Thai Tea: 50 → 50 (no bonus). Server errors: 0.
- Not tested: live server, real phones (both need a Publish and real devices/accounts).

## NPC workers, crew roles, full shop, lock/kick — 2026-10-27
- Environment: Studio Local Server, sandbox asserted, server Source contained the crew lock. Part A ran on the 4-player server after the owner handover (Player2 owner, Player3/4 crew); that server was replaced mid-test by a new 5-player Local Server (Player1-5), where Part B ran. Temporary server QA Scripts removed; client QA code in-memory and cleaned up. Local Studio multi-client test, not a live server.
- Hiring (owner Player2): Chef -$300, Waiter -$250, Technician -$350 through the normal `Hire` command (bank 2000→1100); a second Chef hire → "Already hired"; crew Hire → "Owner only"; Employees models Chef/Waiter/Technician spawned.
- NPC-only shift (no player input, 90 s server monitor): chef prepared the correct dish for 4/4 orders, the waiter served each ~6 s later (served +4), the technician cleared BLACKOUT after 8.2 s, 0 strikes.
- Crew roles: owner assigned Player3 Chef and Player4 Technician; bad role → "Unknown role", self → "Crew member not found", crew assigning → "Owner only". Chef role cook: CookDuration 2.4 s (3 × 0.8), dish held after ~2.3 s; served normally. Technician role (5-player server): Player4 repaired BLACKOUT via the real FuseBox prompt → event cleared, shop funds 2000→2015, notice "Technician repair bonus • +$15 shop funds".
- Full shop / visitor: with 4 owners, Player5 started as Visitor (shop 0). After Player2-4 joined Shop1 (4 members), Player5 `Join` 1 → "Shop is locked or full"; Player5 `Home` → "Your shop is ready", Owner of freed Shop2.
- Leave/lock/kick: crew `Leave` → Visitor in the city with guidance text. Owner `Lock` → Player4 `Join` refused "Shop is locked or full"; unlock → join succeeded. Owner `Kick` Player3 → "Player3 removed for 5 minutes"; Player3 became Visitor at the city, rejoin refused "The owner removed you from this kitchen. Try again in 5 min."
- The 1 strike in the 5-player shift came from an order left uncooked while the test waited for an event (no players cooking). Server LogService: 0 errors.
- Not tested: kick-ban expiry after 5 minutes, Waiter role +10% value check, live server, mobile.
- Checkpoint: no source/asset changes in this step; bridge `synced`, no pending, sceneDirty=false; commit guard still stops at the older staged StyleRenderer copy in the Git index. Local Server windows left open for the user. No Save/Publish.

## Four-player crew, NPC Chef with the crew lock, owner disconnect — 2026-10-27
- Environment: user-started Studio Local Server; 4 clients connected (Player1-4, although 3 were requested). Server Source contained the crew lock; `Profiles.Sandbox=true` asserted. Temporary server QA Scripts (seed/probe/monitor) removed; client QA code in-memory only and cleaned up. Local multi-client Studio test, not a live server.
- 4-person crew: Player2-4 `Join` 1 → Crew (shop full at 4; a fifth join could not be tried with 4 players). All four autoplayers raced every order (serve only a matching held dish). Shift `Won`: 28 served, 0 strikes, 0 client/server errors. Cooks per player 11/8/6/4; lock refusals 27/35/25/37. A 60 s server monitor sampling every 0.1 s (545 samples) found no moment where two members cooked/held the current order's dish at once.
- NPC Chef: hired by the owner through the normal `Hire` command (sandbox shop funds -$300). During the 4-player race the chef made 0 dishes because a player always started the order first (chef interval 9 s). With bots paused: the chef also waited while a crew member was holding the order dish and during SHADOW (correct, `mealInProgress`). New shift: Player2 cooked and held Chicken Rice for 14 s and the chef made no duplicate. After serving, the chef prepared Thai Tea alone; Player3's Cook prompt at that station picked it up (Held=THAI TEA, Prepared cleared, FrontTea unchanged 4→4, no stock used) and serving it gave served 2, 0 strikes.
- Owner disconnect: server `Player1:Kick()` (closed Player1's client). Shop1 passed to Player2 (earliest crew join), Player3/4 stayed Crew, phase reset to Ready, sign became "PLAYER2'S KITCHEN", crew got "Player2 now owns this kitchen. Open the shop when ready." Player2 could open/close the shop; Player3 `ToggleShop` → "Owner only". Server errors: 0.
- Observation (not changed): shops abandoned when their owners joined Shop1 show phase `Lost` while unowned even though no shift was running there; a new claim resets them to Ready.
- Not tested: a fifth player joining a full shop, Waiter/Technician workers, live server latency, mobile, rejoin after kick ban.
- Checkpoint: no source/asset changes in this session step; bridge `synced`, no pending. sceneDirty became true again around the Local Server run; fresh 33-asset export vs `assets/`: 0 differences, verify_repository OK (29/33/62); sceneDirty left for the user to acknowledge; commit guard still stops at the older staged StyleRenderer copy in the Git index. Local Server windows left for the user to close (Player1's window closed by the kick). No Save/Publish.

## Crew cooking lock — 2026-10-27
- Change: ShopService `cook()` refuses to start the current order's dish when another shop member is already cooking or holding that dish (notice "<Name> is already making <Dish> for this order"); checked before `Inventory.Consume`, so no stock is used. Non-order dishes can still be cooked ahead. Synced to Studio and confirmed in the Edit Source before testing.
- Environment: user-restarted Studio Local Server, 2 clients (Player1 owner, Player2 crew via `Join`), server `Profiles.Sandbox=true`, server Source contained the lock. Temporary seed Script removed; client QA code in-memory only. Local 2-client Studio test, not a live server.
- Step test: order Fried Rice (B). Player1 started cooking; Player2's real Cook prompt at B was refused with the notice, Player2 Cooking/Held stayed empty, FrontRice stayed 2 (only Player1's portion used). Refused again while Player1 held the finished dish (Player2's client saw Player1's MidnightHeldDish = FRIED RICE). After Player1 served (set meal 1/2), Player2 cooked the second item Lemon Iced Tea, and Player1 at F was refused ("Player2 is already making Lemon Iced Tea..."). Player1 could still cook Noodles ahead while the order was Lemon Iced Tea.
- Race test (both autoplayers chase every order; they serve only a held dish that matches the order): shift `Won`, 24 served, Strikes stayed at 1 for the whole race (that strike came from an order that timed out during the step test, before the race). Lock refusals: Player1 28, Player2 11; no duplicate dishes. The pre-cooked Noodles was served when a Noodles order arrived. Compare the same race without the lock earlier today: strikes built up and the shift ended `Lost`.
- Server LogService: 0 errors. Rojo build + verify_repository OK (29/33/62). Bridge `synced`, no pending, sceneDirty=false; commit guard still stops at the older staged StyleRenderer copy in the Git index. No Save/Publish.
- Not tested: 3-4 crew members, Chef worker together with the lock, owner-disconnect heir transfer, live server latency, mobile.

## Multiplayer: Studio Local Server, 2 players — 2026-10-27
- Environment: user-started Studio Test > Local Server with 2 clients (Player1 uid -1, Player2 uid -2), PlaceId 120399989321685, `Profiles.Sandbox=true` asserted on the server. MCP reached the server and both client windows separately. Temporary server QA Scripts (removed) used `Profiles.Mutate` to skip the tutorial for both players and set Player1 to tier 4; client autoplayers were in-memory `_G` only. This is a local 2-client Studio test, NOT a live Roblox server, real devices or network latency.
- Two owners, two shops at once: each player auto-owned a shop (Shop1, Shop2). Both opened with the real bell prompt and played simultaneously: Shop1 (Lv.4) served 5, Shop2 (Lv.1) served 3 within ~60 s, 0 strikes, 0 errors; each player received only its own shop's notices.
- Crew join and permissions: Player2 `Join` 1 → Role=Crew, teleported into Shop1, Shop1 members Player1+Player2. Crew `ToggleShop`, `Lock` and `Kick` were rejected with "Owner only". Player2's abandoned running shift in Shop2 ended as `Lost` and the shop was released (by design; a new claim resets it to Ready). Owner `Leave` is rejected ("Join another kitchen to release your shop").
- Uncoordinated crew (both autoplayers chase the same order): no script errors; shop served 12 orders, both members cooked, refilled and handled events (crew cleared WHISPER/SHADOW). Both players can cook the same order at once — nothing reserves an order or station for one cook — so a leftover duplicate dish stays in hand, and serving it to the next customer is a wrong dish (strike + customer leaves, by design). With this bot behaviour the shift later reached 5 strikes and ended `Lost` while the bots were paused.
- Coordinated crew (Player2 cooks/refills and `PassMeal`s to Player1, who serves and handles events): 6/6 PassMeal succeeded, Player1 served each one; set meal 1/2 → 2/2 flow, Dinner Party and BLACKOUT handling worked. Each client saw the other player's `MidnightHeldDish` (FoodId MK_LEMON_TEA, THAI TEA, MK_CHICKEN_RICE), so held-dish replication works. 2 strikes in this run came from the test bot reading the old order after a set meal changed items (cooked a second Chicken Rice) — a bot timing artifact.
- Server LogService: 0 errors. Not tested: ownership transfer to the crew member when the owner disconnects or joins another kitchen (would need closing a client window), 3–4 player crews, Kick of a real crew member, mobile clients, live server/latency, shared-profile persistence (sandbox).
- Checkpoint: Edit DataModel untouched by the Local Server; bridge `synced`, no pending, sceneDirty=false; no source/asset changes. Local Server windows were left open for the user to close (MCP Stop did not close them). No Save/Publish.

## Lv.4 shop + other themes (single-client Play) — 2026-10-27
- Environment: connected `Midnight Food Court [TEST]` Studio, PlaceId 120399989321685, Studio sandbox (`Profiles.Sandbox=true` asserted), ONE desktop client. Temporary server QA Scripts (removed) used `Profiles.Mutate` to set TutorialStep 6, Career.Served 60 (tier 4 "Midnight Landmark", MenuLevel 4) and later the equipped theme + front/back stock refill; no source/asset changes. Client autoplayer (in-memory `_G`, removed by Stop) used the real ProximityPrompts (bell, Cook, Serve, FuseBox/Radio/Ward) plus `CookSkill`/`TakeStock`/`FillStock` through the normal Command remote. Customers/orders spawned by the game itself (not seeded orders).
- Default theme Lv.4: board screenshot shows top row Lemon Iced Tea / Chicken Rice / Pork Dumplings (F E D) and bottom Thai Tea / Fried Rice / Noodles (C B A); all six Cook prompts enabled with matching labels. Shift 1: `Won`, 9 served (4 at F), 3 strikes caused by test-tool downtime while diagnosing. Shift 2: 16 served, 0 strikes, Perfect grades; D (Pork Dumplings) x4, E (Chicken Rice) x3, F x3 plus A/B/C cooked and served; backroom refill for MK_DUMPLINGS at D worked; then closed with `OUT OF STOCK` once all stock was used (correct behaviour).
- Cozy Cafe (Lv.4): theme walls/lamps, "COZY CAFE MENU" board and station labels all match (F Strawberry Milkshake, E Cafe Cheeseburger, D Gingerbread Cookies, C Cafe Latte, B Club Sandwich, A Croissant). The shift resumed from the earlier OUT OF STOCK close (156 s left, by design) and finished `Won`, 17 more served, 0 strikes; A/B/C/E/F cooked+served, D got no order. Visual issue confirmed: station gear is still noodle pot/wok/tea bar (burger on a wok) — the known theme-specific gear item.
- Japanese Night and Space Bistro (Lv.4): screenshot check only — "MIDNIGHT RAMEN" / "COSMIC MENU" boards, theme wall colours and all six station labels/dish models matched board order. No shift played.
- Test-tool finding (not a game bug): after a scripted camera, the default camera stopped following teleports, so ProximityPrompt selection used the stale camera and the bell/Cook holds did not fire. Fixed in the QA tool by moving a scripted camera with each teleport.
- Server LogService: 0 errors (ConfigService missing-key notices and the installed plugin's HttpEnabled message only).
- Checkpoint: Stop; 33-asset export vs `assets/`: 0 differences; verify_repository OK (29/33/62); bridge `synced`, no pending. `sync_bridge.py check` still stops at the older staged StyleRenderer copy in the Git index. No Save/Publish.
- Not tested: multiplayer (needs a Studio Local Server with 2+ players started by the user), Lv.5/Legend stars, Signature Rice menu, the other 7 themes in Play, phone layout at Lv.4, live server.

## Shelf signs + menu board order — 2026-10-27
- Main-session review after the subagent: Edit Source contained both changes; Play screenshots confirmed menu cards Thai Tea / Fried Rice / Noodles above stations C B A (A rightmost) and backroom signs above the racks with ingredients visible. That review Play/Stop set the bridge SceneDirty again; re-export of all 33 assets vs `assets/`: 0 differences. SceneDirty left for the user to acknowledge.
- Environment: Studio Play (sandbox, single client), PlaceId 120399989321685 / UniverseId 10772566896, Shop1 Lv.1 default theme. Scripted client camera, ScreenGuis hidden.
- Sync note: Studio had been reopened (new studio id) and the local sync server was not running. Before starting it, every Studio script was compared against `.sync/base.json` (all 29 equal; only the 3 edited files differed on disk). Started `tools/start_sync.py`; the installed plugin still fails (`HttpEnabled` / lacking capability LocalUser), so a fresh bridge session was bootstrapped through MCP from repo `Bridge.luau` + `.sync/plugin-config.json` (bundle served once from a temporary localhost server, token not printed, HttpEnabled restored). Each edit was confirmed in Studio `Source` before Play.
- Backroom (all 4 shops, server measurement): rack top 7.79, shelf signs 8.08–10.13, INGREDIENTS header 11.30–12.90, roof bottom 13.00 — no overlap. Screenshots from the aisle (eye ~6.5) and from a higher third-person angle: signs above the racks and readable, noodle sacks / vegetable crates / tea jars fully visible, INGREDIENTS header visible above the signs. An intermediate attempt (signs at the back of the rack top) was rejected because the top deck hid the dish-name line from eye height.
- TakeStock prompts on StockNoodles/StockRice/StockTea exist and Enabled=true in all 4 shops.
- Menu board: screenshot from the dining side shows cards Thai Tea, Fried Rice, Noodles left→right with Stations C, B, A on the right side of the counter (F, E, D locked on the left). Lv.2+ checked by building the board on a temporary ServerStorage probe model (MenuLevel 1/2/3/4/5/10/99, removed afterwards): Lv.2 top row D on the right; Lv.4+ top row Lemon Tea, Chicken Rice, Dumplings (F E D), bottom row Thai Tea, Fried Rice, Noodles (C B A). Real Lv.2+ shop not played.
- Output: no script errors (only existing ConfigService missing-key notices and the installed plugin's HttpEnabled message).
- Checkpoint: Play stopped; scripts `synced`, pending [], sceneDirty false (fresh bridge session); Rojo build + `verify_repository.py --xml` OK (29/33/62); 33-asset export vs `assets/` **0 differences**. `sync_bridge.py check` stops at the existing commit guard "Staged source differs from Studio: StyleRenderer.luau" (Git index holds an older staged copy; staging not touched). No Save/Publish.

## Guide/task card gap — 2026-10-27
- Emulator Play 685×338, touch: screenshot shows ~15 px between the guide and OPEN SHOP card; the card's right edge stays left of the jump button; KITCHEN above jump unchanged.
- Process note: the first Play started before the bridge had pushed the edit into Studio (running client source still had `.4+8`); the status file's disk hashes are not proof of the Studio push. Verified Edit `Source` contained the change, then replayed. Check Studio source before Play after edits.
- Checkpoint: scripts `synced`, pending []; Rojo build + `verify_repository.py --xml` OK (29/33/62); 33-asset export vs `assets/` **0 differences**. SceneDirty still set. No Save/Publish.

## Larger phone text — phone verified 2026-10-27
- User-started Play with Device Emulator: 685×338, TouchEnabled=true, guide UIScale 1.34, KITCHEN at (1,-16,1,-102). Screenshot: guide and OPEN SHOP card text clearly larger and readable; KITCHEN above the jump button; thumbstick ring visible; OPEN SHOP card right of the thumbstick zone and left of jump.
- Observations: guide and task card now sit edge-to-edge (≈2 px gap) and the guide's left part still lies over the dynamic-thumbstick zone near the ring. Cosmetic; not changed.
- No code changed in this check. Play stopped afterwards for the checkpoint.

## Larger phone text — 2026-10-27 (phone render not verified)
- MCP-started Play did not pick up Device Emulator twice (1630×761, TouchEnabled=false). Desktop screenshot confirms the non-touch layout is unchanged (KITCHEN [M] bottom-left, guide below stock card, task card bottom-centre) and no new Output errors.
- Phone check pending: needs a user-started Play with the emulator on (earlier pattern that worked). Expected at 685×338: guide/task text at ~.71 effective scale (was ~.53), task card ~256×70 px right of the thumbstick zone, KITCHEN above jump.
- Checkpoint: scripts `synced`, pending []; Rojo build + `verify_repository.py --xml` OK (29/33/62); 33-asset export vs `assets/` **0 differences**. SceneDirty still set. No Save/Publish.

## KITCHEN button on touch — 2026-10-27
- Environment: Studio Device Emulator phone (685×338, TouchEnabled=true; emulator also reports keyboard/mouse), single client. TouchGui: DynamicThumbstickFrame covers the left 40% / lower two-thirds; JumpButton 70px at (1,-95,1,-90).
- Result: button text "KITCHEN", 124×40 at (1,-107,1,-24) anchor (1,1); screenshot shows the thumbstick ring unobstructed bottom-left, KITCHEN left of the jump button and right of the OPEN SHOP action card, guide beside the stock card.
- Not tested: tapping the button on the emulator/real device (Activated wiring unchanged), cooking-active and portrait positions, Thai locale, desktop after the change (non-touch path only switched to name lookup).
- Checkpoint: scripts `synced`, pending []; Rojo build + `verify_repository.py --xml` OK (29/33/62); 33-asset export vs `assets/` **0 differences**. SceneDirty still set. No Save/Publish.

## Phone emulator verification — 2026-10-27
- User started Play manually with Device Emulator on: viewport 685×338, TouchEnabled=true, mobile thumbstick/jump visible. MCP-started Play also picked up emulation later in the session (685×338).
- First fix failed visually: a red marker parented to the guide rendered over the stock card while MCP-read AbsolutePosition claimed it was beside it — AbsolutePosition across ScreenGuis is not trustworthy under emulation. Reworked to canvas math (see CHANGELOG); after Stop/sync and Play, the screenshot shows the guide to the right of the stock card with rows A/B/C all visible.
- Remaining phone UI observations (not fixed): KITCHEN [M] button covers the left thumbstick ring and still shows the keyboard hint; small body text in guide/OPEN SHOP cards; portrait, cooking timing button and mall/management windows not checked.
- Desktop after the canvas rework not re-captured (emulator stayed on); by the same canvas math desktop 1630×761 keeps the guide below the stock card (guide top ≈455 vs card bottom ≈452 canvas units, a narrow margin).
- Checkpoint: scripts `synced`, pending []; Rojo build + `verify_repository.py --xml` OK (29/33/62); 33-asset export vs `assets/` **0 differences**. SceneDirty still set. No Save/Publish.

## Phone re-check attempt — 2026-10-27 (blocked)
- User re-enabled Device Emulator; an MCP-started Play still reported ViewportSize 1630×761 for 5 consecutive seconds (TouchEnabled=false), so the guide/stock-card fix could not be confirmed at phone size. Desktop layout unchanged (guide y 483 below stock bottom 472). Suspected cause: emulation not applied to MCP-started Play sessions or reset on Play start; next try: user starts Play manually with the emulator on, then inspect via MCP. No changes.

## Phone Device Emulator check — 2026-10-26 (partial)
- Second attempt: Play client reported ViewportSize 732×448 (landscape phone size) but TouchEnabled=false and no TouchGui, so touch-only layout code (`layoutTouch`, thumbstick) did not run. Two screenshots were captured before emulation switched back to 1630×761 mid-session (cause unknown; possibly the scripted camera/MCP camera reset).
- Phone-size findings: storefront awning/lights/backdrop decor read fine; the FIRST-SHIFT guide card overlapped the FRONT / BACK stock card (C row hidden); KITCHEN [M] button is large relative to the screen and still shows the keyboard hint; small body text (guide instruction, OPEN SHOP subtitle) is near the readability limit.
- Fix: guide now moves beside the stock card when they would overlap. Desktop 1630×761 re-checked: guide at y 483 below stock card bottom 472, unchanged. **Not re-verified at phone size** because emulation was off.
- Not tested: real touch device/thumbstick overlap with the bottom-left KITCHEN button and guide, portrait, cooking timing button on touch, mall/management windows at phone size.
- Checkpoint: scripts `synced`, pending []; Rojo build + `verify_repository.py --xml` OK (29/33/62); 33-asset export vs `assets/` **0 differences**. SceneDirty still set. No Save/Publish.

## Phone Device Emulator attempt — 2026-10-26 (blocked)
- User reported switching Studio's Device Emulator to a phone, but both the Edit and Play client camera reported ViewportSize 1630×761 with TouchEnabled=false, KeyboardEnabled/MouseEnabled=true and no TouchGui; the Play screenshot showed the desktop layout. Emulation was therefore not active in the viewport MCP reads, so no phone look/UI result was recorded. No source/asset changes; Play stopped.

## Decor performance / phone-size check — 2026-10-26
- Environment: connected TEST Studio, single-client Play on the developer PC (60 FPS cap). No phone, Device Emulator or low graphics-quality run: Device Emulator cannot be switched through MCP and Studio quality settings were not changed. The Studio viewport (~2.14:1) roughly matches phone-landscape framing, but UI scale/text size on a real phone was not checked.
- Inventory: workspace 5,484 parts (StreamingEnabled=true); decor added today ≈2,200 parts (StationGear 560, Trees 519, TownDetail 396, MallInterior 319, Storefront 232, citizens 261 vs ~84 before), 21 extra PointLights (90 total, 0 with shadows), 755 Neon parts, 33 emitters.
- Render cost, decor shown vs hidden on the client (2 s samples): town 4.05/1.12 vs 4.55/1.51 ms CPU/GPU, mall 4.02/1.22 vs 3.94/1.43, kitchen 4.42/1.65 vs 4.47/1.61, shop row 5.76/2.18 vs 4.71/1.79 (largest delta). Chase-light tick 0.67 ms every 150 ms for all four shops.
- After tweaks (distance-culled chase loop, no redundant writes, small decor without shadows): shop row 4.30 ms CPU / 0.64 ms GPU; Shop1 bulbs still change colour between samples; tree decor 423 of 519 parts no longer cast shadows.
- Risk/heuristic: PC numbers do not predict phone FPS; low-end phones may still feel the ~2,200 extra parts in the dense shop row. If a real device shows drops, next levers are fewer fairy lights/tree extras or client-side culling of far decor.
- Checkpoint: scripts `synced`, pending []; Rojo build + `verify_repository.py --xml` OK (29/33/62); full 33-asset export vs `assets/` **0 differences**. Bridge SceneDirty still set (user to acknowledge/restart). No Save/Publish.

## Trees, bushes and fairy lights — 2026-10-26
- Environment: connected TEST Studio, single-client Play. Extras: 108 per shop (e.g. Shop1), 87 in MidnightCity park. Screenshots: alley between Shop1/Shop2 tree rows and the park — round/small/pine/cluster/blossom/autumn variants, bushes with flowers and lit fairy-light strings all visible.
- Not tested: a shop with Dining Area/Space upgrades (right-row extras shifting via `TreeRowDecor`), mobile performance (~520 extra parts across shops + park), multiplayer.
- Checkpoint: scripts `synced`, pending []; Rojo build + `verify_repository.py --xml` OK (29/33/62); full 33-asset export vs `assets/` **0 differences** (runtime-only). Bridge SceneDirty still set (user to acknowledge/restart). No Save/Publish.

## Mall interior / windows — 2026-10-26
- Environment: connected TEST Studio, single-client Play. MallInterior ~300 parts. Screenshots: street view through both windows (grocery aisles left, fridges/snack island right), interior from entrance, fridge close-up.
- Iterations: interior lights at Brightness 1.3 washed the room out → 0.5; first fridges were solid boxes hiding the bottles → open-front cabinets with shelves and 70%-transparent doors; banner wrapped with a bullet → shortened to "FRESH INGREDIENTS 24/7".
- Regression: holding the real SuppliesCheckout prompt still opened the MidnightMall window (MallPanel visible, Prep/Kitchen/Drink kits listed).
- Not tested: walking collision around the new shelves/carts, courier visitor route into the mall, mobile performance, multiplayer.
- Checkpoint: scripts `synced`, pending []; Rojo build + `verify_repository.py --xml` OK (29/33/62); full 33-asset export vs `assets/` **0 differences**. Bridge SceneDirty still set (user to acknowledge/restart). No Save/Publish.

## Full shift after station equipment change — 2026-10-26
- Environment: connected TEST Studio sandbox, one desktop client, fresh sandbox profile (TutorialStep 1, Bank 500, Lv.1). Temporary client autoplayer (in-memory `_G`, removed by Stop) teleported the character to each spot, held the real ProximityPrompts (`InputHoldBegin/End`) for bell/Cook/Serve/FuseBox/Radio/Ward, and sent `CookSkill`, `TakeStock`, `FillStock` through the normal Command remote with ±0.08 random aim error. Server validation unchanged.
- Result: full 300-second shift completed, `Phase=Won`: 13 served, 1 strike, shift cash $1130, Bank 500→2010. All 13 CookSkill calls accepted (Perfect 94–98 / Good 87 range). Cook + serve worked at Stations A (Noodles), B (Fried Rice), C (Thai Tea); backroom refills worked for C and A; Lv.2 reached mid-shift and an MK_DUMPLINGS order routed to Station D (enabled, refill accepted). Events handled: BLACKOUT, WHISPER, SHADOW, BLACKOUT. Station gear (CanQuery=false, prompts RequiresLineOfSight=false) did not block any prompt; no script errors in Output (only ConfigService missing-key warnings and sync messages).
- Tool artifacts, not game bugs: early Cook presses and two refill commands failed until the server caught up with the teleported position (0.25 s wait too short); once the refill failed the autoplayer kept the crate and did not retry, so the Station D dumplings order waited (OrderUnavailable, patience frozen) until a manual fill at 0:21; that order was not cooked before time ran out (the single strike came during the final BLACKOUT window).
- Not tested: normal walking/pathing, Station D cook completion, set meals, mobile, multiplayer.
- Checkpoint: no source/asset changes this run; scripts `synced`, pending []; 33-asset export vs `assets/` **0 differences**. Bridge SceneDirty still set (user to acknowledge/restart). No Save/Publish.

## Cooking station equipment — 2026-10-26
- Environment: connected TEST Studio, single-client Play. Gear part counts: A/D 22, B/E 27, C/F 20. Screenshots: front row close-up, gameplay camera from behind the player (steam visible above pots), pot/wok close-up.
- First pass had a white-looking pot and a pancake-looking wok; darkened steel, shrank pot, added wok rim/larger rice/bigger flames and re-verified. Cook prompts still present (A/B/C enabled, D locked at Lv.1 as before).
- Not tested: a full cook/serve cycle after the change, theme menus with non-noodle/rice/tea dishes (gear is per kit, so e.g. cafe/pizza themes still show pot/wok/tea gear), mobile performance, multiplayer.
- Checkpoint: scripts `synced`, pending []; Rojo build + `verify_repository.py --xml` OK (29/33/62); full 33-asset export vs `assets/` **0 differences** (runtime-only). Bridge SceneDirty still set from Play/Stop (user to acknowledge/restart). No Save/Publish.

## Town building lighting/detail — 2026-10-26
- Environment: connected TEST Studio, single-client Play. TownDetail part counts: Apartments 116, Market 76, Clinic 68, Office 69, Bus Terminal 67. Screenshots: street overview toward Apartments/Market/Clinic, Apartments entrance close-up, Clinic, Bus Terminal.
- Iterations: first window colours bloomed to near-white → darkened palette and re-verified; departure board overlapped a window and wrapped → moved/resized to two lines. A scripted text edit briefly put a raw newline inside a Luau string on disk during Play; fixed before Stop, and the synced/verified source contains `
`.
- Not tested: mobile performance with ~400 extra parts and ~15 PointLights, multiplayer, rain-event fog look.
- Checkpoint: scripts `synced`, pending []; Rojo build + `verify_repository.py --xml` OK (29/33/62); full 33-asset export vs `assets/` **0 differences** (runtime-only decor). Bridge SceneDirty still set from Play/Stop (user to acknowledge/restart). No Save/Publish.

## Citizen faces and arms — 2026-10-26
- Environment: connected TEST Studio, single-client Play. All 12 citizens build 23 parts (was 7). Close-up screenshots while walking confirmed face on the walking side, readable eyes/blush/smile, cap and bun styles, skin-tone hands under streetlights.
- First Play started before the bridge pushed City.luau (Studio still had old source); stopped, confirmed Studio source, replayed. Wait for sync before Play.
- Not tested: walking animation (citizens still glide), mobile/perf with 12×23 parts, multiplayer.
- Checkpoint: scripts `synced`, pending []; Rojo build + `verify_repository.py --xml` OK (29/33/62); full 33-asset export vs `assets/` **0 differences** (citizens are runtime-only). Bridge SceneDirty still set from Play/Stop (user will acknowledge/restart). No Save/Publish.

## Storefront decor — 2026-10-26
- Environment: connected TEST Studio, single-client Play (sandbox). Screenshots from street, side, close-up and gameplay camera.
- Verified: all four shops build 58 Storefront parts; Shop1 owner sign `CHAMPNOHELL'S KITCHEN`; owned Shop1 bulbs change colour between 0.16 s samples (chase); vacant Shops 2–4 warm static; synthetic `StorefrontPower=false` on the server (attribute only, not a full BLACKOUT event) turned all Shop1 bulbs non-neon; awning fade LTM 0.85 for Shop1 with camera at (4,7.5,-17), Shop2 unaffected; default gameplay camera inside the shop shows the awning as an unobstructed top frame. First frame version was hidden by roof/awning; moved inside the board edges and re-verified.
- Not tested: real BLACKOUT event cycle, multiple clients/other owners, mobile performance, themed shops (decor colours are fixed, not theme-tinted).
- Checkpoint: scripts `synced`, pending []; Rojo build (.rbxl/.rbxlx) and `verify_repository.py --xml` OK (29/33/62); full 33-asset Edit export vs `assets/` **0 differences** (decor is runtime-only, generated by ShopService). Bridge SceneDirty remains set from Play/Stop and Edit captures; clearing it via MCP was denied by the tool permission classifier, so `sync_bridge.py check` still reports the scene commit guard. Remaining step: acknowledge SceneDirty (review shows 0 differences) or restart the bridge per SYNC.md. No Save/Publish.

## Youth-perspective visual/model review — 2026-10-26
- Environment: connected TEST Studio (PlaceId 120399989321685), single-client Play, scriptable QA camera (client-only RenderStep bind, HUD hidden for shots); Edit-mode overview capture. Heuristic review as an age 10–15 player, not child-user research.
- Captured: own shop exterior/interior, cooking stations + food props, backroom shelves, Kitchen 2 vacant, town buildings (Apartments/Corner Market/City Clinic), Midnight Mall exterior/sign, citizen NPCs.
- Findings (no changes made): shops/town are flat untextured boxes; town buildings too dark with flat windows; citizen NPCs have no face/arms (customers do have eyes/hair/arms); cooking stations are plain grey crates with tiny labels; backroom shelf signs hide ingredients; mall is mostly empty with opaque windows and stretched sign; blocky tree wall; owner sign shows `champnohell'S` capitalization; menu board order (Noodles left) is opposite station order (Station A right).
- Checkpoint: Play stopped; scripts `synced`, pending []. Stop/Play and Edit captures set bridge SceneDirty. Full 33-asset export (MidnightCityModules exported shallow, scripts stripped as in prior reviews) vs `assets/`: **0 differences** (previous staging kept at `.sync/scene-review/assets.prev-20261026b`). Clearing the plugin's in-memory SceneDirty flag via MCP was denied by the tool permission classifier, so `sync_bridge.py check` still reports the scene commit guard; remaining step: user acknowledges SceneDirty (review already shows 0 differences) or restarts the bridge session per SYNC.md. Pre-existing staged-index guard (ShopService) unchanged. No source/assets changed. No Save/Publish.

## StationIcon_Ward removal / scene checkpoint resolved — 2026-10-26
- Usage audit: the only reference is the HUD task highlight (`shop:FindFirstChild("StationIcon_"..target.Name) or target`); StyleService/StyleShop only touch cooking-station icons. In Play, the server moves `Ward` behind the radio (e.g. Shop2 Ward 106,2.1,-8) while the Edit-mode `StationIcon_Ward` stays at its old spot (102,9.2,7.3), 17.4 studs away — so in Shops 2–4 the SHADOW highlight pointed at the wrong place. Shop1 (icon already missing) highlighted correctly.
- Removed `StationIcon_Ward` from Shops 2–4 in Edit (one ChangeHistory recording); 0 remain. Play check: with Event=SHADOW the client `NextAction` highlight adorns `Shop1.Ward` behind the radio (local-only attribute preview; full SHADOW event not replayed).
- Scene review: full 33-asset export vs `assets/` showed exactly 12 removals (4 icon Models + 8 Parts), nothing else. Promoted the reviewed staged `assets/Workspace/MidnightShops.rbxm`, rebuilt (.rbxl/.rbxlx), `verify_repository.py --xml` OK (29/33/62), re-compare **0 differences**. Then cleared the MCP-bootstrapped bridge SceneDirty flag. Final status: `synced`, pending [], SceneDirty=false.
- `sync_bridge.py check` still stops only at the commit guard: the Git index holds older staged copies (now ShopService first) than the Studio-matching working tree. Stage reviewed changes before committing. No Save/Publish.

## First-session fixes: patience freeze / refill lesson / next-level goal — 2026-10-26
- Environment: connected `Midnight Food Court [TEST]` Studio sandbox (Studio had been reopened; new MCP connection id), one desktop client, fresh sandbox profile. Confirmed PlaceId 120399989321685 / UniverseId 10772566896. Before pushing edits, checksummed all 29 Studio scripts against `.sync/base.json` and disk: Studio equalled base for every script, only the 5 edited files differed on disk (no conflict).
- Sync infrastructure: the local sync server had stopped and was restarted with `tools/start_sync.py`; the installed plugin still cannot write HttpEnabled (`lacking capability LocalUser`), so a fresh bridge session was bootstrapped through MCP from repo `Bridge.luau` + `.sync/plugin-config.json` (bundle served once from a temporary localhost server, token not printed, HttpEnabled restored). Status became `synced`; all 5 edits verified present in Studio.
- Patience during tutorial: after opening (TutorialStep 2, THAI TEA order) the player stayed idle 15 s; Patience stayed 1.000 and no strike. Tutorial order cooked/served normally (Bank 500→538).
- Patience during events (after TutorialSkip): BLACKOUT started at Patience 0.858; after the event cleared Patience read 0.867 (no drop for the event duration). The blackout's own repair timer still expired and gave its existing strike (unchanged, intended).
- Refill lesson: played until THAI TEA front stock was 0 with back stock 6. Guide showed `NEW • REFILL 1 / 2`, task card `REFILL FROM BACKROOM / Go to shelf C / DRINKS` (screenshot reviewed, Skip hidden). Walked by PathfindingService waypoints to the shelf (2.3 s), actual prompt hold took the crate → guide `NEW • REFILL 2 / 2 … STATION C`; walked to Station C (4.4 s), prompt hold refilled FrontTea 0→3, `RefillTaught=true`, guide hidden, Patience ~0.99 throughout.
- Shift end: completed the shift (10 served, reached Lv.2 mid-shift). SHIFT COMPLETE panel showed `$619 • 10 served` and `15 more orders to Lv.3 • unlocks Chicken Rice`; all labels TextFits=true (screenshot reviewed). Server/client error log: 0 errors.
- Not tested: the Lv.1 wording ("N more orders to Lv.2 • unlocks Pork Dumplings") as a screenshot, Lv.5/star wording, mobile/narrow layout of the taller result card, Thai locale, multiplayer (crew members see the owner's TutorialActive patience freeze), live server, Save/Publish. TutorialActive freezes patience for the whole 5-step guide including the Upgrade Desk step, so a player who never buys an upgrade or skips has no order timer pressure until they do.
- Checkpoint: Rojo builds + `verify_repository.py --xml` passed (29 scripts / 33 assets / 62 paths); bridge `synced`, no pending. **Incomplete:** the new bridge session reports SceneDirty=true. Full 33-asset export to `.sync/scene-review/assets` (previous staging kept at `assets.prev-20261026`) compared with `assets/`: 3 differences — Edit-mode `Workspace/MidnightShops/Shop1/StationIcon_Ward` (Model + 2 Parts) exists in `assets/` but is missing from Studio; Shops 2–4 still have it. This session made no Edit scene changes; the removal predates or is outside this session. Both sides preserved, SceneDirty not cleared, pending user decision (restore into Studio from asset, or accept removal and update the asset). Commit guard also still reports the pre-existing staged-index mismatch.

## Youth-perspective full first-shift playtest — 2026-10-26
- Environment: connected `Midnight Food Court [TEST]` Studio sandbox, one desktop client, fresh profile (TutorialStep 1, Bank 500, Lv.1). Confirmed PlaceId 120399989321685 / UniverseId 10772566896; bridge `synced`, no pending, SceneDirty=false before and after. Heuristic review from the perspective of ages 10–15, not research with child participants and not measured analytics.
- Method: opened the shop by walking to the bell, then cooked/served the tutorial order with real prompt holds. From 2:44 left, a temporary client autoplayer (in-memory `_G` helpers, gone after Stop) walked to prompts, handled events and sent `CookSkill` through the normal Command remote with a random ±0.12 aim error around the gold target to imitate an average child's timing. Server validation was unchanged.
- Result: full 300-second shift completed (`Phase=Won`): 7 served, 2 strikes, Shop funds 500→1040, shift payout $420, Journey 7/8 — one order short of Lv.2. Grades Good 70 (practice) then Good 84–85 and Perfect 99–100. Events observed: BLACKOUT, WHISPER, SHADOW roughly every 45 s; customers included a Dinner Party (3 guests) and Riley (Regular, Friend Lv.1 +15%). Typical order cycle ~13–15 s plus ~5 s customer gap.
- Positive for ages 10–15: rising funds and COMBO ×6/Perfect pop-ups feel rewarding; event variety and party/regular customers break repetition in the first shift; nighttime look and large dish cards are clear.
- Friction: (1) the first two strikes happened in the first ~90 s while the tutorial/order/blackout were all competing (tutorial 5/5 asks for the Upgrade Desk while the blackout card and a waiting order are shown); the strikes were partly caused by QA tool delay, but the order timer has no grace during the tutorial. (2) Front stock (3 per kit) ran out at ~3:30 into the first shift; A and B reached 0 and the task card showed MENU UNAVAILABLE while Riley waited — first-time players meet the backroom refill loop under time pressure with no tutorial step for it. (3) The SHIFT COMPLETE panel shows only `$420 • 7 served` and does not say "1 more order to Lv.2", so a near-miss reads as a dead end. (4) Cook prompts did not trigger while the camera faced away from the station (Studio MCP observation; normal players usually face the station).
- Heuristic retention estimate: typical first-time 10–15-year-olds ~8–12 minutes (one shift plus part of a second, likely leaving around the stock-out/near-miss), 20–30 minutes for players who reach Lv.2 and unlock a new dish in shift 2. Not measured.
- Not tested: backroom refill by normal walking (autoplayer's direct MoveTo got stuck against the station row, so refill attempts after 1:28 failed — automation limitation, not a confirmed game bug), shift 2/Lv.2 promotion, mobile/device emulator, multiplayer, live server, paid purchase, Save or Publish. No game source or assets changed.
- Checkpoint: after Stop, status `synced`, pending [], SceneDirty=false. `python tools/sync_bridge.py check` still stops at the pre-existing commit guard (Git index has older staged Inventory/HUD/Management copies than the Studio-matching working tree); not changed in this session.

## Mall supply window / multi-crate trip / kit labels — 2026-10-25
- Environment: connected `Midnight Food Court [TEST]` Studio sandbox, one desktop client. Confirmed PlaceId 120399989321685 / UniverseId 10772566896; 29 scripts synced before and after edits (no pending/conflicts).
- Kitchen [M] navigation now Overview/Staff/Quests/SHOP/GET GEMS/More (no Supplies); `OpenMidnightManagement:Fire("Stock")` lands on Overview with the info-only supplies card (screenshot reviewed).
- Actual client hold on the mall `SuppliesCheckout` prompt opened the separate MallPanel with Kitchen panel hidden; cards listed Prep/Kitchen/Drink kits with dishes (A Noodles + Lv.2 Pork Dumplings, etc.).
- Real `Command` remote: NOODLES:3, THAI TEA:2, FRIED RICE:3 succeeded (Bank 500→140, Carrying 8/8, Items 18/18/12); FRIED RICE:4 at 5/8 rejected with "3 more"; 0 and 99 rejected; buttons showed "Hands full • deliver first". Rapid calls hit the existing rate limit as expected.
- Walking to Shop1 backroom auto-closed the mall window; an actual hold on the Drink kits shelf stored the whole delivery (Back 6/6/6 → 24/24/18), cleared the carried crate.
- Runtime MenuLevel=2 on Shop1 → HUD stock rows `A D / B / C`; synthetic Phase=Closed + CloseReason=OUT OF STOCK showed "BUY SUPPLIES / Go to the BUS stop, then buy supplies at the MALL" fully inside the task card (TextFits=true, screenshot reviewed). No console script errors.
- Not tested: mobile/narrow layout of the mall window, gamepad, crew member (non-owner) and visitor-courier views in a real second client, multiplayer, bus ride with a full delivery, Thai locale strings for the new window. Runtime QA state reset by Stop Play.
- Checkpoint: Rojo build + `verify_repository.py --xml` passed (29 scripts / 33 assets / 62 paths). SceneDirty was already set before this session; exported all 33 mapped Edit assets to `.sync/scene-review` and compared against `assets/`: **0 differences** (previous staging kept at `.sync/scene-review/assets.prev-20261025`). The running plugin flag cannot be cleared without a bridge restart, so `sync_bridge.py check` still reports COMMIT BLOCKED (scene) while scripts are `synced` with no pending changes. Follow-up (user-approved): stopped the MCP-hosted bridge session via `_G.MidnightRepoSyncControl.Stop()` and started one fresh session from repo `tools/studio_sync/Bridge.luau` + `.sync/plugin-config.json` (bundle fetched once from a temporary localhost server, then removed; token not exposed; HttpEnabled restored). Fresh status: `synced`, no pending, `sceneDirty=false`. `sync_bridge.py check` now stops only at the commit guard because the Git index holds older pre-session staged copies of HUD/Management/Inventory (working tree = Studio). Stage the reviewed changes before committing. The installed plugin's old-token session (seen as 403 in Output) cannot authenticate and is not counted. No Save/Publish.

## Cooking F timing input / client-server marker reconciliation — 2026-10-25
- Confirmed connected TEST PlaceId 120399989321685 / UniverseId 10772566896 and successful pre-edit live sync checkpoint. Source-only fix; no Edit scene/model changes.
- Diagnosis: the UI marker used the client-visible clock, while `Experience.Skill` scored only the server receipt time. Frame/network delay could therefore move the evaluated phase outside the gold zone after the player pressed F on it. ContextActionService also had no fallback if a higher-priority binding consumed F.
- Client now submits its displayed marker phase with `CookSkill`. Server still requires an active cook, one unused hit, correct shop membership and proximity, accepts only a finite 0–1 phase within 0.12 of its authoritative phase, and otherwise scores the authoritative phase. A debounced `UserInputService.InputBegan` F fallback shares the same one-request timing action.
- Runtime normal-script QA bridge armed the actual ShopService/Experience state; with the client-visible phase inside the gold interval, a real client F keypress produced `SkillHit=true`, `Perfect`, 97/100. An earlier off-zone F produced Good 68/100, confirming input registration and continuous scoring rather than unconditional success.
- Temporary QA Scripts/BindableFunctions were removed by Stop Play. Rojo XML/source verification and a fresh final live sync checkpoint passed with no pending changes, conflicts or SceneDirty. No mobile/gamepad, multiplayer latency, Save or Publish test.


## Youth-perspective follow-up playtest — 2026-10-25
- Environment: connected `Midnight Food Court [TEST]` Studio sandbox, one desktop client. Confirmed PlaceId 120399989321685 / UniverseId 10772566896 and a successful 29-script sync before Play. This is a heuristic review from the perspective of ages 10–15, not research with child participants.
- Replayed the opening flow: held E at the bell, received a Noodles order, cooked at Station A, completed the no-penalty practice as Good 70/100 without a timing input, carried and served the meal. Shop funds rose 500→538 and Journey progress 0/8→1/8 in about 40 seconds after opening.
- Positive observations: the large dish image, persistent task card, station letter/name, carrying panel, reward total and progress bar make the first success easy to understand. The nighttime shop has a strong identity and the first reward arrives quickly.
- Retention concern: after the first order the tutorial immediately sends the player to the backroom Upgrade Desk. The core action is already exposed as fetch/interact/serve, while Lv.1 has only three recipes; without stronger short surprises, choices, collection goals or visible near-term unlock previews, repetition is likely to become noticeable during the first or second five-minute shift.
- Heuristic session estimate: many first-time 10–15-year-old players are likely to tolerate roughly 5–10 minutes in the current solo Lv.1 loop; players attracted by restaurant progression may continue 15–25 minutes. This estimate is an inference from this single-client run and the documented pacing, not measured retention analytics.
- Scope/limitations: runtime character repositioning was used after automated pathfinding could not route to the bell, so normal walking/path discovery was not validated. No full shift, organic promotion, mobile/device emulator, multiplayer, live server, paid purchase, Save or Publish test. No game source/assets were changed.

## First-shift clarity / training grace — 2026-10-25
- Confirmed connected TEST PlaceId 120399989321685 / UniverseId 10772566896 and passed the required pre-edit live sync checkpoint after updating the Git index to the already-synced Studio source. No Edit scene/model changes were made.
- Single-client Studio sandbox, actual first-shift flow: with a Noodles order at TutorialStep 2, a validated `TakeStock` request for Fried Rice was rejected with `Wrong ingredients for Noodles. Follow the order icon to STATION A.` No wrong crate was created.
- Actual cooking with no F/tap input during training completed as Good 70/100, carried the correct meal, and displayed `PRACTICE COMPLETE • GOOD 70/100` rather than Poor. The redesigned timing panel and guide were visually reviewed while cooking: `PRESS F / TAP WHEN WHITE REACHES GOLD`, gold target, moving white marker, and practice/no-penalty explanation were visible.
- Regression after TutorialSkip: an actual Thai Tea cook with no timing input completed as Poor 0/100, confirming the grace applies only to training. Normal timed-hit qualities were not exhaustively replayed in this session.
- Rojo XML build and all 29 source round-trips passed before Studio QA. Single-client desktop only; mobile touch sizing and multiplayer simultaneous stock handling remain untested. No paid transaction, Save or Publish.


## Single rear-wall station row — 2026-10-25
- Connected TEST PlaceId 120399989321685 / UniverseId 10772566896; successful pre-edit source audit. Earlier playtest's staged StyleRenderer mismatch was not used to overwrite current source; current live/disk audit passed before edits.
- All four plots: six bases share Z, width 4.1, .3 gaps and .15 rear-wall clearance. Final base ends .2 stud before doorway's left edge, preserving the existing doorway width. Six cooktops per plot match their bay X/Z and fit its width; original floating tops removed through relocation.
- Sandbox rank/theme fixtures checked all 66 themed/default dish previews plus Signature Rice against bay width/depth; all fit. Labels now fit base width. Lv.1 and Lv.2 desktop screenshots reviewed; Lv.2 D remained unlocked, E/F locked.
- Actual E at wall-row D cooked/held MK_DUMPLINGS, shared front stock three→two. Initial inputs with camera facing away did not trigger; oriented character/camera toward station before successful input. This is a seeded single-client sandbox order, not organic progression or a general interaction-ambiguity fix.
- Character_navigation from side aisle to stock entrance succeeded. Steam identity mapping reviewed statically; no separate particle/multiplayer/mobile test. Runtime QA scripts removed by Stop. Final XML/source round-trip and fresh full sync checkpoint checked; no Save/Publish.

## Youth-perspective first-session playtest — 2026-10-25
- Environment: connected `Midnight Food Court [TEST]` Studio sandbox, one desktop client. Confirmed PlaceId 120399989321685 / UniverseId 10772566896. This was a heuristic playtest from the perspective of a 10–15-year-old, not research with child participants.
- Played the opening flow with normal keyboard input: opened the five-minute shift, received a Thai Tea order, interacted with Station C, carried the finished drink and served it. Bank rose 500→526 and career progress 0/8→1/8. A blackout interruption appeared during the second order and the fuse-box interaction cleared it.
- Positive observations: the nighttime identity is distinctive; the large task card and dish imagery make the next goal easy to recognize; the first reward arrives quickly; the early interruption breaks up the cook/serve loop.
- Friction observed: the initial cooking attempt completed at Poor 0/100 without making the timing action sufficiently obvious. During the Fried Rice order, interaction around the tightly grouped stations/stock area resulted in carrying Noodles ingredients and the HUD redirected to Station A, creating a mismatch between the active order and task guidance. This is likely confusing for younger players even though the stock system is internally valid.
- Pacing review: one shift is 300 seconds, orders allow 40 seconds, disturbances are scheduled every 45 seconds, and the first promotion requires eight served orders. The five-minute session length is suitable, but Lv.1 has only three recipes and the repeated fetch/cook/serve loop risks feeling repetitive before promotion if interaction mistakes consume customer patience.
- Scope/limitations: session ended early after the second-order interaction issue; no full-shift completion, organic promotion, mobile/device-emulator, multiplayer, paid purchase, Save or Publish test. Runtime character repositioning was used to reach interactions, so this does not validate normal walking/path discovery.
- Console was dominated by repeated missing ConfigService-key fallback warnings and local sync-plugin HTTP/capability messages; no new gameplay exception was identified in the captured output.
- Completion checkpoint is blocked: `python tools/sync_bridge.py check` reports staged `src/shared/ReplicatedStorage/MidnightStyle/StyleRenderer.luau` differs from Studio. The discrepancy was preserved and not overwritten. No Edit-mode scene/model changes were made.

## Six fixed cooking bays — 2026-10-25
- Confirmed connected TEST PlaceId 120399989321685 / UniverseId 10772566896, successful pre-edit live script audit. Runtime-generated scene changes represented in maintained source; no Edit asset changes intended.
- All four kitchens generated six bases. Single-client sandbox normal server QA Script checked 11 menu sets x ranks 1–5 = 55 combinations: three/four/five/six/six enabled Cook prompts; exact SelectedRecipe/Station mapping, compatible stock IDs, unlocked dish models and visible locked-level labels. Additional default + four legacy theme checks x five ranks = 25 cases (five default cases repeated), covering 75 unique theme/rank combinations overall.
- Actual client E on shelf A took three Dumplings kits; E on D refilled front zero→three, then E cooked and held MK_DUMPLINGS, front three→two. Prompt/hint identifies D; final server Take notice explicitly says STATION D. Initial rapid reposition/input did not pick up; repeated after character/camera stabilization succeeded. These use seeded orders/profiles, not organic progression.
- Synthetic sandbox E/F refill actions succeeded for Chicken Rice/Lemon Iced Tea. Ready Lemon Tea model was at F and normal PickupPrepared succeeded. Bundle acceptance passed drink-first then Dumplings; initial incomplete test fixture lacked Score/Quality and was corrected before passing. SignatureEnabled at rank 3 selected Signature Rice at B. Server locked-menu validation reviewed; no malicious-remote/multiplayer exploit test claimed.
- Lv.1 desktop screenshot reviewed with six bases, ABC dishes and DEF locked signs. Character_navigation succeeded through the right-side aisle from front/middle to stock entry. No real-phone, full theme visual tour, owner-transfer or simultaneous crew cooking regression.
- Runtime QA scripts/BindableFunctions removed on Stop; final XML/source build and fresh full sync checkpoint checked. Save/Publish not performed.

## Pork Dumplings refill / ingredient context — 2026-10-25
- Confirmed TEST PlaceId 120399989321685 / UniverseId 10772566896. Pre-edit sceneDirty reviewed via fresh staged export of all 33 mapped assets and normalized comparison: zero semantic differences; export receiver stopped.
- Root cause: station callback passes expanded recipe ID to Inventory.Restock, which compared it directly with the shared crate Food ID (MK_DUMPLINGS vs NOODLES). Stock normalization now precedes both Take/Restock lookup/validation. Internal stock IDs remain shared station kit categories.
- Single-client sandbox normal QA Script seeded rank 2, MK_DUMPLINGS order, zero A front/six back. Real E at shelf A took three (back six→three); prompt read STATION A / Pork Dumplings ingredients, carried crate label PREP KITS / Pork Dumplings / 3 and SupplyRecipe=MK_DUMPLINGS. Real E at station A refilled front zero→three, removed crate; another E cooked and held MK_DUMPLINGS, front three→two. Initial local-bin-frame reposition landed badly; corrected world-space placement before successful interaction. No organic customer-spawn progression claim.
- Resolver checked all 67 recipes and simultaneous dumplings/lemon-tea bundle slots. Synthetic sandbox Take/Restock via recipe IDs also passed Chicken Rice (B), Lemon Iced Tea (C), legacy Noodles (A), rejecting wrong-slot refill without consuming the crate. Old transit bag without RecipeId resolved Dumplings correctly and returned stock.
- Expanded B/C empty-front shelf routing reviewed statically; no second-client/mobile or mall purchase regression. QA removed on Stop; Edit SceneDirty=false. Final XML/source build and fresh full sync checkpoint checked. No real purchase, Save or Publish.

## Separate Upgrade UI / complete-theme surface matching — 2026-10-25
- Confirmed connected TEST PlaceId 120399989321685 / UniverseId 10772566896 and successful pre-edit sync. Source-only changes; no Edit asset change.
- Temporary normal server QA Script asserted Profiles.Sandbox, seeded theme selection with Profiles.Mutate and purchased Space through validated commands. Compared seven backroom wall/office-divider sections against LeftWall and both BackroomFloor/ExpandedFloor against ShopFloor for exact Color, Material and MaterialVariant equality: 15 variants x three expansion levels = 45 passing cases. Variants include default, ten StyleCatalog themes and four legacy themes. Reflectance is copied by implementation but not separately asserted.
- Real client held E at work desk: separate MidnightUpgrade.UpgradePanel visible, KitchenPanel hidden, five cards (four upgrades + funds). Actual UI mouse click purchased Kitchen Lv.1; price/level/status refreshed correctly. M hid Upgrade and opened main management; generic OpenMidnightManagement Upgrade route did not open it. Revisited desk with E successfully. After final close-button color/backdrop adjustment, independent close mouse click hid Upgrade and backdrop without opening M.
- Desktop Upgrade layout screenshot reviewed. Retro Diner Dining Lv.2 floor and backroom walls visually reviewed; all-theme sweep checked properties rather than 45 individual screenshots. Runtime character repositioning used; no walking/path test. Responsive reflow implemented; real-phone/viewport-emulator QA remains pending.
- Temporary QA removed by Stop; Edit SceneDirty=false. Final Rojo XML/source round-trip and fresh full sync checkpoint checked. No multiplayer, real purchase, Save or Publish.

## Upgrade page reopened by M — 2026-10-25
- Confirmed TEST PlaceId 120399989321685 / UniverseId 10772566896. Pre-test sceneDirty reconciled by fresh staged export of all 33 mapped assets and normalized XML comparison: zero semantic differences; receiver stopped.
- Single-client Studio sandbox: actual E at work desk opened Grow your kitchen; M closed it, character moved to storefront, M reopened Kitchen overview. Revisited desk with actual E and purchased Kitchen level 1 through normal Command remote (Ok=true), then closed/reopened with M at storefront: Overview. Generic OpenMidnightManagement:Fire("Upgrade") also returned Overview.
- Escape was intercepted by Roblox core pause menu during QA; resumed before completing the M regression. No claim of Escape-close regression coverage. Movement used runtime character repositioning, not a walking/navigation test.
- Stop restored Edit, runtime QA left no persistent scripts/assets. Rojo XML/source verification and fresh full sync checkpoint checked. No mobile/multiplayer, Save or Publish.

## Shadow behind radio / purchased seating only — 2026-10-25
- Connected Studio TEST, PlaceId 120399989321685 / UniverseId 10772566896; single-client sandbox. Pre-edit scene guard reconciled by fresh export of all 33 mapped assets and normalized XML comparison: zero semantic differences. Export receiver stopped; maintained assets unchanged.
- Runtime sandbox QA seeded SHADOW through the normal event loop. Separate apparition stood three studs directly behind each plot's radio; original customer remained unchanged at the counter. Shop1 screenshot reviewed with customer and radio visible separately.
- Sampled all five ShopLight brightness values at different ticks; partial dimming varied and all remained enabled. Forced an expired event deadline: SHADOW and dimming persisted. Actual held E at the relocated Ward cleared SHADOW and restored every original brightness exactly; repeated successfully after final placement adjustment.
- Attempted E at Serve while carrying a seeded meal during SHADOW: meal retained, zero strikes, same guest/event. Closing during another SHADOW removed the apparition and restored lighting. Technician/shift-end/owner-transfer cleanup paths reviewed statically, not separately exercised.
- All four starting plots had zero DiningTable/UnlockedTable/TableTop objects. Career rank fixtures 1–5 with Space/Decor zero generated no rank tables. Normal validated Space upgrade commands then produced exactly one/two/three DiningTable objects at levels 1/2/3. Office chair is intentionally excluded from dining counts.
- QA Scripts/BindableFunctions removed with Stop; confirmed absent in Edit and SceneDirty=false. Final source XML round-trip/build and fresh full sync checkpoint checked. No multiplayer, real-phone, real purchase, Save or Publish; seeded fixtures do not establish organic progression testing.

## Lv.2 cooking / Dining Area — 2026-10-25
- Connected Studio TEST single-client sandbox, PlaceId 120399989321685 / UniverseId 10772566896. Pre-edit sceneDirty reviewed by staging all 33 mapped assets and normalized XML comparison (zero semantic differences); temporary export receiver stopped before implementation.
- Diagnosis: expanded recipes already route through MealBundles.StationFood, but station prompts/models showed the base theme dish; Dining canopy used a hard-coded lower height and three systems independently placed dining/rank/decor tables.
- Temporary normal server QA Script accessed the running ShopService/Profiles state, asserted sandbox, and seeded a rank-2 Pork Dumplings order. Real client saw A / Pork Dumplings and its canonical preview, held E at Station A, then held MK_DUMPLINGS after cooking. This is a seeded-order integration test, not an organically spawned customer/live progression test.
- Unparented shop fixture verified all 67 recipe selections/prompt names and active previews, concurrent dumplings+lemon-tea bundle previews and clearing of the completed slot. Fixture destroyed.
- Actual validated Upgrade commands exercised Dining levels 1–3; rank fixtures 2–5 (12 combinations) showed one/two/three tables, zero table/seat corners outside expanded floors, no old rank/decor table rows, matching roof height/thickness/depth, and matching roof seam. Decor 3 planter checks at all dining levels found zero planter/table/seat overlaps and zero planters outside the floor.
- Roof top Y=14 matches main roof; right-side crown clearance is at least .5 stud at Dining levels 2–3. Visual review of Dining level 2 completed.
- QA scripts/BindableFunctions disappeared after Stop; confirmed Edit SceneDirty=false. Final Rojo XML/source round-trip and fresh sync checkpoint checked. No multiplayer, real-phone, paid transaction, Save or Publish.

## Rank plaque/menu separation — 2026-10-25
- Confirmed target PlaceId/UniverseId in Edit; one connected Studio sandbox client.
- Actual Corner Kitchen plaque right edge x=-5 versus menu left edge x=-2.75: 2.25-stud gap in Shop1. Screenshot shows both rank text and all three starting dish cards unobstructed.
- Shared rank plaque placement applies to later tiers; no level progression replay performed. Stop Play, source XML round-trip and final sync checkpoint checked. No Save/Publish.

## Station base sign placement — 2026-10-25
- Connected Studio TEST, one sandbox client. Confirmed PlaceId/UniverseId in Edit before edits.
- All 12 StationGuide panels across four plots: local vertical offset 0, height within base bounds, .08-stud center offset in front of base face, AlwaysOnTop=false. Shop1 screenshot confirmed Station B attached to the front base below the cooking surface.
- Stop Play, XML source round-trip/build and final sync checkpoint checked. No gameplay/economy change, mobile/multiplayer, Save or Publish.

## Signs, white board clipping and rear lawn — 2026-10-25
- Environment: connected Studio TEST single-client sandbox; correct PlaceId 120399989321685 / UniverseId 10772566896 confirmed in Server before edits, followed by Stop and fresh sync audit.
- Diagnosed: WorldActions sign helper used AlwaysOnTop=true; office board/papers intersected the one-stud rear wall; expanded pavement and original rear grass overlapped at the same Y=1 surface.
- All four plots: four affected SurfaceGuis each with zero AlwaysOnTop=true; board-to-wall clearance .06 stud and papers entirely ahead of board. Pavement rear and grass front both z36, zero positive-area overlaps between any shop pavement and city GrassTiles.
- Visual review: complete cork board with three papers inside Office; outside rear wall occludes Upgrade/hiring text. Actual client navigated across rear grass successfully; before/after walking captures reviewed. Geometry check establishes removal of the coplanar overlap; no real mobile hardware test.
- Fixes are generated at runtime by maintained ShopService, including matching grass-tile trim. Stop restores the original Edit assets; final build/source round-trip and sync checkpoint checked. No Save or Publish.

## Ingredient-to-dish labels — 2026-10-25
- Environment: connected Studio TEST single-client sandbox, correct PlaceId/UniverseId confirmed during fresh 33-asset scene reconciliation.
- Pre-edit sceneDirty: staged all 33 current Edit assets; normalized XML comparison returned zero differences. Acknowledged only after export/review, stopped the temporary receiver, and passed fresh sync before edits.
- Actual client default labels: A/PREP Noodles, B/KITCHEN Fried Rice, C/DRINKS Thai Tea. Visual capture reviewed shelf text. Actual FRIED RICE pickup returned Take Kitchen kits to STATION B; prompt identified B / KITCHEN and Fried Rice.
- Isolated unparented shop clone: verified label contents for 11 themes x levels 1–5 (55 cases), including additional unlocked recipes. Japan level-3 SignatureMenu showed Signature Chicken Rice + Chicken Rice Bowl and omitted replaced Sushi. Fixture destroyed afterward; these checks are not live profile/theme-purchase tests.
- Stop Play, Rojo XML round-trip and final sync checkpoint checked. HUD station-letter text reviewed statically; no mobile/multiplayer, paid purchase, Save or Publish performed.

## Wall-aligned racks, 95% scale — 2026-10-25
- Connected Studio TEST, one real client, Studio sandbox; confirmed PlaceId/UniverseId before editing.
- All four shops: rack models GetScale()=.95, shelf width 7.03/depth 3.515 (from 7.4/3.7), bin width 5.7 (from 6). Checked world corners of racks, food props, bins/count plates and sibling icons: zero divider crossings, minimum rear gap .15 stud.
- Actual FRIED RICE stock pickup succeeded; no-jump stock-to-office navigation returned Success. Screenshot reviewed with INGREDIENTS sign visible above the wall-aligned shelves.
- Stopped Play and checked source XML build/round-trip plus final fresh sync audit. No persistent Edit asset change; runtime layout remains in synced source. No multiplayer/mobile, Save or Publish.

## Stock room spacing / wall penetration — 2026-10-25
- Connected Studio TEST, one real client, Studio sandbox. Confirmed PlaceId 120399989321685 / UniverseId 10772566896 before edits.
- Root cause inspection: stock box icons are sibling Models of their pick bins. Previous translation moved bin descendants but omitted sibling icons, leaving boxes behind the relocated divider.
- Runtime across all four shops: Stock depth 11, Office depth 14, backroom 32x25. Audited world-space corners of 15 bin/count/icon parts per plot; zero corners crossed the stock-facing divider plane, minimum clearance 2.45 studs.
- Actual TakeStock FRIED RICE succeeded at relocated bin. No-jump path from stock aisle (14,3,11) to office (10,3,24) returned Success. Inspected room captures; no new permanent Edit models created.
- After Stop Play, final Rojo XML/source round-trip and fresh sync checkpoint checked. No multiplayer/mobile, Save or Publish performed.

## Compact ingredient pantry — 2026-10-25
- Connected Studio TEST, one client, Studio sandbox. Stock footprint reduced from 32x14 to 32x8; backroom floor 32x22. Office divider moved to Shop1 z16, pick bins to z13; office furniture moved with the rear room.
- All four runtime plots: zero ReserveCarton objects and 27 food props (sacks, crates, vegetables and jars); lower racks have nine shelf decks. Final stock light brightness .65, range 18.
- First compact rack placement blocked navigation. Shifted racks left; final no-jump Pathfinding from (14,3,10) to office (10,3,21) returned Success. Actual TakeStock FRIED RICE at relocated bin succeeded.
- Play screenshots reviewed for shorter racks, open produce crates, sacks/jars and aisle. No physical mobile or multiplayer test; existing office interaction code is unchanged.
- Rojo XML round-trip and final sync checkpoint checked after Stop Play. Runtime-only furnishings remain in maintained generating source; no Edit asset change, Save or Publish.

## Stock/office furnishing and scene reconciliation — 2026-10-25
- Environment: connected Studio TEST, PlaceId 120399989321685 / UniverseId 10772566896; single real client, Studio sandbox.
- Reconciled pre-existing SceneDirty before source edits: serialized all 33 mapped Edit assets into .sync/scene-review, built baseline/review XML and compared normalized properties/structure. Zero differences; serialization child ordering and referent IDs excluded from comparison. Terrain still has zero cells; known Rojo unsupported Terrain property warning remains.
- Two bridge sessions were reporting conflicting dirty state. After export/review, rotated the local bridge token and connected one current bootstrap session; fresh working-tree audits passed. Installed plugin restart behavior is not validated by this recovery.
- All four runtime shops: 12 shelf decks, 18 reserve cartons, native enabled bin and Upgrade prompts, and an OfficeChair Seat.
- Shop1: TakeStock FRIED RICE succeeded from relocated bin; FillStock succeeded (+3). Held E at the office desk opened the actual Upgrade panel with Kitchen/Service/Decor/Dining Area cards.
- Chair: actual Humanoid occupied Seat and faced +Z toward monitor. Pathfinding from stock aisle (14,3,13) to office (4,3,28) succeeded with eight waypoints, no jumping.
- Screenshots inspected: stocked steel shelving with clear aisle; workstation with monitor/keyboard/mouse/lamp, chair and filing cabinet. This supersedes the earlier white-capture limitation for these rooms.
- Stop Play restored Edit mode with SceneDirty=false; runtime furniture remains represented by synced generating source. Temporary export HTTP receiver stopped. Final source build/round-trip and sync checkpoint performed; no multiplayer, mobile hardware, Save or Publish.

## Task completion checkpoint rule — 2026-10-25
- Documentation-only change to AGENTS.md and SYNC.md; reviewed the rule for script sync, scene export, fresh check, blocked-task reporting and separate Save/Publish status.
- No game source/assets changed or gameplay tests run. Existing sceneDirty blocker remains unresolved; stock/office furnishing is pending comparison/export before implementation.

## Expanded backroom — 2026-10-25
- Connected Studio sandbox Play: all four kitchens created a 32x28 backroom, partition and rear office desk. Shop1 desk at 4,4,30; stock bin remains at 4,2.8,17; divider at z22 with a six-stud doorway.
- Rojo XML build and all 29 source round-trips passed. Geometry is generated from source; no permanent Edit scene mutation or manual asset export needed.
- Screen capture returned a white scene, so room appearance and walk-through were not visually verified. Stock interaction and Upgrade prompt activation were not replayed for this layout.
- No multiplayer, Save or Publish performed.

## Navigation wording — 2026-10-25
- Environment: repository plus connected Studio Edit place (PlaceId 120399989321685, UniverseId 10772566896).
- Corrected four outdated instructions: upgrade tutorial, Save Slot unlock notice, travel HUD and shop return button.
- Search found none of the four old strings in src; Rojo XML build and all 29 source round-trips passed. Existing Terrain warning remains.
- Bridge was reconnected through the existing bootstrap after plugin startup failed to answer audits. Working-tree sync audit passed before editing; final audit recorded in this session.
- Text-only verification; no Play, paid purchase, Save or Publish performed.

## Post-kick visitor recovery — 2026-10-24
- Rojo XML build and exact 29-script round-trip verification passed after replacing all obsolete Co-op references in the HUD and server leave/kick guidance.
- In one connected Studio Play client, a local `ShopId=0` UI-state simulation displayed `CHOOSE YOUR NEXT STEP` and `Tap for options, or find a green NOW HIRING sign`; this verifies the rendered HUD state only.
- Static review confirmed the HUD action now routes to Overview, Overview offers `Open my kitchen` through the existing server `Home` command, and a second card points to hiring signs/city spawn.
- Limitation: no real two-client owner-kick flow was run, so server-to-client transition, five-minute same-shop block and immediate joining of a different owner's shop still require multiplayer verification.
- No Save or Publish was performed.

## World-first restaurant UX — 2026-10-24
- Environment: connected `Midnight Food Court [TEST]` Studio session, PlaceId 120399989321685 / UniverseId 10772566896, Studio sandbox, one real Play client.
- All four runtime kitchens created both `WorldActions.Upgrade` and `WorldActions.CrewJoin` prompts.
- Walk/hold-E test on the gold circle opened the Upgrades panel; the main navigation contained nine simplified destinations and no Upgrade/Co-op button.
- Upgrade catalog rendered Kitchen, Service, Decor and Dining Area. A sandbox Dining Area purchase spent 300 Shop funds, set level 1, created 10 expansion parts with a 7x20 floor, and opened the right wall.
- Visual inspection confirmed the two circles are visible outside the front counter. Rojo XML build and exact 29-script round-trip verification passed; known Terrain warning unchanged.
- Locale observed in this client was `en-us`; Thai dictionary/prompt selection was code-reviewed but not run under a Thai locale emulator. Crew signup with a second real client remains untested.
- No DataStore persistence, paid purchase, multiplayer, Save or Publish test was performed.

### Revised world placement
- Replaced the front Upgrade circle with a five-part work desk in each backroom at a clear location beside the stock area; the prompt remains owner-only.
- Replaced the front Crew circle with a freestanding hiring board and smaller green discovery pad beside each restaurant. Runtime inspection confirmed the prompt is enabled and still uses the selected shop's existing join validation.
- Connected Studio Play created both models for Shop 1 at the expected positions (`DeskTop` 11,4,12 and hiring board -17,6.4,-3); visual inspection confirmed the desk and side sign do not occupy the front service area.
- Single-client Studio could not validate a successful Crew join because the local player already owned that kitchen; two-client validation remains pending.

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
## 2026-10-27 — Visual review for ages 10–15 (heuristic; checkpoint incomplete)
- Confirmed TEST PlaceId 120399989321685 / UniverseId 10772566896. Single-client Studio Play, touch emulator reported 705x338; not a real phone or child-user study. Reviewed spawn HUD, storefront/street, kitchen equipment/food, pantry, town/NPCs, mall and park via temporary camera captures. No shift/cooking interaction or alternate-theme test in this session.
- Strengths: night identity, striped awnings/neon, varied tree colors/fairy lights, lit town windows, recognizable kitchen equipment and pantry ingredients.
- Findings: bright kitchen backsplash/white dishes lose detail; mall has large empty surfaces and products read as simple colored blocks; repeated shop silhouettes and town building shapes; food/menu details small at normal distance; NPC faces present but dark outdoors. Priorities: lighting/material contrast, food silhouettes/garnish, mall product clusters, shop identity and restrained NPC idle/walk animation. These are design judgments, not measured youth preferences.
- Only runtime ScreenGuis/camera changed for inspection; Stop returned to Edit. No intentional source or scene edits; no Save/Publish. Started/reused tools/start_sync.py bridge. Before and after check failed: `Staged source differs from Studio: src/shared/ReplicatedStorage/MidnightStyle/StyleRenderer.luau`.
- Final status: synced, pending [], sceneDirty=true. Checkpoint INCOMPLETE: review staged StyleRenderer against current source; export current Edit assets to staging and compare/review against maintained assets before acknowledging SceneDirty. No dirty flag reset or bridge restart performed. No asset equivalence claimed for this session.

## 2026-10-27 — Kitchen/food/mall visual polish
- Final fresh `python tools/sync_bridge.py check`: PASS (29 scripts acknowledged). Edit mode confirmed, SceneDirty=false, bridge connected; no pending/conflicts. Immediate first post-acknowledgement check saw stale dirty status; subsequent fresh audit passed after bridge exchange, without another reset or restart.
- Environment: confirmed TEST 120399989321685 / Universe 10772566896, single-client Studio Play, touch emulator 705x338. No real phone/child research/multiplayer/paid test. Runtime camera/HUD visibility used for screenshots; removed by Stop.
- Screenshots: default kitchen at normal and close range now preserves backsplash/steel/food colors; Thai Tea has a round cup, orange tea, milk cap, ice, teal sleeve and red straw. Teal bowl/plate edges and larger garnish read clearly. Mall overview and close views of produce, grocery shelves and drink fridges reviewed. Night ClockTime remains 23; no global Lighting edits.
- All 67 RecipeCatalog recipes built through FoodFactory with valid PrimaryPart/nonzero bounds, then probe models destroyed. Includes derived dishes that inherit modified noodle/rice geometry; maximum 214 descendants. This is model-construction coverage, not visual approval of every theme or gameplay coverage.
- All four shops have three ceiling lights at brightness .7. Mall checkout prompt still enabled; actual InputHoldBegin/End near checkout opened visible MidnightMall MallPanel. Server LogService had 0 errors before Stop. Did not purchase supplies or run a full cooking shift.
- MallInterior child count 319 -> 643 (packaging details and three central product displays). Added parts use existing noncollision/nonquery/nontouch helper with small-part shadows disabled. Phone GPU/frame-time impact remains unmeasured; do not infer device performance from the emulator.
- Checkpoint: before edits exported/reviewed all 33 assets (0 differences), acknowledged SceneDirty, updated stale Git staging to current source; fresh sync check passed. Confirmed all four changed Studio Sources before Play. After Stop exported all 33 assets again (first export hit HttpEnabled race with bridge; retry sets HttpEnabled immediately before each request and restores prior value), fresh comparison 0 differences. Binary/XML build and exact source round-trip passed (29 scripts / 33 assets / 62 paths). Reviewed SceneDirty acknowledged. No bridge restart, persistent scene edit, new script, mapping change, Save or Publish.

## 2026-10-27 — Restore original kitchen lighting
- User preferred the original light. Removed only kitchen ceiling runtime brightness/range/color override in ShopService; other visual polish retained.
- Confirmed TEST PlaceId/UniverseId; stopped existing Play. Before edits exported all 33 Edit assets, compared with repository: 0 differences, then acknowledged SceneDirty and passed fresh sync check.
- Verified Studio Source no longer contains override; all 12 Edit ceiling lights across 4 shops have Brightness 2, Range 23 and RGB 255/213/164. Binary/XML build and 29-script exact source round-trip passed. Fresh final sync check passed. No new Play/visual comparison in this small revert; no Save/Publish.

## 2026-10-27 — Kitchen lighting midpoint
- Final fresh sync checkpoint PASS: 29 scripts acknowledged, Edit mode, no pending/conflicts, SceneDirty=false; bridge kept connected.
- Confirmed TEST identity; before-edit sync passed following Stop and 33-asset export/review (0 differences). Set kitchen ceiling Brightness 1.35 / Range 21 and default Color3 midpoint between RGB 255/213/164 and 255/230/201.
- First runtime assertion caught theme() restoring default old color on the owned shop. Updated only its default fallback; equipped theme colors retained. One Play started before the bridge pushed this correction; stopped, confirmed corrected Studio Source, then retested successfully.
- Final single-client desktop Play: all 12 kitchen ceiling lights across four shops matched brightness/range/color (floating tolerance), ClockTime 23; kitchen screenshot reviewed. No full shift/mobile/multiplayer or event test in this small visual change.
- Stop; all 33 assets freshly exported and compared: 0 differences; reviewed SceneDirty acknowledged. Binary/XML build and exact source round-trip passed. No Save/Publish.

## 2026-10-27 — Recipe equipment
- TEST identity confirmed; before-edit sync check passed. Single-client desktop sandbox normal server QA Script built all 11 menus on a temporary six-station probe, checked 12 children (6 stations + 6 equipment groups) and no rebuild on unchanged refresh; probe destroyed.
- Profiles.Mutate selected Cozy Cafe for the real sandbox player; actual runtime gear: Oven/Prep/Coffee/Oven/Grill/Blender. Screenshot inspected. Setting Career.Served alone did not unlock menu immediately in this test, so screenshot is Lv.1 with D–F locked. No full shift or performance test.
- Stop removed runtime QA. Fresh 33-asset export comparison 0 differences; build/source round-trip and final fresh sync check passed. No Save/Publish.

## 2026-10-27 — Coins/Gems storefront decorations
- Normal runtime Script on one real Studio sandbox player (`Profiles.Sandbox` asserted) seeded Coins=1000/Gems=100 with Profiles.Mutate. Mint purchase -> 400/100; duplicate rejected unchanged; Cosmic -> 400/15; Sunset and Sakura insufficient-fund purchases rejected unchanged; unowned equip and wrong-slot placement rejected. Place Mint -> remove -> re-equip Cosmic passed with ownership retained. Plant Corner purchased for 350 Coins -> 50/15.
- Decor UI opened via its real OpenStyleShop BindableEvent. Read actual action labels: Place Front/Entrance, Need 600 Coins (disabled), Get Gems, Remove for equipped Cosmic. UI screenshot shows Coins/Gems badges separately; street screenshot confirms rooftop planet/sign does not replace owner sign/awning. 0 Server LogService errors.
- Existing ShopSaves validates slot against catalog item and copies DecorSlots, so Front fits its schema without migration; cloud persistence/design purchase not tested. Multi-client owner validation unchanged, not re-tested this session. Sandbox funds only; no real Robux/Gem purchase.
- Stop cleaned QA scripts/bridge; 33 fresh asset exports compared with repository: 0 differences. Build/source round-trip passed. No Save/Publish.

