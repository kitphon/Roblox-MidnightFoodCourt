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
2026-10-28 mobile bell + Gems Save Slot: touch devices now get Roblox's tappable Default prompts at the bell/stations (desktop unchanged). Without a Save Slot each join resets Coins, Bank, upgrades, employees, stock and career level (Gems/purchases/decor stay); Save Slot is 150 Gems (`ShopSaveGems`), keeps progress automatically, old pass buyers keep access. Sandbox QA: reset function, Gems unlock/no double charge, UI both states. PENDING: phone/emulator tap on the bell, real DataStore rejoin (needs StudioPurchaseSimulation off or a published test), live pass owner. Existing players without a slot will lose shop progress on their next join after Publish. Bridge synced; check blocked only by the unstaged Git index. No Save/Publish.
2026-10-28 teen-playtest fixes: no interruptions during the whole guide or the final 30 s of a shift (late SHADOW can no longer void the held dish); step 5 text says the guest waits; Upgrade window closes on Escape/Roblox menu/walking >14 studs from the desk. Single-client sandbox (Device Emulator) verified all three plus a normal-shift event control. Synced, build/round-trip OK; edits are unstaged (commit guard). No Save/Publish.
2026-10-28 teen (15–18) playtest, heuristic, no code change: fresh sandbox did 2 shifts (1 served/2 strikes, then 6 served/1 strike), finishing 7/8 orders, one short of Lv.2. Main feedback: frequent fixed-order events; SHADOW at shift end voids the held dish; tutorial pushes to the Upgrade Desk while an order waits; tutorial text clips; no guide to the fuse box; the Upgrade panel does not close on Escape/walk-away; three currencies; Gems-only NPC outfits with no player cosmetics. Sync check passed; no Save/Publish.
2026-10-28 ambient citizen walking: `MidnightGameplay` now smooths replicated citizen roots and poses nearby citizens every rendered frame; `City` replicates only the invisible authoritative route root so server updates no longer fight local limb poses. A 120-frame single-client desktop probe reduced left-arm correction jumps from average/max 0.416/0.796 to 0.116/0.176 studs while retaining 119 moving frames and a 14.0-stud route; all 12 citizens walked, eight distant bodies matched their route roots exactly, street capture reviewed, no new script errors. Binary/XML build and exact source round-trip passed; final Edit/Stop sync check passed for all 29 scripts with no pending/conflicts/SceneDirty. Runtime source-only change; real phone/low graphics/multiplayer/live server not tested. No scene asset, Save or Publish.
2026-10-28 customer-detail pass: `CustomerFlow` runtime guests now have skin-tone hands, shoes, collars/outfit accents, four hair variations and fuller faces; hands/shoes follow the existing walk swing. Guest, Reviewer, Riley and a 3-person Dinner Party were spawned in single-client Studio sandbox; all reached Ordering, party companions cloned correctly, added parts had collision/touch/query disabled, close-up reviewed, no new script errors. XML build/source round-trip passed. Final Edit/Stop checkpoint: 29 scripts synced, no pending/conflicts/unreviewed SceneDirty. Source-only runtime change; no persistent scene asset, Save or Publish.
2026-10-28 commit `d00c8b1` (user-approved `--no-verify`): fresh check passed for the committed files, then the installed plugin logged `stopped` before the hook audit. Bridge is stopped in Studio — reopen the place and confirm `[Midnight Sync] synced` before further edits. Open issue: SceneDirty can re-set shortly after Studio load with 0 scene differences (likely load-time property events). No Save/Publish.
2026-10-27 sync audit: scripts synced (29, no pending/conflicts); 33-asset export vs `assets/` 0 differences; build/round-trip OK. SceneDirty re-set ~1 min after the user's Studio/bridge restart (re-export 0 differences, no ongoing changes; likely load-time event). Restart only the bridge after Studio finishes loading, or acknowledge, before committing. No source/asset change, no Save/Publish.
2026-10-27 task 2: Front decor slot with Mint/Sunset rooftop signs (600 Coins each), Sakura (75 Gems), Cosmic (85 Gems); Plant Corner now 350 Coins, previous ownership retained. Shared price UI + server-catalog currency validation, Profiles.Mutate maintained. Sandbox tests passed currency isolation, duplicate/insufficient/unowned/wrong-slot rejection, placement/removal/re-equip; UI and Cosmic street screenshot inspected, 0 server errors. Stop/export comparison 0 differences; build/source verification passed. No real purchase, cloud persistence test, Save or Publish.
2026-10-27 task 1: recipe-driven station equipment implemented; all 11 menus build six equipment groups with unchanged-refresh identity preserved. Cafe runtime screenshot verified oven/prep/coffee/oven/grill/blender. Sandbox QA only; no full shift. Stop/export 33 assets (0 differences), build/round-trip and fresh sync check passed. No Save/Publish. Continuing storefront purchases and NPC motion.
Midpoint lighting final checkpoint: fresh `tools/sync_bridge.py check` PASS, 29 scripts acknowledged, no pending/conflicts/unreviewed SceneDirty; bridge connected, Play stopped.
2026-10-27 kitchen lighting midpoint (supersedes restore below): Brightness 1.35, Range 21, default RGB midpoint 255/221.5/182.5. Theme fallback updated so claiming a default shop keeps midpoint color; equipped theme colors preserved. Desktop single-client Play verified all 12 lights across 4 shops and screenshot; ClockTime 23. Stop, 33-asset export/review 0 differences, binary/XML builds and source round-trip passed. No Save/Publish.
2026-10-27 user preference: restored original kitchen ceiling lighting by removing the runtime override (12 fixtures across 4 shops retain Brightness 2, Range 23, RGB 255/213/164). Food, backsplash/steel colors and mall polish retained. Source verified in Edit, binary/XML build and round-trip passed; fresh sync checkpoint passed. No new Play test, Save or Publish. Before editing, stopped existing Play and exported/reviewed all 33 assets: 0 differences; acknowledged SceneDirty after review.
2026-10-27 QA (no code change): Waiter role +10% confirmed (49→53 vs 50→50 for a non-Waiter), kicked player rejoins after the 5-minute block. Remaining multiplayer evidence needs a Publish: live server latency and real phones.
2026-10-27 QA (no code change): NPC Chef/Waiter/Technician run a shift alone (4/4 orders, BLACKOUT cleared in 8.2 s, 0 strikes); crew Chef role cooks in 2.4 s, Technician role repair +$15; fifth player refused from a full shop and can open a freed one; Leave/Lock/Kick + 5-minute rejoin block all behave. 0 server errors.
2026-10-27 QA (no code change): 4-player Studio Local Server — full 4-crew race Won 28/0 strikes with the crew lock, NPC Chef never duplicated a player's order and its dish is picked up without stock use, owner disconnect passed Shop1 to the earliest crew member (sign + notice updated, owner-only checks follow). 0 server errors. Minor: unowned abandoned shops show phase Lost until reclaimed.
2026-10-27 crew cooking lock: ShopService `cook()` blocks a second crew member from cooking the current order's dish while a teammate is cooking/holding it. Verified on a 2-player Studio Local Server (refusal + notice, no stock used, set-meal second item, race shift Won 24 served with no new strikes, 0 errors). Synced; no Save/Publish; commit guard = older staged StyleRenderer in the Git index.
2026-10-27 QA (no code change): Studio Local Server 2 players — parallel shops, crew join/owner-only checks, PassMeal, held-dish replication all passed, 0 errors. Duplicate crew cooking is now prevented by the crew cooking lock (same day). Not tested: owner-disconnect heir transfer, 3–4 players, live server.
2026-10-27 QA (no code change): Lv.4 default shop played for real in single-client sandbox — D/E/F orders cooked/served, refill at D, OUT OF STOCK close; Cozy Cafe shift won; Japanese Night/Space Bistro boards+labels match. Open: theme-specific station gear (cafe/burger dishes still sit on noodle pot/wok), multiplayer test needs a user-started Local Server (2 players). Scene 0 differences, scripts synced; commit guard = older staged StyleRenderer in the Git index. No Save/Publish.
2026-10-27 shelf signs + menu order: backroom shelf signs moved on top of the racks (ingredients visible), INGREDIENTS header raised to y 10.6; MIDNIGHT MENU cards mirrored to the physical F→A station order (Lv.1: Thai Tea, Fried Rice, Noodles; Lv.2+ D–F on the upper row). Single-client Play screenshots + probe-model check for Lv.2+. Sync server had stopped; restarted with start_sync.py and an MCP-bootstrapped bridge session (installed plugin still lacks HttpEnabled capability). Scripts synced, 0 scene differences, sceneDirty false; commit guard still blocks on the older staged StyleRenderer copy in the Git index (stage reviewed changes before committing). No Save/Publish.

2026-10-27 product decision (user): mobile portrait is not supported — landscape only. Portrait layout work/testing is out of scope.

2026-10-27 phone card gap: task card shifted 16 px further right; ~15 px gap verified in emulator. Note: after editing scripts, confirm Studio Source has the change before starting Play (bridge push can lag). No Save/Publish.

2026-10-27 larger phone text verified in a user-started emulator Play (685×338, touch): cards readable, no overlaps except guide/task card nearly touching. No Save/Publish.

2026-10-27 larger phone text: guide and task card scale up on touch landscape; KITCHEN button moved above jump. Desktop verified unchanged; phone render NOT yet verified (emulator not active in MCP-started Play) — needs a user-started Play with the emulator. Scripts synced; scene export 0 differences; SceneDirty still set. No Save/Publish.

2026-10-27 touch KITCHEN button: no [M], smaller, bottom-right beside jump, thumbstick clear (verified in phone emulator). Remaining phone UI items: small body text, portrait/cooking-state/mall/management windows, real-device tap test. Scripts synced; scene export 0 differences; SceneDirty still set. No Save/Publish.

2026-10-27 phone emulator verification: guide/stock-card overlap fixed with shared-canvas math and confirmed at 685×338 with touch. Desktop after rework not re-captured (math says unchanged, narrow margin). Open phone UI items: KITCHEN [M] covers thumbstick ring + keyboard hint, small text, portrait/mall/management windows. Scripts synced; scene export 0 differences; SceneDirty still set. No Save/Publish.

2026-10-26 phone-size check (partial): at 732×448 the guide covered the stock card → guide now shifts beside it (desktop unchanged; phone re-check pending because the emulator turned off mid-session, and touch was not emulated). Open UI items: KITCHEN [M] keyboard hint/size on touch, small text, thumbstick vs bottom-left buttons on a real phone. Scripts synced; scene export 0 differences; SceneDirty still set. No Save/Publish.

2026-10-26 phone check blocked: Device Emulator not active in the MCP-visible viewport (1630×761, no touch). Retry once emulation shows a phone resolution and TouchEnabled=true. No changes.

2026-10-26 decor performance: measured ~2,200 runtime decor parts; PC render delta small (worst shop row +1 ms CPU before tweaks). Chase loop now distance-culled and change-only; small decor parts no longer cast shadows (shop row 4.30 ms CPU / 0.64 ms GPU after). Not verified on a phone, Device Emulator or low graphics quality — do that next (Studio Test > Device). Scripts synced; scene export 0 differences; SceneDirty still set. No Save/Publish.

2026-10-26 trees: varied sizes/shapes/colours, bushes and fairy lights for shop tree rows and the park (`City.DressTrees`, called from ShopService.Start and City.Start; `refreshExpansion` shifts `TreeRowDecor` extras). Single-client Studio QA passed visually; dining-expansion shift not tested. Scripts synced; scene export 0 differences; SceneDirty still set — user will clear/restart. Remaining visual-review items: backroom sign placement, menu/station order, citizen walk animation, theme-specific station gear, Station D cook/serve test, mobile perf check of all added decor. No Save/Publish.

2026-10-26 mall interior: see-through display windows and a furnished store (grocery aisles, drink fridges, snack island, checkout details, carts, signage) built at runtime by City.luau `dressMall`. Single-client Studio QA passed; mall supply window still opens. Scripts synced; scene export 0 differences; SceneDirty still set — user will clear/restart. Remaining visual-review items: backroom sign placement, tree variety, menu/station order, citizen walk animation, theme-specific station gear, Station D cook/serve test, mobile perf check. No Save/Publish.

2026-10-26 full-shift regression after station gear: autoplayed 300 s sandbox shift `Won`, 13 served / 1 strike, Bank 500→2010; cook/serve at A/B/C, refills, events and Lv.2 Station D routing all worked; no script errors. Station D cook completion not reached (time ran out after a test-tool refill retry gap). No source changes; scene export 0 differences; SceneDirty still set. No Save/Publish.

2026-10-26 station equipment: noodle pot / wok burner / tea bar gear on all six bays (ShopService `buildStationGear`), menu dish moved to a front-left plating spot (StyleRenderer). Single-client Studio QA passed visually; full cook/serve cycle not re-run. Scripts synced; scene export 0 differences; bridge SceneDirty still set — user will clear/restart. Remaining visual-review items: backroom sign placement, mall interior, tree variety, menu/station order, optional citizen walk animation, theme-specific station gear, mobile perf check. No Save/Publish.

2026-10-26 town lighting/detail: City.luau dresses all five town buildings at runtime with lit windows, trim, entrances, rooftop clutter and per-building props. Single-client Studio QA passed; scripts synced; scene export 0 differences; bridge SceneDirty still set — user will clear/restart. Remaining visual-review items: cooking station models, backroom sign placement, mall interior, tree variety, menu/station order, optional citizen walk animation, mobile perf check of the added decor. No Save/Publish.

2026-10-26 citizen faces/arms: City.luau citizens now have faces, hair styles, visible skin-tone hands and varied palettes. Single-client Studio QA passed; scripts synced; scene export 0 differences; bridge SceneDirty still set — user will clear/restart. Remaining visual-review items: town building lights/detail, cooking station models, backroom sign placement, mall interior, tree variety, menu/station order, optional citizen walk animation. No Save/Publish.

2026-10-26 storefront decor: striped awning, neon name-board frame and client-animated chase bulbs on all four shops (runtime `Storefront` folder from ShopService; MidnightGameplay animates/fades). Owner sign now `NAME'S KITCHEN` in capitals. Single-client Studio QA passed; scripts synced; scene export 0 differences, but bridge SceneDirty still set (MCP clear denied) — acknowledge/restart before committing. Pending from the visual review: town building lights/detail, citizen faces/arms, station models, backroom sign placement, mall interior, tree variety, menu/station order; optional theme-tinted storefront colours. No Save/Publish.

2026-10-26 youth-perspective visual/model review (heuristic, single-client TEST Studio): no source/assets changed. Top visual recommendations: add textures/trim/awnings/neon signs to shop exteriors; light up town building windows and add detail; give citizen NPCs faces/arms like customers; make cooking stations look like real stoves/woks/tea bars with larger labels; move backroom shelf signs above the shelves; furnish the mall interior and make windows transparent; vary trees; fix `NAME'S` sign capitalization and align menu-board order with station order. Scene export compare: 0 differences, but bridge SceneDirty is still set (MCP clear was denied by the permission classifier) — acknowledge it or restart the bridge before committing. Pre-existing staged-index commit guard unchanged. No Save/Publish.

2026-10-26 first-session fixes (patience freeze during guide/events, refill lesson + REFILL FROM BACKROOM task card, next-level goal on SHIFT COMPLETE): implemented and single-client sandbox QA passed; scripts synced to Studio. Follow-up (user-approved): `StationIcon_Ward` was unused except as a misplaced SHADOW highlight, so it was removed from all four shops; reviewed MidnightShops asset promoted, 0 scene differences, bridge synced with SceneDirty=false. The bridge is an MCP-bootstrapped session (installed plugin still lacks HttpEnabled capability). Pre-existing staged-index commit guard remains. No Save/Publish.

2026-10-26 youth-perspective full first-shift playtest (heuristic, not child-user research): fresh sandbox profile completed one 300 s shift with 7 served / 2 strikes, funds 500→1040, Journey 7/8. Recommended next work: order-timer grace during tutorial and while an event is active; a refill tutorial step or larger first-shift front stock; SHIFT COMPLETE showing "N more orders to Lv.2" and the next unlocked dish. Shift 2/Lv.2, backroom refill by normal walking, mobile and multiplayer remain untested. No source/assets changed; bridge synced, SceneDirty=false; pre-existing staged-index commit guard unchanged. No Save/Publish.

2026-10-25 mall supplies: out-of-stock hint shortened to BUS → MALL (fits task card); Supplies tab removed from Kitchen [M]; mall counter opens independent MidnightMall window with per-kit quantity and multi-kit trips (8 crates default, `SupplyTripCrateLimit`), whole delivery stored at any backroom shelf. Kits list their dishes/stations (answering where dishes 4–6 get ingredients: same three shared kit pools A/D, B/E, C/F, sold at the mall). Single-client sandbox QA passed. Scripts synced, build verified, scene export review 0 differences — bridge then restarted as a single fresh session: synced, no pending, SceneDirty=false. Commit guard still needs the reviewed HUD/Management/Inventory changes staged (index holds older pre-session copies). No Save/Publish. Pending: phone layout, non-owner/visitor real clients, Thai strings.

2026-10-25 cooking F timing fix: client sends the marker phase it visibly displayed; server reconciles it only within 0.12 of authoritative timing and preserves active-cook/proximity/one-hit validation. Added debounced F fallback input. Runtime ShopService QA with an actual client F inside gold produced Perfect 97/100; an off-zone input produced Good 68/100. QA runtime objects cleaned by Stop; build/source round-trip and fresh final sync checkpoint passed with Edit SceneDirty=false. No Save/Publish.

2026-10-25 youth-perspective follow-up: replayed the latest first Noodles order in the connected TEST Studio sandbox. The tutorial delivered a clear first success in about 40 seconds after opening (practice Good 70/100, funds 500→538, Journey 0/8→1/8). Heuristic retention estimate is 5–10 minutes for many first-time ages 10–15 players in the current solo Lv.1 loop, and 15–25 minutes for progression-motivated players. Main risk is repetition after the first success and the tutorial's immediate switch to the Upgrade Desk. This is not child-user research or measured analytics. No game source/assets, Save or Publish changed; mobile, multiplayer, full-shift and organic promotion remain untested.

2026-10-25 first-shift clarity: timing UI now clearly says to press F/tap when the white marker reaches gold, highlights the button in-zone, and labels the practice as no-penalty. Missing the training timing grants Good 70/100; post-training misses remain Poor 0/100. Training rejects unrelated ingredient crates with the active dish and station letter. Actual single-client Noodles wrong-crate rejection, no-input training cook, visual timing panel, and post-TutorialSkip Thai Tea Poor regression passed. Build/source round-trip and final fresh sync checkpoint passed with Edit SceneDirty=false. No Save/Publish.

2026-10-25 single cooking row supersedes two-row layout: six 4.1-stud bays now align against rear wall (.15 gap) with .3 gaps and clear stock doorway. Cooktops/labels/dish previews resized and aligned; steam uses station identity. All four plots, 67 preview bounds, actual E Dumplings at D and side aisle navigation checked; final build/sync completed, no Save/Publish. Mobile/multiplayer pending. The earlier youth-playtest staging mismatch is historical; current source audits passed before and after this task.

2026-10-25 youth-perspective first-session playtest (ages 10–15 heuristic, not child-user research): single-client Studio sandbox opened a five-minute shift, cooked/served Thai Tea (Bank 500→526, progress 0/8→1/8), and cleared an early blackout. Strong visual identity/task imagery and quick reward; concerns are unclear timing input and nearby interaction ambiguity—the Fried Rice order ended with Noodles ingredients and Station A guidance. Session stopped before full shift/promotion; mobile, multiplayer and organic progression remain untested. No game source/assets, Save or Publish changed. Task checkpoint is incomplete because the pre-existing staged `StyleRenderer.luau` differs from Studio; preserved without overwrite. See TESTING.md.

2026-10-25 six fixed cooking bays: every plot generates ABC rear row and DEF front row; 3/4/5/6 available at ranks 1/2/3/4, rank 5 retains six. Locked bases show unlock levels. Recipe CookingSlot/Station is fixed; ingredient Slot/StockId remains three shared pools. Dumplings now D, Chicken Rice E, Lemon Tea F; HUD/crates/ready pickup follow new locations. All four plots, 75 unique theme/rank combinations, actual E D refill/cook, synthetic E/F refill/bundle/ready pickup/signature and side aisle navigation passed in sandbox. Final build/sync checked; no Save/Publish. Mobile/multiplayer/owner-transfer regression pending. This supersedes earlier pending-order replacement of ABC station dishes.

2026-10-25 expanded-recipe refill fix: Inventory.Take/Restock normalize recipe IDs to shared stock IDs before validation, resolving Dumplings crate rejection. Shelf prompt/crate label/carrying and refill HUD show the pending recipe; B/C shortage directions use correct shelf. Actual E zero-stock Dumplings take→refill→cook passed; 67 recipe/bundle resolver checks, B/C/legacy refills, wrong-slot rejection and old transit compatibility passed in sandbox. QA cleaned; final build/sync checked, no Save/Publish. Mobile/multiplayer/mall delivery regression pending.

2026-10-25 Upgrade separation/surfaces: desk opens independent MidnightUpgrade window (no Upgrade branch in M). Own funds/deposit/status/close and responsive grid; M switches to management. Backroom walls/office divider and both extended floors match main shop colors/materials, including later expansions and theme changes. Fifteen theme variants x Dining levels 1–3 passed exact surface checks (45 cases); actual E, UI purchase, M and independent close passed; desktop/Retro Diner visuals reviewed. QA cleaned, build/sync checked; no Save/Publish. Real-phone/multiplayer pending.

2026-10-25 Upgrade/M fix: desk Upgrade is no longer remembered after closing. M/Kitchen and generic management routes return Overview; server world-desk event still opens Upgrade. Actual E desk/revisit, sandbox Kitchen Lv.1 purchase and storefront M reopen passed; final build/sync checked. No Save/Publish. Mobile/multiplayer regression pending.

2026-10-25 Shadow/seating: SHADOW now spawns a separate non-colliding apparition three studs behind the radio, with relocated Banish Shadow interaction. Shop lights slowly dim/pulse until banishment; SHADOW no longer times out or disappears on a serving mistake. Held meals stay intact; existing Technician resolution and shift/close cleanup remain. Removed all career-rank automatic dining tables; seating requires Space or Decor purchases. Single-client sandbox actual E banishment/restored brightness, expired deadline, close cleanup, all four starter plots, rank 1–5 fixtures and Space 1–3 purchase/table counts passed. Temporary QA removed; final build/sync checkpoint checked, no Save/Publish. Multiplayer/mobile and separate Technician/shift-end regression remain pending.

2026-10-25 Lv.2/Dining repair: Pork Dumplings and other pending recipes now replace the station's default prompt/model (Pork Dumplings uses A); cooked/pickup/bundle states preserved. Dining roof matches main roof; expanded rooms use only their own table layout, rank patio tables are hidden while expanded and Decor becomes rear planters. Trees shift clear. Rank-2 seeded order cooked via actual E input; 67 presentation routes/bundles and 12 dining/rank geometry combinations checked, plus Decor 3 clearances. Temporary QA/export helpers stopped/cleaned; final build/sync checked, Edit SceneDirty=false. No Save/Publish. Multiplayer/owner-transfer and real-phone regression remain pending.

2026-10-25 rank plaque placement: moved Corner Kitchen/reputation plaque to the adjacent wall area, leaving 2.25 studs clear of the themed food board. Single-client default menu screenshot and geometry check passed; source build/sync checked after Stop. No Save/Publish.

2026-10-25 station label placement: A/B/C guides now mount on station base front faces, retaining stock-matching colors and text. All 12 panels verified within base bounds; Shop1 visual review passed. Final build/sync checked after Stop; no Save/Publish.

2026-10-25 scene artifact fixes: hiring/Upgrade SurfaceGuis now AlwaysOnTop=false; office board/papers moved entirely in front of rear wall; pavement ends three studs behind room and matching rear grass tile is trimmed to meet it (runtime, no Edit asset replacement). Four-plot checks found zero see-through sign flags, wall-intersecting board/papers or pavement/grass overlap. Single-client interior/exterior/walking visuals checked; final build/sync completed after Stop. No Save/Publish.

2026-10-25 ingredient guidance: StyleService generates A/PREP, B/KITCHEN, C/DRINKS shelf and station signs; shelf food names derive from current unlocked recipe slots and update for theme/level/signature changes. Inventory pickup notices/prompts and HUD directions share the letters. Actual default client/pickup visual QA plus isolated 55 theme-level cases/signature substitution passed. Final build/sync checked; no Save/Publish. Fresh scene export/review resolved a pre-edit sceneDirty flag with zero semantic asset differences.

2026-10-25 rack alignment: shelves moved against INGREDIENTS divider with .15-stud clearance and uniformly scaled to 95%, including bins/count plates, ingredient props and sibling box icons. Four-shop geometry/scale checks, Shop1 stock pickup, office navigation and visual inspection passed. Final build/sync completed after Stop; no Save/Publish. Earlier 2.45-stud rear clearance is superseded by this intentional wall alignment.

2026-10-25 Stock spacing fix supersedes 32x8 pantry: Stock now 32x11, Office depth unchanged at 14, total backroom 32x25. Detached sibling stock icon models were the wall-overlap cause; they now move with bins/count labels. All four plots passed world-space corner checks (zero office crossings, minimum 2.45 studs clearance), Shop1 stock pickup and aisle-to-office navigation passed in sandbox. Final build/sync checked after Stop; no Save/Publish.

2026-10-25 pantry revision supersedes the larger stock layout: Stock depth 14→8 studs (~43% smaller), total backroom 32x22. Lower racks now show ingredient sacks, vegetables in open crates and tea jars; small receiving bench replaces pallet/trolley clutter. Office retains its usable depth, shifted forward with the partition. Stock pickup and final stock-to-office no-jump path passed in single-client sandbox; food props visually inspected. Final build/sync checkpoint recorded; no Save or Publish.

Stock/office furnishing completed 2026-10-25: stock racks, reserve cartons, receiving bench/pallet/trolley; office computer desk, keyboard/mouse/tower/lamp, usable chair, filing cabinet and noticeboard. All four plots generate this from ShopService. Shop1 sandbox stock take/refill, actual E upgrade panel, chair occupancy and navigation path passed; both rooms visually reviewed. Old sceneDirty blocker resolved after 33-asset staged export and zero semantic scene differences; no asset overwrite needed. Local token rotated to isolate duplicate bridge sessions. Temporary export receiver stopped; bridge stays connected. Final sync/build checked; no Save or Publish. Prior pending furnishing/white-capture notes below are historical and superseded.

2026-10-25 workflow update: AGENTS.md/SYNC.md require a sync/export checkpoint after every task before completion or further task work. Current stock/office furnishing request remains incomplete: sync reports sceneDirty and the Edit scene needs comparison and reviewed asset export. This documentation change does not clear that blocker; no Save or Publish performed.

Backroom expanded on 2026-10-25: 32x28 with front Stock room, rear Office, partition/six-stud doorway and relocated Upgrade Desk. Generated by ShopService at runtime for all four plots. Runtime geometry and build passed; visual capture returned white, so walk-through/visual QA remains pending. No Save or Publish.

Navigation wording corrected on 2026-10-25: upgrade tutorial points to the backroom desk, Save Slot unlock notice points to Overview > Save / Load design, Travel guidance includes More options, and shop return button reads Back to Kitchen. Build/source checks passed; no Save or Publish. Installed plugin autostart still needs investigation; existing bridge was bootstrapped for this session.

1. Removed obsolete Co-op directions from the post-kick/no-kitchen state.
   - HUD now opens Overview and explains the two valid paths: open a vacant kitchen or use another restaurant's green `NOW HIRING` sign.
   - Kick/leave/full-capacity server messages match this flow; the five-minute ban remains scoped to the kicking owner's kitchen.
   - Single-client UI-state simulation passed; a real two-client kick/rejoin/different-crew test remains pending.
2. World-first restaurant management now places an Upgrade work desk in every backroom and a green Crew hiring sign beside every kitchen.
   - The desk is owner-only and opens the existing validated upgrade panel; the hiring sign joins that specific available kitchen.
   - Upgrade/Co-op were removed from main navigation; legacy Co-op routes show Overview/world guidance.
   - Dining Area levels 1–3 visibly extend the covered shop floor, open the side wall and add seating.
   - Main management/world-action Thai strings follow `RobloxLocaleId`; English is the fallback. Thai emulator QA is pending.
3. Removed Kitchen Crew popup, replaced PassMeal button with a local ProximityPrompt on eligible teammates.
   - Hold E for .25s, 7-stud range; same kitchen, empty-handed/non-cooking receiver.
   - Mobile tap / gamepad Y. Existing server validation remains authoritative.
   - Sender: Dish passed to [name]; receiver: Dish received from [name].
4. ServerScriptService.MidnightHeldDishes creates a replicated welded dish on the character from MidnightState.Held.
   - Removed the local-only world clone from MidnightCityHUD.
   - Clears/replaces on state changes, death, respawn and departure.
5. Expanded 11 themes to 6 recipes each (66 themed recipes + Signature Chicken Rice).
   - Start 3; additional dishes at restaurant levels 2/3/4.
   - Reuses existing kit categories and cooking stations; variants reuse canonical geometry.
   - Journey shows unlock levels; FeatureDish supports 6 menu indices.
   - Menu board uses 3 columns x 2 rows; station props avoid overlapping duplicate dishes.
6. MealBundles introduces main + drink sets after level 2 and training.
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
1. Test world Crew signup with two real clients and Thai locale/device emulation; review circle labels/positions on phone and gamepad.
2. Test Dining Area levels 2–3 with every Decor level/theme and verify seating/roof/wall do not overlap styled assets.
3. Test latest E give-dish interaction with two real clients, including transfer feedback and receiver-full/too-far cases.
4. Confirm replicated held dishes are seen by a second client through cooking, transfer, serving and respawn.
5. Two-client set-meal test: cook main/drink concurrently, deliver drink first, avoid duplicate payouts, verify client HUD sync.
6. Set-meal edge cases: sold-out second item, menu change, timeout, closing/reopening, blackout/shadow, party/reviewer/regular behavior, owner transfer.
7. Review all six-dish board visuals and recipe variants per theme; visual inspection so far was not exhaustive.
8. Device Emulator check of set order card and Journey cards on narrow screens.
9. Balance set payout 2.2 and unlock pacing using real player feedback.
10. Save and Publish the reviewed build; join a new server and record the exact deployed verification.
11. Paid checkout remains untested; prefer no-cost tests until user explicitly authorizes any spend.

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
## 2026-10-27 — Latest visual review; checkpoint incomplete
- Youth-perspective visual review in single-client touch-emulated Studio Play (705x338); heuristic only, no real children. See TESTING.md. No game source/assets changed. Suggested priorities: reduce washed-out kitchen lighting, improve food readability, furnish mall displays more densely, distinguish shop silhouettes/colors, add restrained NPC movement.
- Play stopped; bridge connected/synced with pending [], but sceneDirty=true. Fresh `tools/sync_bridge.py check` failed on older staged `src/shared/ReplicatedStorage/MidnightStyle/StyleRenderer.luau`. Remaining: review/reconcile Git staging; export/review Edit assets against repository before acknowledging SceneDirty, then fresh successful check. This session's required checkpoint is incomplete. No Save/Publish.

## 2026-10-27 — Kitchen/food/mall visual polish
- Final fresh `python tools/sync_bridge.py check`: PASS, 29 scripts acknowledged; Edit mode, synced, pending [], SceneDirty=false. This supersedes the earlier incomplete visual-review checkpoint below.
- Implemented first three visual-review priorities: softer local ceiling lights, darker kitchen backsplash/steel, teal noodle bowl/rice plate rims with clearer garnish, round layered Thai Tea cup; slightly larger station dish previews. Mall packaging has bands/can lids/bottle caps; central supply tables now show pantry bags, produce and tea tins with English labels.
- Single-client touch emulator (705x338): kitchen and mall screenshots reviewed; actual mall checkout prompt opened supplies panel; all 67 recipe models built; 0 server errors. Real-device performance/full shift/other themes' appearance not tested in this session. MallInterior grows 319 -> 643 children; new decorations are static and do not collide.
- Earlier staged-index/SceneDirty blocker reconciled: staged current source (no commit); before-edit check passed. Final Stop/export of all 33 Edit assets compared with repository: 0 differences; reviewed SceneDirty acknowledged; binary/XML build and 29-script round-trip passed. No persistent scene edits or mapping changes. No Save/Publish.


## 2026-10-28 — Latest visual review checkpoint
- Current desktop runtime inspected; design suggestions remain proposals: vary shop/building silhouettes, improve food material contrast, dress mall walls/checkout, give empty outdoor space a focal point. No source/assets changed; FEATURES unchanged.
- Play stopped; bridge connected, state=synced, pending=[], SceneDirty=false; fresh tools/sync_bridge.py check PASS (29 scripts). This session confirms the bridge is now connected, superseding the earlier stopped-bridge status. No Save/Publish. Testing limits and failed automated route are recorded in TESTING.md.

## 2026-10-28 — Storefront food mascots
- Existing Front IDs now render as Noodle Bowl Mascot and Fried Rice Mascot (600 Coins each), Sakura Dumpling Mascot (75 Gems), and Cosmic Thai Tea Mascot (85 Gems). IDs were preserved for prior owners; server-owned catalog pricing, Profiles.Mutate and saved Front-slot validation remain intact.
- Single-client Studio sandbox verified real StyleBuy currency isolation, insufficient balances, all four StyleEquip placements and desktop street visuals. Runtime QA objects were removed; no paid/cloud/multiplayer/real-phone test.
- Source-only change in StyleCatalog/StyleRenderer; no persistent Edit model or mapping change. XML build/source round-trip passed. Final state: Edit/Stop, bridge synced, 29 scripts acknowledged, pending=[], conflicts=nil, SceneDirty=false. No Save/Publish.
