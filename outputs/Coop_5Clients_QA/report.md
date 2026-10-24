# Five-client Co-op QA — 23 October 2026

Used StudioTestService.ExecuteMultiplayerTestAsync with five actual Studio client DataModels and a separate server. These are real Roblox Player instances and replicated client/server sessions, not mock player tables. Sandbox profiles only.

Three runs:
1. Initial test exposed ownership transfer failure after owner disconnection.
2. After fix, all 31 assertions passed.
3. Extended test, including simultaneous cook/serve prompts, all 41 assertions passed.

## Passed
- Four initial owners each receive a separate kitchen; fifth player is Visitor.
- Three clients join one owner, four members total; fifth cannot enter full kitchen.
- Chef/Waiter/Technician assignments through real client Command RemoteFunction; respective roles replicate to clients.
- Non-owner Kick and Role denied.
- Two clients trigger cooking prompts concurrently: both cook, exactly two stock units consumed, both receive cooked meals; Chef has shorter duration.
- Two clients trigger Serve concurrently: shop served count increases exactly once, extra meal remains held. This asserts order completion count, not an independent bank-delta audit.
- PassMeal through actual client Command preserves Perfect quality and score 98; recipient sees replicated meal/quality/score.
- Pass denied with occupied recipient hands or distance over seven studs.
- Kick through actual client Command moves kicked client to Visitor; kicked client cannot rejoin immediately.
- Owner client disconnects using LeaveTest; ownership transfers to longest-serving remaining crew, whose client sees Owner role.

## Fixed
ShopService.RemovePlayer called Model:RemovePersistentPlayer after departing Player had already left Players. Roblox threw "PersistentPerPlayer player isn't in datamodel", stopping ownership transfer and subsequent profile-save scheduling. Guard streaming removal with player.Parent==Players; continue remaining cleanup/transfer.

## Scope
Automated real-client integration QA, not manual clicks through Role/Kick menus. Prompt tests temporarily disabled line-of-sight requirement at runtime and positioned cameras/characters. Meal transfer quality fixture was seeded at runtime. No live Robux, cloud persistence or physical device testing.

Temporary server/client QA scripts and RemoteFunction removed from Edit after runs. All test clients/server closed automatically. Product change only in ShopService.RemovePlayer. Save Studio file with Ctrl+S.

