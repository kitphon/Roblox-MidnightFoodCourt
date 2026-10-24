"""Loopback-only, conflict-preserving three-way sync for maintained scripts."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import secrets
import subprocess
import threading
import time
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

ROOT = Path(__file__).resolve().parents[1]
PLACE, UNIVERSE, PORT = 120399989321685, 10772566896, 34875

def norm(s):
    # Ignore editor/export-only blank lines at EOF, preserve all interior whitespace.
    return s.replace("\r\n", "\n").replace("\r", "\n").rstrip("\n") + "\n"

def sha(s):
    return hashlib.sha256(norm(s).encode()).hexdigest()

def decision(base, disk, studio):
    if disk == studio: return "equal"
    if base is None: return "conflict"
    if studio == base: return "push"
    if disk == base: return "pull"
    return "conflict"

def save_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_suffix(path.suffix + ".tmp")
    temp.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")
    os.replace(temp, path)

class Engine:
    def __init__(self, root=ROOT, git_check=True):
        self.root = Path(root).resolve()
        self.local = self.root / ".sync"
        self.local.mkdir(exist_ok=True)
        self.scripts = json.loads((self.root / "studio-export/manifest.json").read_text(encoding="utf-8"))["scripts"]
        self.paths = {}
        for i, entry in enumerate(self.scripts):
            path = (self.root / entry["file"]).resolve()
            if not path.is_relative_to(self.root) or path.suffix != ".luau":
                raise ValueError("Invalid source path")
            self.paths[str(i)] = (path, entry)
        project = self.root / "default.project.json"
        self.project_hash = hashlib.sha256(project.read_bytes()).hexdigest() if project.exists() else None
        base = self.local / "base.json"
        self.base = json.loads(base.read_text(encoding="utf-8")) if base.exists() else {}
        self.git_check = git_check
        self.lock = threading.Lock()
        self.challenge = 0
        self.status = {"state": "waiting", "checkedAt": 0}
        self.report()

    def report(self):
        save_json(self.local / "status.json", self.status)

    def exchange(self, data):
        with self.lock:
            return self.reconcile(data)

    def reconcile(self, data):
        if data.get("placeId") != PLACE or data.get("gameId") != UNIVERSE:
            raise ValueError("Wrong place/universe")
        if data.get("running"):
            self.status = {"state": "paused-play", "checkedAt": time.time()}
            self.report()
            return {"state": "paused-play", "updates": []}
        sources = data.get("scripts", {})
        if set(sources) != set(self.paths):
            raise ValueError("Inventory changed: no automatic creation/deletion")
        actual={p.resolve() for p in (self.root/"src").rglob("*") if p.suffix in (".lua",".luau")}
        if actual!={p for p,_ in self.paths.values()}:
            raise ValueError("Source files added/removed: register mappings and restart sync")
        if self.project_hash is not None and hashlib.sha256((self.root/"default.project.json").read_bytes()).hexdigest()!=self.project_hash:
            raise ValueError("Rojo project changed: review mappings and restart sync")
        if self.git_check:
            result = subprocess.run(["git", "-c", "safe.directory=" + self.root.as_posix(), "ls-files", "-u"],
                                    cwd=self.root, capture_output=True, text=True, timeout=10)
            if result.returncode or result.stdout.strip():
                raise ValueError("Git conflict state unavailable or unresolved")
        plan, conflicts = {}, []
        for key, (path, entry) in self.paths.items():
            value = sources[key]
            if value.get("class") != entry["class"] or not isinstance(value.get("source"), str):
                raise ValueError("Wrong script class/source: " + entry["file"])
            disk, studio = norm(path.read_text(encoding="utf-8")), norm(value["source"])
            mode = decision(self.base.get(key), disk, studio)
            markers = any(line.startswith(("<<<<<<<", "=======", ">>>>>>>")) for line in (disk + "\n" + studio).splitlines())
            plan[key] = (mode, disk, studio)
            if mode == "conflict" or markers:
                conflicts.append(entry["file"])
                folder = self.local / "conflicts" / key
                folder.mkdir(parents=True, exist_ok=True)
                for label, text in (("disk", disk), ("studio", studio)):
                    (folder / (label + "-" + sha(text)[:16] + ".luau")).write_text(text, encoding="utf-8")
        if conflicts:
            self.status = {"state": "conflict", "checkedAt": time.time(), "conflicts": conflicts}
            self.report()
            return {"state": "conflict", "conflicts": conflicts, "updates": []}
        for key, (_, disk, _) in plan.items():
            if norm(self.paths[key][0].read_text(encoding="utf-8")) != disk:
                raise ValueError("Disk changed during exchange; retry")
        updates = []
        for key, (mode, disk, studio) in plan.items():
            path, entry = self.paths[key]
            if mode == "push":
                updates.append({"id": key, "base": studio, "source": disk})
            else:
                if mode == "pull":
                    backup = self.local / "backups" / key / (sha(disk) + ".luau")
                    backup.parent.mkdir(parents=True, exist_ok=True)
                    if not backup.exists(): backup.write_text(disk, encoding="utf-8")
                    temp = path.with_suffix(".luau.sync-tmp")
                    temp.write_text(studio, encoding="utf-8")
                    os.replace(temp, path)
                self.base[key] = studio
        save_json(self.local / "base.json", self.base)
        self.status = {"state": "pending" if updates else "synced", "checkedAt": time.time(),
                       "pending": [u["id"] for u in updates],
                       "files": {e["file"]: sha(p.read_text(encoding="utf-8")) for p, e in self.paths.values()},
                       "sceneDirty": bool(data.get("sceneDirty")),
                       "audit": data.get("audit") if data.get("audit")==self.challenge else 0}
        self.report()
        return {"state": self.status["state"], "updates": updates}

def token(root=ROOT):
    path = root / ".sync/token"
    path.parent.mkdir(exist_ok=True)
    if not path.exists(): path.write_text(secrets.token_urlsafe(32), encoding="utf-8")
    return path.read_text(encoding="utf-8").strip()

def request_audit(root):
    headers={"Content-Type":"application/json","X-Midnight-Sync":token(root)}
    request=urllib.request.Request(f"http://127.0.0.1:{PORT}/audit",data=b"{}",headers=headers)
    challenge=json.loads(urllib.request.urlopen(request,timeout=3).read())["audit"]
    deadline=time.time()+10
    while time.time()<deadline:
        status=json.loads((root/".sync/status.json").read_text(encoding="utf-8"))
        if status.get("state") in ("conflict","error","paused-play"):
            raise ValueError("Studio sync "+status["state"]+": "+str(status.get("conflicts",status.get("message",""))))
        if status.get("audit")==challenge:
            return
        time.sleep(.2)
    raise ValueError("Studio did not answer the live audit; commit blocked")

def check(root=ROOT, live=False):
    if live: request_audit(root)
    status = json.loads((root / ".sync/status.json").read_text(encoding="utf-8"))
    if status.get("state") != "synced" or time.time() - status.get("checkedAt", 0) > 12:
        raise ValueError("Studio is offline, paused, pending or conflicted; wait for SYNCED")
    if status.get("sceneDirty"):
        raise ValueError("Scene/models changed in Studio; export/review assets before committing")
    scripts = json.loads((root / "studio-export/manifest.json").read_text(encoding="utf-8"))["scripts"]
    for entry in scripts:
        if status.get("files", {}).get(entry["file"]) != sha((root / entry["file"]).read_text(encoding="utf-8")):
            raise ValueError("Studio has not acknowledged " + entry["file"])
    if live: check_index(root,status,scripts)
    return status

def check_index(root,status,scripts):
    # Git commits the index, not necessarily the current working tree.
    for entry in scripts:
        staged=subprocess.run(["git","-c","safe.directory="+root.as_posix(),"show",":"+entry["file"]],
                              cwd=root,capture_output=True,timeout=10)
        if staged.returncode==0 and sha(staged.stdout.decode("utf-8"))!=status["files"][entry["file"]]:
            raise ValueError("Staged source differs from Studio: "+entry["file"])
    deleted=subprocess.run(["git","-c","safe.directory="+root.as_posix(),"diff","--cached","--name-only","--diff-filter=D"],
                           cwd=root,capture_output=True,text=True,timeout=10)
    if deleted.returncode or set(deleted.stdout.splitlines()) & {e["file"] for e in scripts}:
        raise ValueError("Maintained source deletion is staged; review mappings first")

def serve(port):
    engine, secret = Engine(), token()
    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path != "/status": self.send_error(404); return
            self.reply(engine.status)
        def do_POST(self):
            if self.headers.get("X-Midnight-Sync") != secret:
                self.send_error(403); return
            if self.path == "/stop":
                engine.status = {"state": "stopped", "checkedAt": time.time()}
                engine.report()
                self.reply(engine.status)
                threading.Thread(target=self.server.shutdown, daemon=True).start()
                return
            if self.path == "/audit":
                with engine.lock:
                    engine.challenge+=1
                    self.reply({"audit":engine.challenge})
                return
            if self.path != "/sync":
                self.send_error(404); return
            try:
                size = int(self.headers.get("Content-Length", 0))
                if size <= 0 or size > 4_000_000: raise ValueError("Invalid size")
                self.reply(engine.exchange(json.loads(self.rfile.read(size))))
            except Exception as error:
                engine.status = {"state": "error", "checkedAt": time.time(), "message": str(error)}
                engine.report()
                self.reply(dict(engine.status, updates=[]), 409)
        def reply(self, data, code=200):
            body = json.dumps(dict(data,audit=engine.challenge)).encode()
            self.send_response(code)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        def log_message(self, *_): pass
    print(f"Midnight sync on 127.0.0.1:{port}", flush=True)
    ThreadingHTTPServer(("127.0.0.1", port), Handler).serve_forever()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=["serve", "check", "stop"])
    parser.add_argument("--port", type=int, default=PORT)
    args = parser.parse_args()
    if args.action == "serve": serve(args.port)
    elif args.action == "stop":
        request=urllib.request.Request(f"http://127.0.0.1:{args.port}/stop",data=b"{}",
            headers={"Content-Type":"application/json","X-Midnight-Sync":token()})
        print(urllib.request.urlopen(request,timeout=3).read().decode())
    else:
        try:
            result = check(live=True)
            print(f"SYNCED: {len(result['files'])} scripts acknowledged by Studio")
        except Exception as error:
            raise SystemExit("COMMIT BLOCKED: " + str(error))
