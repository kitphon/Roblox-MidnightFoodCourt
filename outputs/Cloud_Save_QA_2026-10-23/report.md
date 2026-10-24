# Published test experience — Studio cloud persistence QA

Universe 10772566896; Place 120399989321685.
StudioUsesDataStore enabled on MidnightCityModules; production code chooses MidnightCityProfiles_v1_Studio, separate from MidnightCityProfiles_v1.

Passed:
- Real DataStore save/update, session release and reload.
- Persisted Coins12345, Gems421, Bank6789, Kitchen upgrade2, Chef worker, front/back stock, saved design slot and AutoResume.
- Real Profiles.Receipt against Studio store: same test PurchaseId applied twice grants +100 Gems only once (321 to421).
- Stop Play, start fresh Play, require normal production Profiles module, load same fixture profile: all seeded values and receipt remain.
- Real local player's normal profile loads with SaveMode=Persistent.
- Fixture used unique negative UserId and mock player table, NOT human profile mutation. Real DataStore operations, not simulated persistence.
- Released fixture profile and removed its exact test key after verification.

Limits:
- Does not verify joining a live Roblox server, server-hop timing/session contention, network outage recovery, game-pass ownership or actual Robux checkout/receipt delivery.
- ConfigService warns that Midnight_* keys are missing; defaults remain used. Fourteen monetization IDs remain unconfigured.
- Saved design entitlement was not purchased; test only persisted the design slot data.
- StudioUsesDataStore remains true for continued Studio testing. Save local place to persist attribute.

Temporary test Scripts were runtime-only and cleared by Stop. Studio left in Edit mode.

Stage1:
{"Stage":"Save, receipt retry, release and reload","Passed":true,"TestUserId":-1792766230}

Stage2:
{"Stage":"Fresh Play session reload and test-key cleanup","Passed":true,"TestUserId":-1792766230}

