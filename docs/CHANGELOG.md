# Change history

## 2026-10-28 — Mobile bell fix; Save Slot now Gems and gates shop progress
- MidnightCityHUD: on touch devices every shop prompt uses Roblox's Default (tappable) style instead of the invisible Custom style, so phones get an on-screen button at the golden bell and stations; desktop/gamepad keep the Custom style. The task-card hint reads "Tap here or the button" on touch.
- ShopSaves: without a Save Slot, each join resets Coins, shop Bank, upgrades, employees, stock, career level/served counts, Riley visits, regular favorites, last review and house-special slot to starter values. Gems, owned items, receipts, equipped looks, placed decorations, the saved design slot, quests/login, tutorial and settings always persist. The reset is skipped if pass ownership cannot be confirmed (lookup failure with no cache).
- Save Slot is unlocked permanently for 150 Gems (`MonetizationConfig.ShopSaveGems`, new `SaveBuyGems` command, server-validated through Profiles.Mutate, no double charge). Owners keep automatic progress persistence between visits. The Robux pass button is removed; earlier pass buyers still have access.
- Kitchen > Save / Load design shows the Gems price, "Need N Gems" when short, and a "Fresh start each visit" explanation for players without the slot.

## 2026-10-28 — Teen-playtest fixes: events, upgrade step, Upgrade window
- ShopService no longer starts interruptions during the whole guide (step 5 Upgrade Desk included; previously only steps 1–4) or in the final EventSeconds+10 seconds of a shift, so a late SHADOW can no longer block serving and void the held dish at shift end.
- Guide step 5 text now reads "Buy an upgrade at the backroom Upgrade Desk. Your next guest waits for you." (patience was already frozen; events no longer cost hearts there).
- MidnightManagement: Escape closes the Upgrade/Mall window even though Roblox marks Escape as processed; the Roblox menu opening also closes them; the Upgrade window closes when the player is more than 14 studs from their shop's desk.

## 2026-10-28 — Teen-perspective playtest (no game change)
- Recorded a heuristic 15–18 playtest in TESTING.md. No source, assets or behavior changed.

## 2026-10-28 — Smooth ambient-citizen walking
- Ambient citizens now animate locally every rendered frame instead of stepping at 20 Hz. Framerate-independent damping smooths replicated route position, facing, walk speed and walk/idle blending while retaining the existing opposite arm/leg swing, body bob, breathing and idle head look.
- `City` now replicates only each citizen's invisible authoritative route root; visible anchored body parts are posed from `CitizenRest` on each client, removing the server/client CFrame fight that caused arm and leg snapping. Routes, schedules and permanent nighttime behavior are unchanged.

## 2026-10-28 — More detailed food-court customers
- Runtime customer models now have skin-tone hands, shoes, collars, outfit accents, four deterministic hair variations and fuller faces (brows, eye shine, nose, smile and skin-adaptive blush). Caps gain a brim and casual outfits vary between a chest stripe and pocket.
- Hands and shoes follow the existing arm/leg walking swing. All added parts remain anchored runtime decoration with collision, touch and query disabled; customer flow, order logic and special-guest behavior are unchanged.

## 2026-10-28 — Commit d00c8b1
- Committed all Studio-synced scripts, reviewed MidnightShops asset, docs and `tools/review_scene.py` (hook bypassed with user approval after a passing check). No game changes.

## 2026-10-27 — Sync audit only
- No game source or asset changes. Scripts synced (29); full 33-asset scene export 0 differences; SceneDirty still awaiting user acknowledgement. See TESTING.md.

## 2026-10-27 — QA only: Waiter role bonus, kick block expiry
- No game source or asset changes. Waiter role adds 10% (49→53) and a non-Waiter gets none; a kicked player can rejoin after the 5-minute block. See TESTING.md.

## 2026-10-27 — QA only: NPC workers, crew roles, full shop, lock/kick
- No game source or asset changes. Local Server multi-client tests of hiring, NPC Chef/Waiter/Technician running a shift alone, crew Chef/Technician role perks, fifth player vs full shop, Leave/Lock/Kick and the 5-minute rejoin block. See TESTING.md.

## 2026-10-27 — QA only: 4-player crew, NPC Chef + crew lock, owner disconnect
- No game source or asset changes. 4-player Local Server: full crew race (Won, 28 served, 0 strikes), NPC Chef cooperates with the lock (no duplicates, players pick up the chef dish without using stock), owner disconnect hands the shop to the earliest crew member. See TESTING.md.

## 2026-10-27 — Crew cooking lock
- ShopService `cook()`: while one crew member is cooking or holding the current order's dish, other members cannot start the same dish (English notice "<Name> is already making <Dish> for this order"; no stock consumed). Prevents duplicate dishes that later became wrong-dish strikes. Cooking other dishes ahead is unchanged.

## 2026-10-27 — QA only: 2-player Local Server
- No game source or asset changes. Two owners played their own shops at the same time; crew join, owner-only checks, crew cooking, PassMeal and held-dish visibility tested. See TESTING.md.

## 2026-10-27 — QA only: Lv.4 shop and other themes
- No game source or asset changes. Single-client sandbox Play tests of a Lv.4 shop (all six stations A–F cooked and served with game-spawned orders) and of the Cozy Cafe, Japanese Night and Space Bistro themes. See TESTING.md.

## 2026-10-27 — Shelf signs above the racks; menu board in station order
- StyleService `UpdateIngredientGuides`: the backroom shelf signs (`StockGuide_1..3`, e.g. "A + D / PREP" with dish names) now sit on top of each rack, centred over it (bin position + (0, 6.15, 0); bottom ~0.3 stud above the rack posts) instead of hanging in front of the upper shelf, so the ingredient crates/sacks/jars are no longer covered. Bin ProximityPrompts unchanged.
- ShopService `buildBackroom`: the INGREDIENTS header on the divider wall is raised from y 8 to y 10.6 (just under the backroom roof) so it stays readable above the moved signs.
- StyleRenderer `BuildMenu`: MIDNIGHT MENU cards are mirrored to match the physical station line seen from the dining side (F E D C B A, Station A on the right). At Lv.1 the row reads Thai Tea, Fried Rice, Noodles (C, B, A); once D–F unlock they take the upper row (F E D) and A–C move to the lower row, so the board reads F→A left to right. Column/row now follow each dish's `CookingSlot`. Stations, prompts, tutorial and HUD unchanged.

## 2026-10-27 — Gap between guide and task card on phones
- MidnightCityHUD: the landscape-touch task card now starts 24 px (was 8) past the left-40% thumbstick zone, leaving a visible gap after the first-shift guide.

## 2026-10-27 — Larger tutorial and task cards on landscape phones
- MidnightGameplay: on touch landscape the first-shift guide gets UIScale clamp(.71/canvasScale,1,1.35) and its height is included when placing it above the bottom row; the guide baseline stays at the old bottom-left button height.
- MidnightCityHUD: on touch landscape the OPEN SHOP/task card scales the same way, keeps its bottom edge, and is pushed right of the left-40% thumbstick zone; its subtitle uses TextSize 17 on touch (was 14).
- KITCHEN button on touch now sits just above the jump button (1,-16,1,-102 on small screens) so the bottom row is free for the larger task card.

## 2026-10-27 — KITCHEN button off the phone thumbstick
- MidnightManagement names the button `KitchenButton`; on touch devices it reads "KITCHEN" (Thai "ร้านอาหาร") without the [M] key hint and is 124×40.
- MidnightGameplay finds it by name (the old text search missed the Thai label) and, on touch when not cooking, anchors it bottom-right just left of Roblox's jump button (small screens: right edge at -107; large: -182; portrait: above the jump button), clear of the left-40% dynamic thumbstick zone. The cooking-time positions are unchanged. The first-shift guide keeps the left edge on touch instead of following the button.

## 2026-10-27 — Guide/stock overlap check uses shared canvas coordinates
- The 2026-10-26 overlap fix compared AbsolutePosition across ScreenGuis, which did not match the rendered layout under Studio device emulation (guide stayed on top of the stock card). It now compares in the 960×640 canvas that MidnightCityHUD and MidnightGameplay share (StockCard at leftEdge,325, 148×134 at .9 scale) and moves the guide to the card's right when guideY is above the card bottom.

## 2026-10-26 — Guide card no longer covers the stock card on short screens
- MidnightGameplay: when the first-shift guide (above the KITCHEN button) would overlap the HUD StockCard, it moves to the right of the stock card at the same height. Desktop layouts where they do not overlap are unchanged.

## 2026-10-26 — Decor performance tweaks
- Storefront chase loop animates only shops within 220 studs of the camera and writes Material/Color/LocalTransparencyModifier only when the value changes.
- City decor helpers (town, mall, trees) disable CastShadow on small parts (size magnitude < 2): fairy lights, flowers, products, bottles, fruit, etc.

## 2026-10-26 — Varied trees, bushes and fairy lights
- New `City.DressTrees(model,trunkName,crownName)` resizes/reshapes existing trunk/crown parts at runtime and adds TreeExtra/TreeBush/BushFlower/FairyLight parts (non-collide/non-query). ShopService calls it per shop in Start; City calls it for the park. `refreshExpansion` now also shifts parts with the `TreeRowDecor` attribute, and DressTrees refreshes any existing `DiningTreeBaseCFrame`.

## 2026-10-26 — Furnished Midnight Mall with see-through windows
- City.luau `dressMall` hides each solid FrontWall segment (Transparency 1, no collide/query) and builds framing pieces around its DisplayWindow, then makes the glass 75% transparent; adds interior lighting, wall dressing, grocery aisles, drink fridges, snack island, checkout details and carts. All runtime-only; the Edit-mode mall asset is unchanged.

## 2026-10-26 — Full-shift regression check (no code changes)
- Verified one full sandbox shift after the station equipment change; results in TESTING.md.

## 2026-10-26 — Real-looking cooking stations
- ShopService `buildStationGear` (called from `buildCookingStations`) adds decorative non-collide/non-query equipment to all six bays by kit: noodle pot (A/D), wok burner (B/E), tea bar (C/F), plus backsplash, kick plate and knobs.
- StyleRenderer places the station menu dish at a front-left plating spot capped to a 1.6-stud footprint (was centered, filling the top) so it does not overlap the gear.

## 2026-10-26 — Lit, detailed town buildings
- City.luau `dressBuilding` runs at City.Start for every MidnightCity model with Building/Sign parts: recolours existing front windows (deterministic ~8/9 lit in warm or TV-blue Neon, rest dark), adds window crosses/sills, three side windows per floor on both sides, plinth/floor band/roof neon strip, sign PointLight + neon underline, lit door with frame/awning/lamp/step, rooftop AC units and antenna, and a signature prop set per building. Window tones are deliberately darker because Neon + Bloom blew pale values out to white.

## 2026-10-26 — City citizen faces and arms
- City.luau citizens now get a face on the walking (-Z) side (eyes + shine, blush, two-piece smile), hair (short/cap/long/bun by index), sleeve + skin-tone hand arms, shoes, and varied skin/hair/pants palettes; shirts are brighter for night readability. The old arms existed but were the shirt colour and blended into the body.

## 2026-10-26 — Storefront awning, neon frame and chase lights
- ShopService `buildStorefront` creates a runtime `Storefront` folder per shop: striped awning + valance + warm ShopLight glow, neon frame inside the name-board edges, chase bulbs on both front posts and the roof edge. All parts are non-collide/non-query.
- Shops expose `StorefrontLive` (has owner) and `StorefrontPower` (set by `lights`, so BLACKOUT darkens the front). MidnightGameplay animates the bulbs locally (0.15 s step) and fades the awning (LocalTransparencyModifier 0.85) while the camera is inside the awning box.
- Owner sign uses `DisplayName:upper().."'S KITCHEN"`, fixing the mixed-case `name'S` look.

## 2026-10-26 — Visual/model review (no game changes)
- Youth-perspective screenshot review of shops, stations, backroom, town, mall and NPCs; recommendations recorded in HANDOFF/TESTING. No source or assets modified.

## 2026-10-26 — Removed misplaced StationIcon_Ward
- Deleted `StationIcon_Ward` from all four shops (assets/Workspace/MidnightShops.rbxm). It sat at the Ward's old Edit position, so the SHADOW task highlight pointed ~17 studs away from the runtime Ward behind the radio; the HUD now falls back to the Ward itself.

## 2026-10-26 — First-session fixes from youth playtest
- Customer patience is frozen while an interruption (BLACKOUT/WHISPER/SHADOW) is active and while the shop owner is in the five-step guide (`Experience.TutorialActive`, TutorialStep ≤ 5); events no longer silently drain the order timer.
- One-time refill lesson: when the active order's front stock is empty and the backroom has stock, the guide shows `NEW • REFILL 1 / 2` (take a crate from the highlighted shelf) then `2 / 2` (bring it to the station); completes on the first successful refill (`RefillTaught` profile flag, exposed as a state attribute). The task card now says `REFILL FROM BACKROOM` and targets the shelf instead of `MENU UNAVAILABLE` while back stock remains.
- SHIFT COMPLETE shows the next goal: "N more orders to Lv.X • unlocks <dish>" (or the next Legend Star).

## 2026-10-26 — Youth-perspective full first-shift playtest
- No code changes. Played a full first shift on a fresh sandbox profile: 7 served, 2 strikes, funds 500→1040, Journey 7/8 (one short of Lv.2).
- Recorded friction: no tutorial grace on the order timer while tutorial/events overlap, first-shift front-stock depletion with no refill tutorial, and a SHIFT COMPLETE panel that does not show the remaining orders to the next level. Heuristic retention ~8–12 minutes for typical first-time ages 10–15. See TESTING.md.

## 2026-10-25 — Mall supply window, multi-crate trips, kit clarity
- Out-of-stock task hint now reads "Go to the BUS stop, then buy supplies at the MALL" and wraps inside the task card; menu directions removed. OPEN/CLOSED sign hint no longer points to Kitchen → Supplies.
- Removed the Supplies tab from Kitchen [M]; legacy `Stock` routes open Overview. Overview supplies card is info-only (front/backroom per kit + mall hint).
- Mall supply counter opens an independent `MidnightMall` window (not the Kitchen menu): per-kit quantity stepper, total price, carried-crate counter, "Your delivery" summary and courier card for visitors. Closes on ×, Escape or walking away from the counter.
- `Inventory.Buy` accepts `KIT:count` and stacks purchases of different kits into one delivery (default `SupplyTripCrateLimit` 8 crates per trip; still owner-only, near-counter, empty-hands, shop-funds validated inside `Profiles.Mutate`). Any backroom shelf stores the whole delivery into each kit's own pool. Legacy single-kit delivery bags remain compatible for Deliver/Return/Recover.
- Kit clarity for dishes 4–6: snapshot lists the dishes each shared kit feeds (with station letter or unlock level); mall cards show them and the HUD stock card labels each row with its unlocked stations (e.g. `A D`). HUD now refreshes on shop MenuLevel/SignatureMenu changes.

## 2026-10-25 — Youth-perspective follow-up playtest
- Replayed the latest first-order tutorial in the connected TEST place as a single desktop client: Noodles practice completed Good 70/100, served successfully, funds 500→538 and Journey 0/8→1/8 in about 40 seconds after opening.
- Recorded a heuristic 5–10 minute likely first-session tolerance for the current solo Lv.1 loop, with 15–25 minutes plausible for progression-motivated players. Flagged the immediate post-order Upgrade Desk handoff and early three-recipe repetition as retention risks.
- Documentation-only session; no game source/assets, Save or Publish changed. Mobile, multiplayer, full-shift and organic-promotion playtests remain pending.

## 2026-10-25 — Single wall-aligned cooking row
- Arrange all six bays in one rear-wall row: 4.1-stud bases, .3-stud gaps and .15-stud wall clearance, keeping the stock doorway clear. Unlock progression unchanged.
- Fit mounted labels and all canonical dish previews to the narrower bays; relocate/resize original cooktops and clone matching tops for the extra bays. Steam follows explicit station identity.
- Four-plot geometry/cooktop checks, all 67 dish preview bounds, Lv.1/Lv.2 visuals, actual E Dumplings cooking at D and right-side stock-entry navigation checked. Source build/sync completed; no Save/Publish.

## 2026-10-25 — Six fixed cooking bays with rank unlocks
- Every kitchen now starts with two rows of three physical cooking bays. A/B/C open at rank 1; D/E/F unlock at ranks 2/3/4 respectively, retaining visible locked bases and unlock labels before availability.
- Each menu item has its own fixed CookingSlot/Station. Orders no longer replace A/B/C dishes; Dumplings is D. Server callbacks resolve only unlocked menu entries, with disabled locked prompts and consistent model/guide states.
- Keep ingredient Slot/StockId compatible with the three existing shared kit categories. Crate guidance follows the selected recipe's cooking bay, and matching unlocked bays can refill their ingredient pool. Ready pickup, bundle, signature and HUD targeting use the six-bay map.
- Verified all four kitchens, 55 menu/rank combinations plus 25 default/legacy rank combinations, actual E Dumplings refill/cook at D, E/F refill, ready F pickup, bundle acceptance, signature B and side-aisle navigation. Build/sync checked; no Save/Publish.

## 2026-10-25 — Expanded-recipe ingredient refill repair
- Normalize recipe IDs to their shared station stock IDs before Take/Restock validation. A Pork Dumplings station can now accept its Prep kit crate; previously MK_DUMPLINGS was compared directly to NOODLES and rejected.
- Backroom prompts, carried-crate label and carrying/refill HUD identify the pending recipe, including bundle slots. Existing stock IDs/counts/capacities remain compatible; old transit bags derive recipe context.
- Fix empty-front-stock guidance for expanded B/C recipes so each points to its correct shelf rather than falling back to A.
- Seeded rank-2 sandbox: actual E took three kits, refilled Station A from zero to three, cooked and held Pork Dumplings, leaving two front kits. All 67 recipe selections plus bundle routing, B/C/legacy refills and wrong-slot rejection checked. Build/fresh sync completed; no Save/Publish.

## 2026-10-25 — Separate Upgrade window and consistent shop surfaces
- Desk E opens a separate MidnightUpgrade ScreenGui with its own cards, funds, deposit, feedback, close button and responsive scrolling. Upgrade content is removed from the M menu; M switches back to management without retaining Upgrade.
- Backroom exterior walls, office divider/door sections and backroom floor now match the main shop surfaces. Dining floor inherits the main floor color/material, including when added after a theme is already equipped.
- Checked 15 default/current/legacy theme variants across Dining Area levels 1–3 (45 sandbox cases). Actual E, separate UI purchase, M routing and independent close tested. Source build/sync checked; no Save/Publish.

## 2026-10-25 — Upgrade desk page no longer remembered by M
- Closing Upgrade resets its remembered destination to Overview. M/Kitchen cannot reopen a cached Upgrade page; only the server world-desk OpenPanel event opts into opening it.
- Generic OpenMidnightManagement Upgrade requests redirect to Overview. Other remembered management tabs remain unchanged.
- Single-client sandbox: actual desk E, Kitchen level-1 purchase through validated remote, storefront M reopen, repeated desk visit and generic-route regression passed. Build/fresh sync checked; no Save/Publish.

## 2026-10-25 — Shadow relocation, persistent flicker and purchased seating
- Spawn a separate non-colliding Shadow behind the radio instead of recoloring the ordering customer; move the validated Ward interaction there and update directions.
- Slowly pulse shop-light brightness while SHADOW remains. Restore original light levels on resolution/closure; remove automatic Shadow timeout and prevent serving from consuming food or dismissing the apparition. Existing Technician resolution remains.
- Remove career-rank patio tables and update Journey reward wording. Starting kitchens have no dining tables; seating comes from purchased upgrades.
- Verified single-client sandbox banishment with actual E, restored brightness, forced expired deadline, closure, four starter plots, five rank fixtures and purchased Dining Area levels 1–3. Source build/sync checkpoint completed; no Save/Publish.

## 2026-10-25 — Lv.2 cooking guidance and Dining Area repair
- Stations now show the pending recipe name and canonical dish model, including Pork Dumplings at Station A. Prepared-meal pickup still takes precedence; bundle orders can preview different pending dishes at two stations.
- Applied pending-recipe presentation after style rendering, preventing base theme names from overwriting the active recipe prompt.
- Dining roof now matches the main roof height, thickness/depth/material and joins at its edge; support posts reach its underside.
- When Dining Area is expanded, rank patio tables are suppressed and Decor adds interior rear planters instead of a second outside table row. Rank/decor earnings remain unchanged. Right-side decorative trees move clear of expanded seats/roof.
- Sandbox actual-player E cooking produced Pork Dumplings at rank 2; 67 recipe presentation routes and bundle cases checked. Dining levels 1–3 x ranks 2–5 had no outside/stray tables; planter clearance checked. Temporary QA bridges cleaned, build/sync completed; no Save/Publish.

## 2026-10-25 — Rank plaque clears food menu
- Moved ReputationPlaque (including Corner Kitchen and later rank names) away from the food board to the adjacent wall area; 2.25-stud horizontal gap.
- Single-client Studio screenshot and geometry check passed. Build/sync checked; no Save/Publish.

## 2026-10-25 — Station labels mounted on bases
- Moved Station A/B/C signs from above the stations onto their front base faces, preserving color/route text and a small anti-flicker gap.
- All 12 signs across four plots fit within base height; visual review, build and sync completed. No Save/Publish.

## 2026-10-25 — Occluded signs, office board and rear ground repair
- Crew hiring and Upgrade Desk SurfaceGuis now respect wall occlusion (AlwaysOnTop=false).
- Moved the office noticeboard and its papers entirely in front of the rear wall, fixing the clipped white paper shapes.
- Sized pavement to the actual backroom plus a three-stud rear margin and trimmed the matching rear grass tile to its edge at runtime. Removes the coplanar grass/concrete overlap introduced by the earlier pavement expansion.
- Four-plot geometry/GUI checks and single-client visual/walking review passed. Build and final sync checked; no Save/Publish.

## 2026-10-25 — Ingredient-to-dish guidance
- Added matching color/letter guides at stock shelves and cooking stations: A/PREP, B/KITCHEN, C/DRINKS. Each shelf names the currently unlocked dishes that consume its kit.
- Guides update on menu/theme/level/signature changes; stock prompt includes actual dish names. Pickup notices and HUD directions use the same station letters.
- Single-client sandbox: actual shelf labels/pickup notice checked and visually reviewed; detached fixture verified 55 theme/level cases plus signature substitution, then destroyed. Build and final sync checked; no Save/Publish.

## 2026-10-25 — Wall-aligned ingredient racks at 95% size
- Moved all three ingredient racks against the INGREDIENTS divider with a .15-stud rear gap.
- Uniformly scaled rack geometry, ingredient props, pick bins, count plates and detached box icons to 95%, keeping the shelf feet at floor height and preserving direct bin references.
- All four plots passed scale and world-corner wall checks; stock pickup and office navigation passed in one Studio sandbox client. Visual review, build and sync completed; no Save/Publish.

## 2026-10-25 — Stock spacing and detached box visual fix
- Increased Stock depth from 8 to 11 studs; backroom now 32x25, with Office kept at 14 studs deep.
- Fixed the actual overlap cause: StockNoodlesIcon/StockRiceIcon/StockTeaIcon are sibling models, so moving the interactive bins alone left their boxes at old coordinates. Bin labels and sibling visuals now move together.
- Derived walls, divider, racks and office furniture from shared depth values to keep future layout changes consistent.
- Sandbox checks across four plots: no bin/icon corners crossed the office divider; minimum box clearance 2.45 studs. Stock pickup and navigation passed. Final build/sync checked; no Save/Publish.

## 2026-10-25 — Compact food pantry revision
- Reduced Stock depth from 14 to 8 studs (about 43% less floor area); total backroom depth is now 22 instead of 28. Moved the office and furnishings together to keep its existing usable size.
- Lowered racks and replaced archive-like reserve cartons with fabric ingredient sacks, open crates of cabbage/tomatoes/carrots, and tea ingredient jars. Added dedicated pantry lighting and a smaller receiving surface; removed the oversized pallet/trolley arrangement.
- Shifted racks left to preserve the six-stud office doorway approach. Sandbox stock pickup and no-jump navigation to Office passed; inspected the food props in Play. Build and final sync checkpoint performed; no Save or Publish.

## 2026-10-25 — Furnished stock room and office
- Stock now uses three steel racks with lower interactive pick bins, upper reserve cartons, receiving bench, pallet and hand trolley. The original bins/prompts are moved together; stock validation is preserved.
- Office now has a wooden desk, monitor/stand, computer tower, keyboard, mouse/pad, desk lamp, usable chair facing the monitor, filing cabinet and noticeboard.
- Native Stock/Upgrade/Crew prompts remain visible after ShopId changes; previously the HUD could switch all of them to hidden custom prompts.
- Single-client Studio sandbox: stock take/refill, E upgrade panel, chair occupancy and stock-to-office navigation path passed; both rooms visually inspected. No Save/Publish.
- Staged all 33 Edit assets and compared the XML scene to the repository: zero semantic property differences after order normalization (referent IDs ignored). Preserved staged exports under ignored .sync/scene-review; no asset replacement was needed. Duplicate bridge session isolated by rotating its local token after review.

## 2026-10-25 — Mandatory task completion sync checkpoint
- AGENTS.md and SYNC.md now require script reconciliation, reviewed scene export where needed, verification and a fresh successful sync check at the end of every task.
- A blocked checkpoint must be documented and reported as incomplete; restarting/clearing SceneDirty cannot substitute for exporting changes.
- Documentation-only update; current sceneDirty blocker is not resolved by this rule. No Save or Publish.

## 2026-10-25 — Separate stock room and office
- Expanded each backroom from 32x12 to 32x28 studs with matching walls, roof and pavement.
- Added a partition with a six-stud doorway, STOCK/OFFICE signs and office lighting. Stock bins remain in the front room; Upgrade Desk moves into the rear office.
- Layout is generated by maintained ShopService source during startup; no Edit scene assets changed. Build/round-trip and runtime dimensions passed. No Save or Publish.

## 2026-10-25 — Correct navigation instructions
- First-shift upgrade guidance now directs players to the backroom Upgrade Desk.
- Save Slot unlock notice uses Kitchen > Overview > Save / Load design.
- Travel HUD includes Kitchen > More options > Travel; shop return button reads Back to Kitchen.
- Source search and Rojo XML round-trip passed. No Save or Publish performed.

## 2026-10-24 — Post-kick visitor recovery
- Removed the obsolete `MANAGE → Co-op` instruction from the no-kitchen HUD state.
- A player without a kitchen now sees two current choices: open their own vacant kitchen from Overview, or apply to another crew at a green `NOW HIRING` sign.
- Updated leave/kick/full-capacity server messages to use the same world-first directions. The existing five-minute block still applies only to the kitchen whose owner removed that player.
- English and Thai no-kitchen HUD guidance are included. No two-client kick test or Publish was performed.

## 2026-10-24 — World-first upgrades, crew signup and shop growth
- Added a physical Upgrade work desk in each backroom and a green Crew hiring sign beside every restaurant. The desk opens upgrades for the owner; the hiring sign joins the selected occupied, unlocked kitchen through existing server validation.
- Removed Upgrade and Co-op from the management navigation. Visitor guidance now points players to the world signup circles.
- Added a three-level Dining Area upgrade. Each level expands the covered floor and adds a table with seating; the side wall opens and existing patio decor moves beyond the expansion.
- Added locale-based Thai translations for the main management navigation, common actions and the two new world prompts; English remains the fallback.
- Verified in the connected Studio test place and through a Rojo XML build. No Save or Publish was performed.

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
# 2026-10-25 — Youth-perspective playtest notes
- Recorded a single-client first-session heuristic playtest for ages 10–15: opening, first Thai Tea cook/serve, reward/progress feedback, and a blackout repair.
- Identified onboarding clarity risk around cooking timing and an interaction/task mismatch near the tightly grouped station/stock area during a Fried Rice order.
- No player-facing code, source asset, Save or Publish change was made. Final sync checkpoint remains blocked by a pre-existing staged `StyleRenderer.luau` mismatch with Studio.
# 2026-10-25 — Clearer first-shift cooking and ingredient guidance
- Reworked the cooking timing prompt to explicitly say when to press F/tap, highlight the action button when the marker reaches gold, and explain that the practice attempt has no penalty.
- A missed timing action during first-shift training now completes as Good 70/100; normal play still awards Poor 0/100 when the timing action is missed.
- During training, unrelated ingredient crates are rejected for the active order with the correct dish and station letter, preventing a nearby prompt from sending a new player down the wrong task path.
- Single-client sandbox integration and post-training regression passed; no Save or Publish.

# 2026-10-25 — Cooking F timing reconciliation fix
- Fixed F/tap timing being judged at server receipt time instead of the marker position visible to the player.
- `CookSkill` now includes the displayed phase; the server accepts it only within a bounded 0.12 tolerance of authoritative time and retains all active-cook, distance and one-hit validation.
- Added a debounced F input fallback for cases where another ContextActionService binding consumes the key.
- Actual client F in the gold zone returned Perfect 97/100 in single-client Studio QA. No Save or Publish.

## 2026-10-27 — Visual review only (checkpoint incomplete)
- Inspected current shop, food/equipment, pantry, town/NPCs, mall and park in touch-emulated single-client Studio Play. Recorded visual improvement priorities and limitations in TESTING.md; no gameplay/source/asset changes, Save or Publish. Final checkpoint blocked by older staged StyleRenderer and outstanding SceneDirty review; see HANDOFF.md.

## 2026-10-27 — Kitchen, food and mall visual polish
- Reduced overlapping interior ceiling lighting while preserving night sky and ShopLight event controls; darker station backsplash and steel improve contrast.
- Teal noodle bowl/rice plate rim, clearer egg/vegetable garnish, round layered Thai Tea with ice/sleeve/straw, and modestly larger station dish previews.
- Mall: darker shelf frames, package bands/can lids/bottle caps; dressed three existing supply tables with pantry bags, produce and tea tins plus English category signs. Static visual changes only; checkout behavior unchanged.
- Single-client touch-emulator visual review, checkout prompt and 67 recipe construction checks passed; no server errors. Build/source round-trip and 33-asset comparison passed; no Save/Publish. Real-phone performance pending.

## 2026-10-27 — Restore kitchen lighting by user preference
- Removed the kitchen ceiling lighting override, restoring original scene light settings. Retained food, kitchen material colors and mall improvements. Build/source sync verified; no Save/Publish.

## 2026-10-27 — Kitchen lights halfway between presets
- User-selected midpoint: Brightness 1.35, Range 21, default warm color blended 50/50. Default theme refresh preserves the chosen color; equipped theme tint retained. Verified 12 runtime lights and desktop screenshot; no Save/Publish.

## 2026-10-27 — Recipe-specific station equipment
- Added oven/grill/prep/steamer/rice-cooker/coffee/blender models alongside existing pot/wok/tea bar; refresh by recipe identity during Style.Apply. Eleven-menu construction and Cafe runtime visual checks passed; final sync checkpoint passed. No Save/Publish.

## 2026-10-27 — Coins/Gems storefront collection
- Added four rooftop decorations and Front slot; ordinary signs/plant use Coins, special rooftop designs use Gems. Buy UI and server purchase path support both currencies while retaining ownership and placement validation. Sandbox purchase/placement tests and desktop screenshots passed. No Save/Publish.


## 2026-10-28 — Visual review follow-up
- Reviewed current runtime visuals in single-client desktop Studio for a hypothetical 10–15 audience; no child-user study. Priorities: storefront/building identity, food contrast, mall composition, outdoor landmarks. See TESTING.md for coverage and limitations.
- Documentation only; no game source/assets/behavior changed. Stop + fresh sync check passed, 29 scripts, pending=[], SceneDirty=false. No Save/Publish.

## 2026-10-28 — Purchasable storefront food mascots
- Upgraded the four existing Front decorations into food mascots while preserving their IDs and ownership: Noodle Bowl and Fried Rice cost 600 Coins; Sakura Dumpling costs 75 Gems; Cosmic Thai Tea costs 85 Gems.
- Added large rooftop silhouettes, mascot faces, English food signs and themed accents. Purchase currency/price remains catalog-controlled on the server through Profiles.Mutate; Front placement and free removal/re-equip are unchanged.
- Studio sandbox purchase, insufficient-funds, placement and visual checks passed. Repository build/source round-trip and final sync checkpoint passed. No persistent scene asset, Save or Publish.
