# Feature inventory
Developer workflow now includes two-way sync for maintained scripts and live pre-commit/pre-push guards. See SYNC.md; scene/model synchronization is not automatic.
Updated 2026-10-24. “Implemented” means present in Studio source; deployment and verification are separate.

| Area | Implemented behavior |
|---|---|
| Core restaurant | Open/close, 300-second shift, orders, cook, carry, serve, shop funds/tips, five-strike failure |
| Cooking | Randomized F timing target; continuous score and Perfect/Good/Fair/Poor grades; touch controls; the server validates and scores the marker position seen by the player within a bounded latency tolerance |
| First-shift clarity | Customer patience pauses during the five-step guide and during interruptions; one-time two-step refill lesson when front stock first runs out; SHIFT COMPLETE shows orders left to the next level and the dish it unlocks. Training blocks unrelated ingredient crates for the active order, explicitly teaches F/tap timing, and gives Good 70/100 instead of a Poor penalty when the practice timing is missed; normal post-training scoring is unchanged |
| Themes and recipes | 11 menu themes, six fixed cooking bays in one rear-wall row; ABC available at Lv.1, D/E/F at Lv.2/3/4; one optional signature rice replaces B |
| Set meals | Main + drink, after level 2/training, customer waits for both, either delivery order, shared payout |
| Stock | Front capacity 6 per shared kit pool (A/D, B/E, C/F); recipe IDs normalize for carry/refill; prompts/crates/HUD direct to each recipe’s fixed bay; shortages/menu change and temporary closing |
| Shopping/travel | Mall supply counter opens its own window: buy several crates of any kits per trip (default 8), deliver all at any backroom shelf; cards list which dishes/stations each kit feeds. Bus stops for shops and mall, 5-Coin transit |
| Multiplayer | Four kitchens, max four crew each, fifth player does not autojoin full shop; Visitor when unavailable |
| Kick recovery | Removed crew becomes a Visitor at city spawn with clear choices to open a vacant kitchen or apply at another hiring sign; five-minute rejoin block applies to the kicking owner's kitchen |
| Crew cooking lock | Only one crew member can cook the current order's dish: while a teammate is cooking or holding it, the station refuses with "<Name> is already making <Dish> for this order" and no stock is used. Cooking other menu dishes ahead of time is still allowed |
| Co-op | Join/leave/visit/return home, owner lock, role assignment, kick with five-minute rejoin block, owner succession |
| Give dish | Hold E near eligible teammate while holding food; explicit giver/receiver confirmation |
| Food visibility | Server-created held food model visible across clients; new implementation awaiting second-client validation |
| Workers | NPC chef/waiter/technician; role outfits, paid hiring, automated tasks |
| Player roles | Chef 20% faster cooking; Waiter +10% serving value; Technician +15 shop funds per repair |
| Customer flow | Multiple arriving/departing guests; stock-aware orders and alternatives |
| Special guests | Reviewer bonuses/review reasons/popularity rush, Riley relationship, Dinner Party group behavior |
| Interruptions | BLACKOUT / WHISPER / SHADOW; separate Shadow behind radio, relocated Ward banishment and slow partial shop-light flicker until resolved; existing Technician can resolve it; city remains nighttime |
| Progression | Five ranks at served totals 0/8/25/60/125; up to 20 Legend Stars, +2% food value per star |
| Physical progression | Backroom work desk opens an independent owner Upgrade window with funds/deposit and close; M opens separate management; Dining Area has three visible expansion levels with covered seating |
| Trees and fairy lights | `City.DressTrees` (shop tree rows from ShopService.Start, park trees from City.Start) varies each tree deterministically by position: 0.8–1.2× size and six looks (round, small, pine stack, cluster, pink blossom, autumn orange); every other tree gets bushes, some with flowers; neon fairy lights sag between neighbouring trees in a row. Extras are tagged `TreeRowDecor` so the dining expansion shifts them with the right-hand tree row |
| Mall interior | Runtime `MallInterior`: front wall rebuilt around both display windows so the glass (75% transparent) shows the store; warm interior lights; teal wainscot with neon stripe and a FRESH INGREDIENTS 24/7 banner; entrance mat and planters; three GROCERY shelving units with products; five open-front COLD DRINKS fridges with bottles; snack island; register/screen/scanner and basket stack on the supply counter; two shopping carts. Supply counter, shelves and prompts unchanged |
| Station equipment | Each cooking bay has runtime `StationGear_<station>` by ingredient kit: A/D noodle stock pot on a burner with broth, noodles and idle steam, ladles and bowls; B/E wok on a flame ring with rice, spatula and sauce bottles; C/F tea bar with two glass dispensers, cup stack, shaker, straws and wood bar front. Tiled backsplash per kit, kick plate, knobs on A/B/D/E. The menu dish now sits front-left (max 1.6-stud footprint) |
| Storefront decor | Runtime-built per shop (`Storefront` folder): coral/cream striped awning with valance and warm under-glow, pink neon frame around the name board, bulbs up the posts and along the roof edge. Owned shops chase pink/yellow/cyan (client-animated); vacant shops glow warm; BLACKOUT turns bulbs/frame off. Awning fades locally when the camera is underneath. Owner sign reads `NAME'S KITCHEN` in capitals |
| Shop surface consistency | Backroom walls/office divider and backroom/dining floors match main shop colors and materials across current and legacy themes |
| Expanded dining layout | No starter or career-rank tables; seating requires purchased Dining Area/Decor upgrades. Roof continues the main roof at the same height; one table per Dining Area level, Decor uses rear planters inside the room; trees move clear |
| Goals/tutorial | Five-step first-shift tutorial and shift team goals |
| Retention | Three daily quests, weekly rewards, seven-day login streak |
| Rankings | Weekly and lifetime served leaderboards in Journey; sandbox uses server-local results |
| City | Ambient citizens and events: rush/bus/rain/quiet night. Citizens have faces (eyes with shine, blush, smile), four hair styles (short, cap, long, bun), shirt sleeves with skin-tone hands, varied skin/hair/pants and shoes. Town buildings are dressed at runtime (`TownDetail`): most windows lit warm/TV-blue with frames and sills, side windows, floor band/plinth, neon roof strip and sign underline, glowing entrance with awning and lamp, rooftop AC/antenna, plus apartment flower boxes/planters, market fruit crates and OPEN 24H sign, clinic neon cross and bench, office planters/wall AC, bus terminal departure board and bench |
| Visitors | Courier delivery jobs, stock support for kitchens and Coin reward |
| Cosmetics | Themes, uniforms, staff/team styles, effects, emotes, decor and packs |
| Photo mode | Flexible camera and hidden NPC speech; world photo points |
| Economy | Personal Coins, premium Gems, owner shop Bank |
| Monetization | 11 Game Passes, three repeatable Gems products; platform IDs configured |
| Save | Existing automatic progression persistence; optional 79-Robux permanent design Save/Load slot |
| Touch layout | On touch devices the KITCHEN button drops the [M] hint and sits bottom-right beside the jump button, leaving the left thumbstick zone clear; the first-shift guide moves beside the FRONT / BACK card when the screen is too short |
| Input/UI | Simplified management navigation, world-first Upgrade/Crew prompts, English fallback plus Thai localization for main management/world actions, keyboard/touch/gamepad prompts where implemented, Shift camera lock, distinct equip states |

## Current navigation
- At Lv.2, Pork Dumplings cooks at Station A (shared with Noodles). Pending orders change the station's displayed dish and prompt automatically; expanded recipes share A/B/C by recipe slot.
- MIDNIGHT MENU board cards follow the physical station line as seen from the dining side (F E D C B A): A–C share one row with Station A's dish on the right; once D–F unlock they fill the upper row so the board reads F→A.
- Restaurant rank plaque is positioned beside the food menu with a clear gap instead of overlapping recipe cards.
- Station A/B/C signs are mounted on the front of the station bases, matching shelf colors/letters without floating above cooking surfaces.
- Hiring/Upgrade labels are visible only when not blocked by geometry. Office noticeboard is mounted in front of its wall; rear lawn starts at the extended pavement edge without overlapping surfaces.
- Stock room: 32x11 ingredient pantry with lower interactive bins, shorter racks, ingredient sacks, open vegetable crates, tea jars and a small receiving surface; Office: furnished computer workstation with a usable chair, filing cabinet and noticeboard. Interact at the desk to upgrade.
- Backroom: separate front Stock room and rear Office in a 32x25 footprint; six-stud connecting doorway, with Upgrade Desk in the Office. Stock bins, count labels and sibling box visuals move together.
- Ingredient racks sit against the INGREDIENTS wall with .15-stud clearance, uniformly reduced by 5% including their stock bins and ingredient visuals.
- Shelf labels sit on top of each rack (above the top deck, not covering the stock) under a raised INGREDIENTS header. They list their currently unlocked dishes, with matching color/letter station labels (A/PREP, B/KITCHEN, C/DRINKS). Theme changes, menu unlocks and signature substitution update the mapping automatically; pickup notices/HUD directions use the same letters.
- Tutorial and unlock notices use the current Upgrade Desk, Save / Load design and More options > Travel routes; the shop return button is Back to Kitchen.
- Kitchen [M]: Overview, Staff and Quests (supplies are bought only at the mall counter window). Upgrade is used at the backroom work desk; Crew signup is at the hiring sign beside each restaurant.
- Shop / Gems are prominent shortcuts.
- More: Journey and Travel.
- Overview > My shop: design Save/Load.
- Journey: ranks, menu unlocks, reviews, friendship, goals, tutorial.
- Shop: Packs, Gems, Themes, Outfits, Effects, Decor.
- Legacy Saves/Ranks/City routes redirect to the current locations; legacy Co-op routes return to Overview and world guidance.
- Kitchen Crew popup was removed in favor of contextual Give dish on teammates.

## Monetization catalog (configured 2026-10-23)
| ID key | Roblox ID | Robux |
|---|---:|---:|
| shop_save_slot | 2053955069 | 79 |
| retro_collection | 2053841030 | 179 |
| ocean_collection | 2053187069 | 179 |
| garden_collection | 2053763008 | 169 |
| space_collection | 2055622918 | 199 |
| starter_style | 2054164967 | 69 |
| signature_japan | 2052887087 | 199 |
| signature_neon | 2053889058 | 199 |
| outfit_collection | 2053079082 | 79 |
| crew_collection | 2053955073 | 129 |
| festival_collection | 2053925022 | 249 |
| gems_100 | 3721643107 | 49 |
| gems_300 | 3721643205 | 129 |
| gems_700 | 3721643220 | 249 |

IDs/prices are recorded configuration, not a fresh storefront price check. First 11 are passes; last three developer products. Actual paid fulfillment has not been tested.

## Not implemented / not established
- No in-game user image/video content feed described in the current build; Photo Mode alone is not a feed.
- Visitor ordering as a paying customer and a 3D city leaderboard remain ideas, not completed features.
- No guaranteed revenue; payouts and progression are not tuned from production telemetry.
- Expanded recipes include reused canonical models; they are not 33 wholly new custom asset designs.


## Developer tooling
Versionable source and assets now live alongside this documentation. Rojo 7.7.1 can build a local place; verifier checks all 29 source paths/classes/text. This adds no new player-facing feature. See DEVELOPMENT.md.
## Visual polish — 2026-10-27
- Interior ceiling lighting is softened at runtime in all kitchens and the mall; nighttime city lighting remains unchanged. Kitchen ceiling fixtures retain ShopLight event control.
- Default noodle bowl/rice plate use teal contrast rims and clearer garnish; Thai Tea uses round layered geometry, ice, a sleeve and straw. Station dish previews fit within 1.85 x 1.7 studs, on the existing plating spot.
- Mall shelves have package bands, can lids and bottle caps; central supply displays have pantry bags, fresh produce and tea tins with English labels. Checkout and aisle access remain available. Added props are static/noncolliding; real-phone performance still requires measurement.

## Kitchen lighting preference — 2026-10-27
- Kitchen ceiling lights use the original scene values (Brightness 2, Range 23, warm RGB 255/213/164); this supersedes the softened kitchen ceiling lighting note. Food/material improvements and softer mall lighting remain.

## Current kitchen lighting — 2026-10-27
- Supersedes original/soft presets: ceiling Brightness 1.35, Range 21, default warm color at RGB 255/221.5/182.5 midpoint. Theme-specific tints and ShopLight event identity retained. Other food/mall polish unchanged.

## Recipe equipment — 2026-10-27
- Station gear follows full theme recipes (including locked stations and signature rice) and updates when theme changes: pot, wok, tea bar, oven, grill, prep board, steamer, rice cooker, coffee machine or blender. Food placement, station prompts and ingredient pools unchanged. Repeated unchanged refreshes retain equipment instances.

## Storefront collection — 2026-10-27
- Shop > Decor offers ordinary Plant Corner (350 Coins), Mint Market Sign / Sunset Kitchen Sign (600 Coins each), and special Sakura Rooftop (75 Gems) / Cosmic Rooftop (85 Gems). Coins are personal player currency, not Shop Bank. Existing aquarium/neon/speaker remain Gems; ownership of older items is preserved.
- New Front slot equips one rooftop feature above the owner sign, with free removal/re-equip after purchase. UI shows actual currency, insufficient funds, owned/equipped states and previews. Server chooses price/currency from catalog and mutates profiles atomically; client-supplied prices are not used.

