# Menu expansion QA — 2026-10-24
- Expanded 11 theme menus from 3 to 6 entries (66 themed recipes + Signature Chicken Rice).
- Starts with 3 recipes; a fourth/fifth/sixth unlocks at restaurant levels 2/3/4.
- Keeps 3 stations and their ingredient-kit categories. New recipes reuse canonical food geometry; drink variants receive suitable colors.
- Journey lists all recipes with lock levels. Feature Dish supports 6 positions.
- Shop menu board uses 3 columns × 2 rows; station props remain one per station.
- Set meals begin at level 2 after training, on eligible non-party visits (visit counter mod 3 = 1 and a main dish selected). Only in-stock/unlocked drink candidates are used.
- Main and drink can be cooked at separate stations and delivered in either order. Duplicate delivery is rejected. Customer stays until both have arrived.
- One completed set counts as one order, with base reward multiplier 2.2. Each item consumes its normal kit.
- Order HUD shows both food models, names and delivery check marks; existing card dimensions retained.
## Checks performed
- All 11 themes: six entries; unlock counts 3/4/5/6; valid stock/station and registered icon for every recipe.
- Bundle logic: drink-first then main, partial stays pending, duplicate drink rejected, final completes, cleanup.
- Actual Studio sandbox session: level 4, new Pork Dumplings + Lemon Iced Tea; normal proximity cooking and serving.
  - First dish: Held cleared, BundleDone 1, customer order changed to drink, Bank stayed 500.
  - Second dish: Bank 575, Served 1; FrontNoodles 3→2, FrontTea 3→2.
- Client received both food icons/names; all six board models were present. Inspected Studio screenshot.
- No new runtime errors observed; existing ConfigService missing-key warnings remain.
- Temporary QA script/bridge existed only in Play mode and disappeared on Stop. No live purchases or persistent profile modifications.
## Limits
- Not published.
- Full real-player two-client set-meal session and all theme visuals individually remain to be checked.

