#!/usr/bin/env python3
# prebuild.py: run before every build (build.sh, build.ps1, tools/verify_all.sh).
# Usage: python3 tools/prebuild.py
# The ROM must be present (and the right version): the build compares its output with it. If the ROM is missing or wrong,
# stops with the path, file name, SHA-1 and size it must have. Then makes sure Extracted/ is complete, and runs the
# extractor if it is not.
import hashlib, json, os, subprocess, sys

GAME = "NHLPA Hockey '93 (Super Nintendo)"
ROM = {'label': "NHLPA Hockey '93 SNES retail (USA)", 'file': 'lst/nhlpa93snes.bin',
       'sha1': '76a01492cfb656e9fce0094bca356c312adfea0e', 'size': 0x80000}
# ---------------------------------------------------------------------------------------------
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

def sha1_of(data): return hashlib.sha1(data).hexdigest()
def size_text(n):
    unit = f'{n // 0x100000} MB' if n >= 0x100000 else f'{n // 1024} KB'
    return f'{n} bytes (0x{n:X}, {unit})'

def stop(lines):
    print('', file=sys.stderr)
    print('*** BUILD STOPPED: ROM file needed ***', file=sys.stderr)
    print('\n'.join(lines), file=sys.stderr)
    print('', file=sys.stderr)
    print(f'ROMs are not included in the repo. Use your own dump of the {GAME} cartridge,', file=sys.stderr)
    print('saved under exactly that file name (no copier header), then run the build again. The assets in Extracted/', file=sys.stderr)
    print('are then extracted from it automatically.', file=sys.stderr)
    print('', file=sys.stderr)
    sys.exit(1)

# The ROM this build needs.
rom_path = os.path.join(ROOT, ROM['file'])
block = [f"  {ROM['label']}",
         f'    Put it at:  {rom_path}',
         f"                ({ROM['file']} in the repo folder)",
         f"    SHA-1:      {ROM['sha1']}",
         f"    Size:       {size_text(ROM['size'])}"]
if not os.path.exists(rom_path):
    stop(['This build needs this ROM, exactly the version shown:'] + block)
data = open(rom_path, 'rb').read()
if sha1_of(data) != ROM['sha1'] or len(data) != ROM['size']:
    stop([f'Found {rom_path}, but it is not the right ROM:',
          f'    its SHA-1 is {sha1_of(data)}, size {size_text(len(data))}.',
          '    (a bad dump, a hack, another revision, or a file with a 512-byte copier header)',
          'This build needs this ROM, exactly the version shown:'] + block)

# Is Extracted/ complete? The extractor writes the marker last, listing every file it wrote, the ROM it read and its
# own SHA-1. Any missing or resized file, an unknown ROM or a changed extractor means the folder has to be extracted again.
def extracted_state():
    if not os.path.isdir(EXTRACTED): return 'Extracted/ is missing'
    if not os.path.exists(MARKER): return 'Extracted/ is incomplete (no .extract-complete.json marker)'
    try:
        m = json.loads(open(MARKER, encoding='utf-8').read())
    except (OSError, json.JSONDecodeError):
        return 'the Extracted/ marker is unreadable'
    extractor = os.path.join(ROOT, 'tools', 'extract.py')
    if m.get('extractorSha1') != sha1_of(open(extractor, 'rb').read()):
        return 'tools/extract.py changed since the last extraction'
    if m.get('romSha1') != ROM['sha1']: return 'Extracted/ came from an unknown ROM'
    files = m.get('files')
    if not isinstance(files, list) or not files: return 'the Extracted/ marker lists no files'
    for f in files:
        p = os.path.join(EXTRACTED, f['path'])
        if not os.path.exists(p): return f"Extracted/{f['path']} is missing"
        if os.path.getsize(p) != f['size']: return f"Extracted/{f['path']} has the wrong size"
    return None

EXTRACTED = os.path.join(ROOT, 'Extracted')
MARKER = os.path.join(EXTRACTED, '.extract-complete.json')
why = extracted_state()
if not why:
    print('prebuild: ROM OK, Extracted/ assets complete.')
    sys.exit(0)
print(f'prebuild: {why}; extracting assets from {ROM["file"]} ...')
res = subprocess.run([sys.executable, os.path.join(ROOT, 'tools', 'extract.py'), rom_path], cwd=ROOT)
if res.returncode != 0 or extracted_state():
    print('*** BUILD STOPPED: asset extraction failed ***', file=sys.stderr)
    sys.exit(1)
print('prebuild: Extracted/ assets complete.')
