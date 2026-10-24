# Feature inventory
Developer workflow now includes two-way sync for maintained scripts and live pre-commit/pre-push guards. See SYNC.md; scene/model synchronization is not automatic.
Updated 2026-10-24. “Implemented” means present in Studio source; deployment and verification are separate.

| Area | Implemented behavior |
|---|---|
| Core restaurant | Open/close, 300-second shift, orders, cook, carry, serve, shop funds/tips, five-strike failure |
| Cooking | Randomized F timing target; continuous score and Perfect/Good/Fair/Poor grades; touch controls |
| Themes and recipes | 11 menu themes, six dishes each; start three and unlock at levels 2/3/4; one optional signature rice |
| Set meals | Main + drink, after level 2/training, customer waits for both, either delivery order, shared payout |
| Stock | Front capacity 6, backroom storage, ingredient kits, carry/refill, shortages/menu change, temporary closing |
| Shopping/travel | Mall supplies, bus stops for shops and mall, 5-Coin transit |
| Multiplayer | Four kitchens, max four crew each, fifth player does not autojoin full shop; Visitor when unavailable |
| Co-op | Join/leave/visit/return home, owner lock, role assignment, kick with five-minute rejoin block, owner succession |
| Give dish | Hold E near eligible teammate while holding food; explicit giver/receiver confirmation |
| Food visibility | Server-created held food model visible across clients; new implementation awaiting second-client validation |
| Workers | NPC chef/waiter/technician; role outfits, paid hiring, automated tasks |
| Player roles | Chef 20% faster cooking; Waiter +10% serving value; Technician +15 shop funds per repair |
| Customer flow | Multiple arriving/departing guests; stock-aware orders and alternatives |
| Special guests | Reviewer bonuses/review reasons/popularity rush, Riley relationship, Dinner Party group behavior |
| Interruptions | BLACKOUT / WHISPER / SHADOW; FuseBox / Radio / Ward; city remains nighttime |
| Progression | Five ranks at served totals 0/8/25/60/125; up to 20 Legend Stars, +2% food value per star |
| Goals/tutorial | Five-step first-shift tutorial and shift team goals |
| Retention | Three daily quests, weekly rewards, seven-day login streak |
| Rankings | Weekly and lifetime served leaderboards in Journey; sandbox uses server-local results |
| City | Ambient citizens and events: rush/bus/rain/quiet night |
| Visitors | Courier delivery jobs, stock support for kitchens and Coin reward |
| Cosmetics | Themes, uniforms, staff/team styles, effects, emotes, decor and packs |
| Photo mode | Flexible camera and hidden NPC speech; world photo points |
| Economy | Personal Coins, premium Gems, owner shop Bank |
| Monetization | 11 Game Passes, three repeatable Gems products; platform IDs configured |
| Save | Existing automatic progression persistence; optional 79-Robux permanent design Save/Load slot |
| Input/UI | English game text, keyboard/touch/gamepad prompts where implemented, Shift camera lock, distinct equip states |

## Current navigation
- Kitchen [M]: Overview, Supplies, Staff, Upgrades, Co-op, Quests.
- Shop / Gems are prominent shortcuts.
- More: Journey and Travel.
- Overview > My shop: design Save/Load.
- Journey: ranks, menu unlocks, reviews, friendship, goals, tutorial.
- Shop: Packs, Gems, Themes, Outfits, Effects, Decor.
- Legacy Saves/Ranks/City routes redirect to the current locations.
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
