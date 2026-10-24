# Automatic gameplay and persistent reload QA

Two independent Studio multiplayer test sessions, each with one real client and separate server. Actual client Command RemoteFunction and ProximityPrompt input, no native screenshot automation needed. Real Studio DataStore (MidnightCityProfiles_v1_Studio); test client UserId=-1.

Run 1: all 14 checks passed.
Open shop, await customer arrival, cook through client prompt, consume exactly one ingredient, submit CookSkill via client remote, receive meal, serve through client prompt, clear held item, increase bank/career, save to cloud.
Bank500->543, Coins500->512, served1.

Run 2: all six checks passed.
Fresh client/server session reload verifies Coins512, Bank543, Gems0, career served1 and stock total for ordered dish. Original test profile restored and saved. Original session lock was not reused.

Fixtures temporarily provided six front units, disabled NPC workers and skipped tutorial; test only, original profile restored. Prompt line of sight disabled at runtime and camera/character positioned automatically. Timing action tested through production Command remote, not the screen's button activation. This is automated real-client Studio integration QA against cloud storage, NOT a test in the standalone published Roblox Player or live production profile store.

All temporary server/client scripts and RemoteFunction removed from Edit. No product source changes. Native Player capture problem remains unresolved.

