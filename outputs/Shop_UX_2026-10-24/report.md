# Shop/menu UX update — 24 October 2026

Changed MidnightManagement and MidnightStyleShop only.
- Kitchen: 8 initial navigation entries instead of 13. Secondary rewards/progress/travel/ranks/saves/city under More options. Current selected secondary destination remains visible.
- SHOP highlighted gold and routes to Packs; GET GEMS highlighted purple and routes to Gems.
- Shop: 4 primary tabs (Packs, GET GEMS, Themes, More styles); secondary categories accessible via More styles.
- Unowned item badge shows cost; owned badge OWNED; active badge green ✓ EQUIPPED.
- Equip mint, Unequip/Remove coral with light text; Preview subdued.
- Insufficient Gems exposes purple Get Gems action routing to Gems; actual item price remains on badge.
- Owned pack can Apply pack; fully active pack shows disabled ✓ Equipped.
- Robux purchase button says Buy with exact Roblox-provided price; Studio simulation clearly Test unlock (free).

Verified using existing free Studio simulation: unowned pack grant, owned theme Equip -> Unequip after applying, distinct colors and matching badge/state attributes. Kitchen primary count8; Shop primary count4.
Galaxy A06 emulator landscape705x338 and portrait359x718: 4 primary Shop tabs, all labels TextFits=true, screenshots inspected. Desktop screenshot inspected.
No runtime errors observed (existing missing ConfigService-key warnings excluded).
Automatic mouse attempt to toggle More styles did not establish activation; expansion not confirmed through input automation. Logic remains in client callback.

Stopped Play, reset simulator to default viewport/landscape. StudioPurchaseSimulation remains enabled. Publish updated source via File > Publish to Roblox to deploy; not automatically published.

