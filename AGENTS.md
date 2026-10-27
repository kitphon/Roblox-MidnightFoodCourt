# Midnight Food Court agent instructions
- Active workspace: D:/Roblox-game/Midnight_Food_court. Read docs/SYNC.md before editing.
- Start tools/start_sync.py and require a successful tools/sync_bridge.py check before and after source edits. Keep the local Studio bridge connected; never run a competing Rojo writer.
- Existing scripts sync both directions. On conflict, preserve both sides and review before resolving. New scripts/mapping changes need deliberate manifest/project updates and bridge restart.
- Scene/model changes still need reviewed asset export. Never clear SceneDirty merely to bypass a commit guard.
- Finish every individual task with a Studio-to-repository sync checkpoint before reporting completion or moving to the next task. Stop Play, keep the bridge connected, reconcile all script changes into src/, and export/review any intentional Edit-mode scene/model changes into assets/. Review manifest/project mappings when required, rebuild and verify affected assets/source, then require a fresh successful tools/sync_bridge.py check with no pending changes, conflicts or unreviewed SceneDirty. Runtime-only Play objects are not persistent scene assets; keep their generating source synced. Never restart the bridge or clear SceneDirty as a substitute for exporting/reviewing changes. If the checkpoint cannot pass, preserve both sides, record the exact blocker and remaining sync/export work in docs/HANDOFF.md and docs/TESTING.md, and report the task as incomplete. Sync does not mean Save or Publish; report those statuses separately.
- Start with README.md and docs/HANDOFF.md. Read the relevant feature and test sections before modifying code.
- The maintained code is now src/ with assets/ and default.project.json. Read docs/DEVELOPMENT.md before editing. The original connected Studio place was the migration source; compare changes before syncing. Any Studio MCP edits must be exported back into the repository before completion. Verify PlaceId 120399989321685 and UniverseId 10772566896 before edits. Studio connection IDs change between sessions.
- Do not restore old outputs/MidnightCity_v* or work/menu-expansion-backup scripts over current Studio source unless deliberately recovering a specific change.
- Keep player-facing game UI in English; communicate with the user in Thai.
- Preserve the permanent nighttime city atmosphere and distinct Equip/Unequip states.
- Do not treat Studio purchase simulation as real purchase/receipt verification. Do not spend Robux or alter live account ownership to test.
- Preserve existing remote/server validation and Profiles.Mutate for persisted changes.
- Use sandbox for synthetic gameplay/profile tests. Clean up temporary QA scripts/bridges after testing.
- After each meaningful implementation or test session, update docs/CHANGELOG.md, docs/TESTING.md, docs/FEATURES.md (if behavior changed), and the current state / pending work in docs/HANDOFF.md.
- Record what was actually tested, which environment was used, and limitations. Never claim a live/multiplayer/paid test from isolated unit or single-client tests.
- Record publication status explicitly. A local Studio edit or successful compile does not establish successful Save or Publish.
- If access to Studio is blocked, record the blocker and avoid presenting intended changes as completed.

