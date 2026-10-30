#!/usr/bin/env python3
"""Build verified Windows/Linux exports and package Windows; no upload performed."""
from pathlib import Path
import hashlib
import os
import re
import struct
import subprocess
import sys
import zipfile
ROOT=Path(__file__).resolve().parents[1]
env=os.environ.copy()
for key,leaf in [('XDG_DATA_HOME','data'),('XDG_CONFIG_HOME','config'),('XDG_CACHE_HOME','cache')]:
    env[key]=f'/workspace/.runtime/godot/{leaf}'
    Path(env[key]).mkdir(parents=True,exist_ok=True)
def run(command):
    result=subprocess.run(command,cwd=ROOT,env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=900)
    if result.returncode or re.search(r'(?m)^(ERROR:|SCRIPT ERROR:)',result.stdout):
        print(result.stdout[-18000:]); raise SystemExit(f'Build failed: {command} (exit={result.returncode})')
    print('PASS:', ' '.join(command[:4]),flush=True)
run([sys.executable,'tools/setup-export-templates.py'])
run(['godot','--headless','--path','.', '--editor','--import'])
run([sys.executable,'tools/verify-cloud.py'])
for platform,path in [('Windows Desktop','builds/windows/GaragemBrasil.exe'),('Linux Test','builds/linux/GaragemBrasil.x86_64')]:
    (ROOT/path).parent.mkdir(parents=True,exist_ok=True)
    run(['godot','--headless','--path','.', '--export-release',platform,path])
exe=ROOT/'builds/windows/GaragemBrasil.exe'
data=exe.read_bytes()
assert data[:2]==b'MZ'
pe=struct.unpack_from('<I',data,0x3c)[0]
assert data[pe:pe+4]==b'PE\0\0' and struct.unpack_from('<H',data,pe+4)[0]==0x8664
assert data[-4:]==b'GDPC','Embedded PCK missing'
version=re.search(r'config/version="([^"]+)"',(ROOT/'project.godot').read_text()).group(1)
folder=ROOT/'releases'
folder.mkdir(exist_ok=True)
archive=folder/f'GaragemBrasil-{version}-Windows-x64.zip'
readme=f'''GARAGEM BRASIL {version} - WINDOWS x64\n\n1. Extraia todo o ZIP.\n2. Abra GaragemBrasil.exe. Nao precisa instalar Godot ou Blender.\n3. No menu: Garagem para personalizar, Jogar para a pista, Configuracoes para qualidade/tela/volume.\n\nControles: W acelera, S freia/re, A/D viram, Espaco freio de mao.\nSHIFT usa nitro instalado na aba Desempenho. C alterna camera, ESC abre menu, R reposiciona.\nReparar (parado) recupera estado e nitro; na garagem use Desempenho > Reparar.\nP abre modo foto, F12 fotografa.\n\nSeus saves e fotos ficam em %APPDATA%\\Godot\\app_userdata\\Garagem Brasil.\nEsta exportacao foi gerada no Linux. A execucao no Windows precisa do teste do usuario.\nExecutavel sem assinatura digital.\n\nO projeto e um prototipo. Corridas com adversarios, cidade e dinheiro estao planejadas, ainda nao implementadas.\n'''
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
    z.write(exe,'GaragemBrasil.exe')
    z.writestr('LEIA-ME.txt',readme)
    assert z.testzip() is None
assert archive.stat().st_size<95*1024*1024,'Archive too large for GitHub Git upload'
sha=hashlib.file_digest(archive.open('rb'),'sha256').hexdigest()
(archive.with_suffix('.zip.sha256')).write_text(f'{sha}  {archive.name}\n')
print(f'PACKAGE: {archive.name} ({archive.stat().st_size//1024//1024} MiB); SHA-256 {sha}')
