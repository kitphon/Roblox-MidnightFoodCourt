# Device Emulator QA — 23 October 2026

Used Roblox StudioDeviceSimulatorService with actual mobile presets and live Play UI. Applied Roblox rbx-device-simulator-lua guidance. Game StarterGui.ScreenOrientation = Sensor. Runtime MidnightHUD, MidnightGameplay, MidnightManagement and MidnightStyleShop use DeviceSafeInsets.

## Coverage
- iPhone 17 Pro landscape: live HUD and Kitchen Overview screenshots, viewport 750x381.
- iPhone 17 Pro portrait: Overview, Ranks, Saves, Style screenshots, viewport 401x778. Style Back to Manage clicked successfully and visibility verified (Manage=true, Style=false).
- iPad Pro M5 13in landscape and portrait: Kitchen Overview screenshots, viewports 1375x1032 and 1032x1375.
- Samsung Galaxy A06 landscape: actual cook started via station ProximityPrompt, live timing UI screenshot, viewport 705x338.
- Samsung Galaxy A06 portrait: held Fried Rice, Order/Carrying/stock/tutorial HUD screenshot, viewport 359x718; Gems page rendered through existing OpenMidnightManagement event.

## Findings
1. Galaxy A06 landscape Kitchen button overlaps left edge of cooking card/timing track. The 48px timing action itself is separated from the jump button, but the full cooking card conflicts with Kitchen.
2. Portrait HUD remains scaled from desktop canvas: Order, Carrying, stock, top stats and action hints become very small and are grouped around screen center. Portrait menus adapt much better than HUD.
3. iPhone landscape menu navigation measured about 93x24px; content action buttons about 187x19px. These are small touch targets even though the cooking/crew controls were enlarged.
4. Saves and Gems correctly show unavailable/Coming soon for unconfigured purchases in sandbox; this is expected.
5. Tablet menu stayed within viewport in both orientations.

## Limits
Mouse automation did not establish successful CookingSkill button activation; two input attempts left SkillHit false. Treat interaction as inconclusive rather than passed or a confirmed product defect. A cooked dish was produced normally, but no timing result can be claimed from tapping.
Gems rendering was invoked via existing client event, not successful navigation click. No purchases made.
Crew controls not displayed in this single-client session; their physical touch behavior not tested.
This is Studio emulator QA, not a physical phone test.

## Suggested fixes
- Reserve space for Kitchen when laying out the cooking card, or temporarily move Kitchen while cooking.
- Build a portrait HUD layout instead of shrinking desktop canvas.
- Increase landscape menu navigation and action targets with scrolling at a readable UI scale.

No product source changes this QA run. Temporary server cook/reset fixtures existed only during Play and were cleared by Stop. Studio returned to Edit, device simulator reset to default viewport and landscape orientation. Console contained only expected 14 unconfigured monetization items warning, no runtime script errors during this run.

