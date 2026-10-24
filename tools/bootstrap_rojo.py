"""Download pinned Rojo CLI locally from its official GitHub release."""
import io
import platform
import urllib.request
import zipfile
from pathlib import Path

VERSION = "7.7.1"
ROOT = Path(__file__).resolve().parents[1]

if __name__ == "__main__":
    if platform.system() != "Windows":
        raise SystemExit("Use Rokit/your OS package for Rojo 7.7.1 on this platform.")
    arch = "aarch64" if platform.machine().lower() in ("arm64", "aarch64") else "x86_64"
    url = f"https://github.com/rojo-rbx/rojo/releases/download/v{VERSION}/rojo-{VERSION}-windows-{arch}.zip"
    data = urllib.request.urlopen(url, timeout=60).read()
    target = ROOT / ".tools"
    target.mkdir(exist_ok=True)
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        (target / "rojo.exe").write_bytes(archive.read("rojo.exe"))
    print(f"Installed Rojo {VERSION} to {target}; no system installation.")
