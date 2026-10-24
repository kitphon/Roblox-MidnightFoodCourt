# Studio purchase simulation

Enabled ServerScriptService.MidnightCityModules attribute StudioPurchaseSimulation=true.
Profiles.Sandbox now respects this attribute only when RunService:IsStudio(); no real profile loads/saves or ownership lookups in simulation. Existing StudioUsesDataStore=true can stay set: simulation overrides it during Studio testing.
Stop + Play creates a clean session with 0 Gems, no packs and no Save Slot entitlement. This is a free grant simulation, not a Roblox checkout/receipt test.

How to use:
- Kitchen > Gems: Test buy (free) adds the selected Gems.
- Style > Packs: Test unlock unlocks the collection, then Apply pack/Equip.
- Kitchen > Saves: Test unlock (free), then Save/Load design in this session.
- Stop then Play to reset everything.
- To return to cloud-backed Studio tests, Stop, set StudioPurchaseSimulation=false on MidnightCityModules, then Play.
- Actual Roblox Player ignores the simulation flag and still checks actual entitlements.

Updated Profiles, ShopSaves and MidnightManagement. SaveSlot test button is now exposed only when Studio sandbox is active, avoiding a misleading test button in persistent mode.
14 remote-command checks passed: sandbox, zero Gems, locked save/pack, unowned equip denied, real purchase route denied, free pack grant/equip, exactly300 Gems, buy Cozy Cafe, 120 Gems deducted, free Save Slot grant and session-only design save.
Second fresh Play confirmed reset and Test buy (free) buttons on Kitchen > Gems.
Studio left in Play with fresh simulation, Gems page open for user. No cloud profile changed, no Robux charged.

