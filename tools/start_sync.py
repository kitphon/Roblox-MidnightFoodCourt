"""One-click development startup, without changing PowerShell execution policy."""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import time
import urllib.request
from sync_bridge import PORT, ROOT, token

def status():
    try:
        return json.loads(urllib.request.urlopen(f"http://127.0.0.1:{PORT}/status",timeout=2).read())
    except Exception:
        return None

if __name__=="__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("--restart",action="store_true")
    args=parser.parse_args()
    subprocess.run([sys.executable,str(ROOT/"tools/setup_sync.py")],cwd=ROOT,check=True)
    existing=status()
    if existing and args.restart:
        subprocess.run([sys.executable,str(ROOT/"tools/sync_bridge.py"),"stop"],cwd=ROOT,check=True)
        deadline=time.time()+5
        while status() and time.time()<deadline: time.sleep(.2)
    elif existing:
        print(f"Sync server already running on {PORT}: {existing['state']}")
        raise SystemExit(0)
    local=ROOT/".sync"
    flags=getattr(subprocess,"CREATE_NO_WINDOW",0)|getattr(subprocess,"CREATE_NEW_PROCESS_GROUP",0)
    with (local/"server.log").open("a",encoding="utf-8") as out,(local/"server-error.log").open("a",encoding="utf-8") as err:
        process=subprocess.Popen([sys.executable,"-u",str(ROOT/"tools/sync_bridge.py"),"serve"],
                                  cwd=ROOT,stdout=out,stderr=err,stdin=subprocess.DEVNULL,creationflags=flags)
    deadline=time.time()+8
    while time.time()<deadline:
        if status():
            print(f"Started sync PID {process.pid}. Open the test game in Studio.")
            raise SystemExit(0)
        if process.poll() is not None: break
        time.sleep(.2)
    raise SystemExit("Sync startup failed; inspect .sync/server-error.log")
