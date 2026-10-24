# Mobile UI fixes — 23 October 2026

Product scripts changed: MidnightCityHUD, MidnightGameplay, MidnightManagement, MidnightStyleShop.

Changes:
- Portrait HUD stats, Order, Carrying, stock and action card use screen-space layout with readable scale instead of shrinking the whole desktop canvas.
- Gameplay finds TopStats recursively because its parent changes on portrait screens.
- While cooking, Kitchen moves to top-left in landscape and above timing controls in portrait.
- Portrait tutorial remains above Kitchen with explicit clearance.
- Short landscape touch screens get unscaled, scrollable Kitchen and Style panels. Navigation targets are 48px high, main management tile buttons 52–56px; Style action buttons at least 48px. Close/back controls 44px.
- Desktop/tablet menu branch retained.

Verification:
- Galaxy A06 emulator portrait/landscape, live screenshots of HUD, Kitchen, Style and active timing controls.
- iPad Pro M5 landscape menu regression screenshot.
- Order-to-stock gap 17px; guide-to-Kitchen gap ~16.2px; Kitchen-to-cooking gap 12px; timing button height 48px.
- Fresh final Play output had no runtime errors; expected warning for 14 monetization IDs remains.
- Portrait cooking layout screenshots use temporary client state fixtures; do not interpret them as a successful timing-button gameplay test.
- Mouse automation still did not establish successful timing activation; physical touch verification remains outstanding.
- Menu cards scroll on short screens; actions below visible crop require scrolling.

Play stopped and simulator returned to default viewport/landscape. No QA fixtures persist. Save Studio file with Ctrl+S.

