#!/usr/bin/env python3
"""Install pinned official templates after SHA-512 verification; standard library only."""
import hashlib
import json
import os
from pathlib import Path
import urllib.request
import zipfile
VERSION = '4.6.3'
BASE = f'https://github.com/godotengine/godot-builds/releases/download/{VERSION}-stable/'
ARCHIVE = f'Godot_v{VERSION}-stable_export_templates.tpz'
ROOT = Path(os.environ.get('XDG_DATA_HOME', '/workspace/.runtime/godot/data')) / 'godot/export_templates' / f'{VERSION}.stable'
CACHE = Path('/workspace/.runtime/export-tools')
ROOT.mkdir(parents=True, exist_ok=True)
CACHE.mkdir(parents=True, exist_ok=True)
manifest = ROOT / 'verified-files.json'
if manifest.exists():
    records = json.loads(manifest.read_text())
    if records and all((ROOT/name).is_file() and hashlib.file_digest((ROOT/name).open('rb'),'sha512').hexdigest() == digest for name,digest in records.items()):
        print('Verified export templates already installed',flush=True)
        raise SystemExit(0)
with urllib.request.urlopen(BASE+'SHA512-SUMS.txt',timeout=60) as response:
    sums=response.read().decode()
expected=next(line.split()[0] for line in sums.splitlines() if line.split()[-1].lstrip('*') == ARCHIVE)
path=CACHE/(ARCHIVE+'.partial')
digest=hashlib.sha512()
with urllib.request.urlopen(BASE+ARCHIVE,timeout=90) as response, path.open('wb') as output:
    size=0
    reported=0
    while chunk:=response.read(4*1024*1024):
        output.write(chunk); digest.update(chunk); size+=len(chunk)
        if size-reported>=128*1024*1024:
            print(f'Downloaded {size//(1024*1024)} MiB',flush=True); reported=size
if digest.hexdigest()!=expected:
    path.unlink()
    raise SystemExit('Official SHA-512 mismatch; archive discarded')
records={}
with zipfile.ZipFile(path) as archive:
    for name in ['windows_release_x86_64.exe','linux_release.x86_64','version.txt']:
        member=next((n for n in archive.namelist() if n.rsplit('/',1)[-1]==name),None)
        if member is None: raise SystemExit(f'Official archive missing {name}')
        data=archive.read(member)  # ZIP CRC validation also performed here.
        (ROOT/name).write_bytes(data)
        records[name]=hashlib.sha512(data).hexdigest()
        if name.startswith('linux_'): (ROOT/name).chmod(0o755)
manifest.write_text(json.dumps(records,indent=2)+'\n')
path.unlink()
print('Official SHA-512 verified; Windows/Linux release templates installed',flush=True)
