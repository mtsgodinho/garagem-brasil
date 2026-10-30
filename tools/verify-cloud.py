#!/usr/bin/env python3
"""Checks isolated from real player saves; requires installed Godot and Python 3."""
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
RUNTIME = Path('/workspace/.runtime/save-tests')
RUNTIME.mkdir(parents=True, exist_ok=True)
fixture = Path(tempfile.mkdtemp(prefix='process-', dir=RUNTIME))

def run(script, *args):
    command = [str(ROOT / 'tools/godot-cloud.sh'), '--headless', '--script', script]
    if args:
        command += ['--', *args]
    result = subprocess.run(command, cwd=ROOT, text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, timeout=25)
    print(result.stdout, end='', flush=True)
    if result.returncode or re.search(r'(?m)^(SCRIPT ERROR:|ERROR:)', result.stdout):
        raise SystemExit(f'FAILED: {script} {args} (exit={result.returncode})')

for script in ('tests/smoke.gd', 'tests/customization.gd', 'tests/persistence.gd', 'tests/accessories.gd', 'tests/visual_model.gd'):
    run(script)
path = str(fixture / 'customization.json')
for mode in ('write', 'read', 'exit', 'read-exit'):
    run('tests/persistence_process.gd', mode, path)
run('tests/persistence_process.gd', 'failure', str(fixture / 'failure.json'))
print('PASS: verificações e reabertura em processos independentes; dados do jogador intactos')
