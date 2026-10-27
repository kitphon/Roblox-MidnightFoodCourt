"""Stage Studio model exports for review; never overwrites maintained assets."""
import json
import sys
import xml.etree.ElementTree as ET
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ENTRIES = json.loads((ROOT / 'studio-export/manifest.json').read_text())['assets']
STAGING = ROOT / '.sync/scene-review'

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        try:
            index = int(self.path.removeprefix('/asset/'))
            if self.path != f'/asset/{index}' or not 0 <= index < len(ENTRIES):
                raise ValueError('Unknown asset')
            data = bytes.fromhex(self.rfile.read(int(self.headers['Content-Length'])).decode('ascii'))
            if not data.startswith(b'<roblox!'):
                raise ValueError('Invalid model')
            target = STAGING / ENTRIES[index]['file']
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b'Staged for review')
        except Exception as error:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(str(error).encode())
    def log_message(self, *_):
        pass

if __name__ == '__main__':
    STAGING.mkdir(parents=True, exist_ok=True)
    project = json.loads((ROOT / 'default.project.json').read_text())
    def paths(node):
        if not isinstance(node, dict):
            return
        if '$path' in node:
            relative = node['$path']
            staged = STAGING / relative
            node['$path'] = str(staged if staged.exists() else ROOT / relative)
        for child in node.values():
            paths(child)
    # Restart this helper after export to generate a project using the staged files.
    paths(project)
    (STAGING / 'review.project.json').write_text(json.dumps(project, indent=2))
    if '--project-only' in sys.argv:
        raise SystemExit(0)
    if '--compare' in sys.argv:
        def inventory(path):
            root = ET.parse(path).getroot()
            out = {}
            def walk(item, parent):
                props = item.find('Properties')
                name = props.findtext("string[@name='Name']", '')
                prefix = parent + '/' + name + ':' + item.attrib['class']
                count = 0
                key = prefix
                while key in out:
                    count += 1
                    key = prefix + '#' + str(count)
                def clean(element):
                    return (element.tag, tuple(sorted(element.attrib.items())), (element.text or '').strip(), tuple(clean(c) for c in element))
                out[key] = {p.attrib['name']: clean(p) for p in props
                            if p.tag not in ('Ref', 'UniqueId') and p.attrib['name'] not in ('HistoryId',)}
                def order(child):
                    return (child.findtext("Properties/string[@name='Name']", ''), child.attrib['class'],
                            tuple(c.text or '' for c in child.findall("Properties/CoordinateFrame[@name='CFrame']/*")),
                            child.findtext("Properties/string[@name='Text']", ''))
                for child in sorted(item.findall('Item'), key=order):
                    walk(child, key)
            for item in root.findall('Item'):
                walk(item, '')
            return out
        before = inventory(ROOT / 'build/scene-before.rbxlx')
        after = inventory(ROOT / 'build/scene-review.rbxlx')
        changes = []
        for key in sorted(before.keys() | after.keys()):
            if key not in before or key not in after:
                changes.append({'instance': key, 'change': 'added' if key in after else 'removed'})
            else:
                for prop in sorted(before[key].keys() | after[key].keys()):
                    if before[key].get(prop) != after[key].get(prop):
                        changes.append({'instance': key, 'property': prop, 'before': before[key].get(prop), 'after': after[key].get(prop)})
        (STAGING / 'diff.json').write_text(json.dumps(changes, indent=2))
        print(json.dumps(changes[:35], indent=2))
        print('Total differences:', len(changes))
        raise SystemExit(0)
    print('Scene export receiver: 127.0.0.1:34876 (staging only)', flush=True)
    HTTPServer(('127.0.0.1', 34876), Handler).serve_forever()
