# Development and Git workflow
Current workflow: use [SYNC.md](SYNC.md) and Start Development.cmd for guarded two-way script sync. The earlier Rojo serve instructions below are historical; do not connect a competing Rojo live writer.
Updated 2026-10-24.

## Repository layout
- src/server/ServerScriptService: server scripts and MidnightCityModules.
- src/client/StarterPlayer/StarterPlayerScripts: five client scripts.
- src/shared/ReplicatedStorage/MidnightStyle: six shared modules.
- assets/: 33 serialized Studio model files, including the map, remotes, effects and sounds.
- default.project.json: exact service/instance mapping plus selected service settings.
- studio-export/manifest.json: source and model inventory captured during migration.
- studio-export/checksums.json: hashes of the initial exported files; update intentionally after a new baseline.
- docs/ and root AGENTS.md: behavior, history, testing and handoff.
- outputs/: dated report.md evidence tracked; legacy generated code/screenshots ignored.
- build/ and .tools/: local build artifacts/tools, ignored by Git.

## Build on Windows
Run in the repository root:

```powershell
python tools/bootstrap_rojo.py
New-Item -ItemType Directory -Path build -Force
.\.tools\rojo.exe build default.project.json -o build/MidnightFoodCourt.rbxl
.\.tools\rojo.exe build default.project.json -o build/MidnightFoodCourt.rbxlx
python tools/verify_repository.py --xml build/MidnightFoodCourt.rbxlx
```

Rojo is pinned to 7.7.1. Rokit users can instead install the tool from rokit.toml and use rojo directly.

Open build/MidnightFoodCourt.rbxl as a separate local place to review it. This does not publish over the existing game. External Roblox asset permissions, experience settings and DataStores are not exported by this build.

## Edit source
1. Begin from a clean/reviewed Git working tree. Read HANDOFF.md.
2. Edit src files. The project maps them to their original Studio paths.
3. Build/review the local place. For live sync, use Rojo's Studio plugin with rojo serve default.project.json, inspect its change preview and confirm the intended place before connecting.

The guarded launcher checks for unresolved Git conflicts/conflict markers, validates the repository and enforces Rojo 7.7.1 before serving:

```powershell
.\tools\start_rojo_sync.ps1
```

Use `-RequireBaseline` when the exported baseline is expected to be unchanged. The launcher intentionally does not auto-accept the Studio plugin change preview; review that preview before connecting so unexpected Studio/file differences cannot be applied silently.
4. Run the relevant gameplay tests and update docs.
5. Review git diff, commit, then push to the chosen remote.

Rojo serve is not a guarantee that Studio edits are exported to disk. If an agent edits through Studio MCP, it must also export the final changed scripts/models back into this repo before declaring the task complete.

## Bring intentional Studio changes back
Save a separate current .rbxl file from Studio first. On a clean/reviewed branch, preview:

```powershell
.\.tools\rojo.exe syncback default.project.json --input path/to/current.rbxl --dry-run --list
```

Review the output before running the same command without --dry-run. Syncback can rewrite project files/assets and should not run over uncommitted work. Rebuild and re-run verification afterwards.

## Git setup / push
The repository was initialized locally with branch main. Staging from this agent environment was blocked by permission denied on .git/index.lock even after a scoped filesystem grant. Stage and commit from your own terminal. No remote URL was provided and no network push was performed. If Git has no user identity, configure your own name/email before committing:

```powershell
git config user.name "Your name"
git config user.email "your-email"
git add .
git status
git diff --cached --stat
git commit -m "Import Midnight Food Court source, assets and documentation"
git remote add origin YOUR_REPOSITORY_URL
git push -u origin main
```

No passwords, Roblox cookies or API keys are required in source. Do not commit credentials.

## Migration verification and limits
- Read-only export from the confirmed Edit place; no live source replacement, cloud publication or purchase.
- 29 source files, 33 binary model files and 62 Rojo paths verified.
- Binary and XML builds succeeded; each source matches the XML build's Source with normalized line endings, class and original instance path.
- Original model serialization data was preserved in assets; copies are build inputs.
- Current scene uses primitive parts/meshes; Terrain:CountCells() returned 0.
- Rojo warns that Terrain.VoxelGridAssetContentMap uses a newer unsupported property type. The original Terrain.rbxm is retained, but this property is not guaranteed in rebuilt output. Do not use this baseline to validate future nonempty voxel terrain without a dedicated round-trip check.
- This build has not yet been opened/playtested in a separate Studio session. Earlier gameplay tests were against the original connected place.
- Studio flags remain StudioPurchaseSimulation=true and StudioUsesDataStore=true in the exported module folder; simulation wins in Studio.
- Experience access, marketplace product definitions, cloud data, moderation and hosted asset permissions remain Roblox-side configuration.

References: [Roblox external tools](https://create.roblox.com/docs/projects/external-tools), [Rojo project format](https://rojo.space/docs/v7/project-format/), [SerializationService](https://create.roblox.com/docs/reference/engine/classes/SerializationService).
