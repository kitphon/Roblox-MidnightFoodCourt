"""Generate this machine's Studio plugin and install commit guards."""
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/"tools"))
from sync_bridge import token

if __name__=="__main__":
    version=subprocess.check_output([str(ROOT/".tools/rojo.exe"),"--version"],text=True).strip()
    if version!="Rojo 7.7.1":
        raise SystemExit("Expected pinned Rojo 7.7.1, found "+version)
    local=ROOT/".sync"
    local.mkdir(exist_ok=True)
    manifest=json.loads((ROOT/"studio-export/manifest.json").read_text(encoding="utf-8"))
    config={k:manifest[k] for k in ("placeId","gameId","scripts","assets")}
    config.update(port=34875,interval=2,token=token())
    (local/"plugin-config.json").write_text(json.dumps(config,indent=2),encoding="utf-8")
    project={"name":"MidnightRepoSync","tree":{"$className":"Folder",
        "Bootstrap":{"$path":"../tools/studio_sync/Bootstrap.server.luau"},
        "Bridge":{"$path":"../tools/studio_sync/Bridge.luau"},
        "Config":{"$path":"plugin-config.json"}}}
    (local/"plugin.project.json").write_text(json.dumps(project,indent=2),encoding="utf-8")
    plugin_dir=Path(os.environ["LOCALAPPDATA"])/"Roblox/Plugins"
    plugin_dir.mkdir(parents=True,exist_ok=True)
    target=plugin_dir/"MidnightRepoSync.rbxm"
    subprocess.run([str(ROOT/".tools/rojo.exe"),"build",str(local/"plugin.project.json"),"-o",str(target)],check=True,cwd=ROOT)
    hooks=ROOT/".git/hooks"
    hooks.mkdir(exist_ok=True)
    # Preserve existing custom hooks. Chain our check rather than overwrite them.
    for name in ("pre-commit","pre-push"):
        hook=hooks/name
        if hook.exists() and "Midnight sync guard" not in hook.read_text(encoding="utf-8"):
            raise SystemExit(f"Existing custom {name}: review before installing guards")
        hook.write_text('#!/bin/sh\n# Midnight sync guard\nroot="$(git rev-parse --show-toplevel)"\npython "$root/tools/sync_bridge.py" check || exit 1\n',encoding="utf-8")
        hook.chmod(0o755)
    print("Installed Studio plugin:",target)
    print("Installed pre-commit / pre-push guards. Start the local server, then open Studio.")
