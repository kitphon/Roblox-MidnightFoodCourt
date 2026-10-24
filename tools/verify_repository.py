"""Validate source/model references and optional Rojo XML round-trip."""
import argparse
import hashlib
import json
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]

def validate(xml_path=None, baseline=False):
    manifest = json.loads((ROOT / "studio-export/manifest.json").read_text(encoding="utf-8"))
    project = json.loads((ROOT / "default.project.json").read_text(encoding="utf-8"))
    assert project["servePlaceIds"] == [120399989321685]
    if baseline:
        checksums = json.loads((ROOT / "studio-export/checksums.json").read_text(encoding="utf-8"))
        for file, expected in checksums["files"].items():
            data = (ROOT / file).read_bytes()
            assert len(data) == expected["bytes"], file
            assert hashlib.sha256(data).hexdigest() == expected["sha256"], file
    count = 0
    def visit(node):
        nonlocal count
        if not isinstance(node, dict):
            return
        if "$path" in node:
            path = (ROOT / node["$path"]).resolve()
            assert path.is_relative_to(ROOT) and path.is_file(), node["$path"]
            count += 1
        for key, child in node.items():
            if not key.startswith("$"):
                visit(child)
    visit(project["tree"])
    for asset in manifest["assets"]:
        path = ROOT / asset["file"]
        assert path.read_bytes().startswith(b"<roblox!"), asset["file"]
    if xml_path:
        root = ET.parse(xml_path).getroot()
        def name(item):
            return item.findtext("./Properties/string[@name='Name']")
        def locate(parts):
            parent = root
            for part in parts:
                parent = next(item for item in parent.findall("Item") if name(item) == part)
            return parent
        for script in manifest["scripts"]:
            item = locate(script["parts"])
            assert item.attrib["class"] == script["class"], script["file"]
            prop = item.find("./Properties/ProtectedString[@name='Source']")
            if prop is None:
                prop = item.find("./Properties/string[@name='Source']")
            actual = prop.text or ""
            expected = (ROOT / script["file"]).read_text(encoding="utf-8")
            assert actual.replace("\r\n", "\n") == expected.replace("\r\n", "\n"), script["file"]
        terrain = locate(["Workspace", "Terrain"])
        assert terrain.attrib["class"] == "Terrain"
        assert len([x for x in root.iter("Item") if x.attrib["class"] in ("Script", "LocalScript", "ModuleScript")]) == len(manifest["scripts"])
    print(f"OK: {len(manifest['scripts'])} scripts, {len(manifest['assets'])} binary assets, {count} project paths.")
    if xml_path:
        print("OK: every source round-trips through Rojo with exact normalized text and expected class/path.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--xml", type=Path)
    parser.add_argument("--baseline", action="store_true", help="Also verify unchanged initial export hashes.")
    args = parser.parse_args()
    validate(args.xml, args.baseline)
