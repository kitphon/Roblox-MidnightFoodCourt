# Co-op, mobile and persistence readiness — 23 October 2026

## Product change
StarterPlayer.StarterPlayerScripts.MidnightGameplay now lays out touch cooking and crew controls in screen pixels rather than scaling them with the 960x640 desktop canvas.
Timing, three crew signals and Pass Meal are 48px high. Cooking card is at bottom center, width capped at 420px with 16px side allowance. Crew tools sit above it with a 12px gap; desktop layout is unchanged.

## Verified
Virtual GUI geometry at 844x390, 852x393, 915x412 and 390x844: timing and crew tap targets all 48px high, panels stay within width, 12px vertical gap.
Isolated production Co-op handlers: locked/full/vacant kitchens reject Join; active owner kick ban rejects Join; non-owner Kick/Role reject; self PassMeal rejects.
Production ShopSaves Capture/Restore: latest Coins/Gems/Bank/stock/workers/upgrades preserved; invalid saved style rejected.
Production Profiles receipt builders: duplicate PurchaseId does not add Gems twice; merging old and new distinct receipts preserves both grants.
Fresh normal single-client Play has no runtime errors; expected warning remains for 14 unconfigured monetization IDs.
Play stopped; temporary GUI destroyed. Save Studio file (Ctrl+S) to persist UI edit.

## Remaining real tests
These tests do not establish multi-client replication, physical touch usability or cloud purchase delivery.
Roblox Studio Clients and Servers:
1. Start four clients; verify separate initial shops. Join Kitchen 1 from clients 2–4.
2. Owner assigns Chef/Waiter/Technician; confirm roles and perks on each client.
3. Pass an already cooked Perfect meal at <=7 studs: sender clears, receiver holds same quality/score; try occupied hands and >7 studs.
4. Two players cook/serve same order simultaneously; verify no duplicate payout or lost stock.
5. Owner kicks member; member becomes Visitor, cannot return for five minutes, other shops remain available.
6. Owner disconnects; longest serving crew receives ownership, no player remains bound to abandoned state.
7. Start a fifth client with all four shops occupied; verify Visitor assignment.
8. Repeat touch controls in Device Emulator and on physical phone; review against other HUD cards and jump controls.

Publish and use a dedicated test experience/account:
- Configure 11 passes and three products with actual IDs; confirm displayed prices with Roblox.
- Enable Studio API access only when needed; use separate Studio store (StudioUsesDataStore=true).
- Earn progress, save, leave, rejoin; verify Coins/Gems/stock/upgrades and saved design.
- Buy Save Slot, leave/rejoin; verify entitlement and Save/Load.
- Exercise receipt retry/duplicate delivery and server-hop persistence with test procedures; verify a single grant.
- Verify weekly/all-time OrderedDataStore ranking across servers.
Do not count sandbox simulations as live payment or cloud tests.

