# rompath.py: where the retail ROM is. The ROM is found in the repo's root folder by its content (SHA-1 and size), whatever its file
# name, by tools/roms.js; this asks it (so Node.js is needed, as for the build) and falls back to nhlpa93retail.sfc.
import os, subprocess

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

def rom_path():
    try:
        out = subprocess.run(['node', os.path.join(ROOT, 'tools', 'roms.js')], capture_output=True, text=True, cwd=ROOT)
        if out.returncode == 0 and out.stdout.strip(): return out.stdout.strip()
    except OSError:
        pass
    return os.path.join(ROOT, 'nhlpa93retail.sfc')
