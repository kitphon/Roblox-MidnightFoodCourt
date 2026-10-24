# Script sync — Midnight Food Court
Updated 2026-10-24. Root: D:/Roblox-game/Midnight_Food_court.

## ใช้งานครั้งต่อไป
1. ดับเบิลคลิก **Start Development.cmd** ใน repo เพื่อเริ่ม server เบื้องหลัง
2. เปิด Midnight Food Court [TEST] ใน Studio (PlaceId 120399989321685, UniverseId 10772566896)
3. Local plugin MidnightRepoSync จะเริ่มเชื่อมเมื่อ Studio โหลด plugin และเปิด place ที่ตรงกัน
4. ดู Output: **[Midnight Sync] synced** หรือรัน:

```text
python tools/sync_bridge.py check
```

การเชื่อมใน Studio ที่เปิดอยู่ตอนติดตั้งถูก bootstrap ผ่าน MCP และทดสอบแล้ว ส่วนการโหลด plugin อัตโนมัติหลังรีสตาร์ต Studio ยังไม่ได้ทดสอบแยก

## What is automatic
- Maintained scripts in src: file → Studio and Studio editor/MCP → file, polling every 2 seconds.
- Uses the last shared version to distinguish one-sided edits from conflicts.
- Before disk writes, stores the previous content in ignored .sync/backups/.
- Different edits on both sides stop synchronization. Both versions are saved under .sync/conflicts/.
- Git pre-commit and pre-push hooks request a fresh Studio audit. Offline, Play, conflict, pending changes, changed disk content, stale staging, or detected scene edits block the command.
- Play pauses sync; Stop resumes it. No runtime profiles/stock/Coins are exported.
- Per-request HTTP transport restores the original HttpEnabled setting immediately, even on network failure.

## Limits
- This automates the existing **29 scripts**, not all Roblox properties or models.
- Scene/assets remain in assets/ and need a reviewed Studio export. Scene edits observed during the active bridge session mark sceneDirty and block commit. This is not a complete persisted scene comparison or proof that assets match at startup.
- Creating, renaming or deleting scripts requires updating manifest/project mappings and restarting both server and plugin. The bridge refuses implicit destructive inventory changes.
- Do not connect a separate Rojo live writer to the same place while this bridge is active.
- Sync does not Save/Publish to Roblox or create a Git commit.
- Git hooks can be bypassed by explicit Git options; treat them as workflow guards, not a security boundary.
- A local server must be running. After a computer restart, use Start Development.cmd again; this does not install a Windows login task.

## Conflict recovery
Read the versions under .sync/conflicts/<manifest index>/. Review/merge the intended changes, then intentionally set the same merged content on disk and in Studio. The next exchange establishes a new shared version. Do not delete .sync/base.json to make a conflict disappear.

For a scene warning: export/review the changed assets first, rebuild, then restart the bridge/plugin or have an agent clear SceneDirty only after confirming the export. Restarting is not proof that scene assets were exported.

## Controls / tools
- Toolbar Midnight Development: MidnightSyncStatus pauses/resumes; StopMidnightSync stops that Studio bridge.
- Restart server after changes to its implementation:

```text
python tools/start_sync.py --restart
```

- Status metadata: http://127.0.0.1:34875/status
- Logs: .sync/server.log and .sync/server-error.log.
- Token, working baseline, recovery copies and logs stay in ignored .sync/. Do not add that directory to Git.
- Plugin installed locally at %LOCALAPPDATA%/Roblox/Plugins/MidnightRepoSync.rbxm, outside game source.
- tools/start_rojo_sync.ps1 is a legacy launcher and refuses to compete once bridge status exists.

## Verification performed
- 11 automated tests: initial mismatch, both directions, acknowledgements, backup/restart, conflict preservation/resolution, Play pause, wrong place/class/inventory, line endings, markers, scene/stale checks and real Git index contents.
- Live Studio: file comment arrived in Studio; Studio comment arrived on disk; different concurrent comments were both preserved and commit hook blocked.
- QA comments removed; 29 scripts returned to synced.
- Live Play/Stop pause/resume passed.
- A reversible Baseplate color edit triggered scene guard; original color restored exactly and QA dirty flag cleared.
- Fresh audit and pre-commit/pre-push hook success checked after recovery.
- One-click CMD startup and Python restart tested. No PowerShell execution-policy change needed.
- Original export added extra EOF blank lines; sync canonicalized EOF/line endings without gameplay logic changes. Original migration hashes remain historical; use normal repository verifier after intentional edits, not --baseline.
- No Git commit, paid transaction or Roblox publication performed.
