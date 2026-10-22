#!/usr/bin/env python3
"""Regenerate docs/file-map.md from src/banks/*.asm and output/retail/obj/nhlpa93snes.sym (run npm run build:retail first)."""
import os, re, glob
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'src')
sym = {}
for l in open(os.path.join(ROOT, 'output', 'retail', 'obj', 'nhlpa93snes.sym')):
    m = re.match(r'([0-9A-Fa-f]{2}):([0-9A-Fa-f]{4}) ([A-Za-z_]\w*)$', l.strip())
    if m: sym.setdefault(m.group(3), (m.group(1) + m.group(2)).upper())
out = ['# Source file map', '',
       '`src/nhlpa93snes.asm` includes one file per bank (`src/banks/bXX_<name>.asm`). Bank $80 sets its address with `org`.',
       'Each later bank orgs only when `pc()` has not already reached that address, so a bank that grew is not rewound.',
       'On the stock tree the PC arrives exactly there and the org is skipped. A bank file then includes its routine and data',
       'files in exact ROM order. Routines are in `src/routines/<93G module>/<area>/<Routine>.asm`',
       '(one routine per file; a routine that falls through into the next keeps both). Data blocks that are only an `incbin` sit in the bank file itself, at their ROM position (listed here by label); other data is in `src/data/<category>/<Name>.asm`.',
       'The SNES internal header and vectors are in `src/header/snes_header.asm` (end of bank $80).',
       'The ROM is 512 KB (banks $80-$8F). Bank $90 is not in the default build; docs/adding-a-team.md says how to add it.',
       'Regenerate this file with `python3 tools/gen_file_map.py` after `npm run build:retail`.', '']
for b in sorted(glob.glob(os.path.join(SRC, 'banks', '*.asm'))):
    text = open(b).read()
    out.append('## src/banks/%s' % os.path.basename(b)); out.append('')
    org = re.search(r'org\s+\$([0-9A-Fa-f]+)', text)
    guarded = re.search(r'if\s+pc\(\)\s*<\s*\$([0-9A-Fa-f]+)', text)
    if org:
        if guarded:
            out.append('org `$%s` when `pc()` is below it.' % org.group(1).upper())
        else:
            out.append('org `$%s`.' % org.group(1).upper())
        out.append('')
    files = 0
    for l in text.splitlines():
        m = re.match(r'incsrc "\.\./(.*)"', l)
        if not m:
            g = re.match(r'([A-Za-z_]\w*):', l)
            if g and not (g.group(1).endswith('End') and g.group(1)[:-3] in sym):
                files += 1
                out.append('- `$%s` %s (data)' % (sym.get(g.group(1), '??????'), g.group(1)))
            continue
        files += 1
        f = m.group(1)
        g = [x for x in re.findall(r'^([A-Za-z_]\w*):', open(os.path.join(SRC, f)).read(), re.M)]
        a = sym.get(g[0], '??????') if g else ('80FFC0' if 'snes_header' in f else '??????')
        out.append('- `$%s` %s%s' % (a, f, (' (also ' + ', '.join(g[1:]) + ')') if len(g) > 1 else ''))
    if files == 0:
        out.append('No bytes in the stock build.')
    out.append('')
open(os.path.join(ROOT, 'docs', 'file-map.md'), 'w').write('\n'.join(out))
