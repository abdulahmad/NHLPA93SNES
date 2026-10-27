// roms.js: the ROM this build needs, and where it is. The ROM is found in the repo's root folder by its content (size, then
// SHA-1), so the file can have any name; the usual name (`file` below) is tried first. Used by tools/prebuild.js, tools/build.js,
// tools/verifyRom.js, tools/verifySegment.js and the extractor, and from the command line (prints the path of the ROM):
//   node tools/roms.js [retail]
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const ROOT = path.join(__dirname, '..');
const ROMS = {
    retail: { label: "NHLPA Hockey '93 SNES retail (USA)", file: 'nhlpa93retail.sfc',
              sha1: '76a01492cfb656e9fce0094bca356c312adfea0e', size: 0x80000 },
};
// The file extensions of ROM dumps that are looked at (SNES dumps are .sfc or .smc).
const ROM_FILE = /\.(sfc|smc|bin)$/i;

const sha1Of = (buf) => crypto.createHash('sha1').update(buf).digest('hex');

// { ok: true, path } when a file in the root folder is this ROM; otherwise { ok: false, reason: 'missing' } or, when the file
// with the usual name is there but is not this ROM, { ok: false, reason: 'wrong', path, sha1, size }.
function findRom(rom) {
    const names = [rom.file, ...fs.readdirSync(ROOT).filter((f) => f !== rom.file && ROM_FILE.test(f))];
    let wrong = null;
    for (const name of names) {
        const p = path.join(ROOT, name);
        let st;
        try { st = fs.statSync(p); } catch (e) { continue; }
        if (!st.isFile()) continue;
        if (st.size !== rom.size && name !== rom.file) continue;      // not worth reading
        const data = fs.readFileSync(p);
        const sha1 = sha1Of(data);
        if (sha1 === rom.sha1 && data.length === rom.size) return { ok: true, path: p };
        if (name === rom.file) wrong = { ok: false, reason: 'wrong', path: p, sha1, size: data.length };
    }
    return wrong || { ok: false, reason: 'missing', path: path.join(ROOT, rom.file) };
}

// The path of the ROM with this id ('retail'), or null.
function romPath(id = 'retail') {
    const rom = ROMS[id];
    const r = rom && findRom(rom);
    return r && r.ok ? r.path : null;
}

module.exports = { ROOT, ROMS, findRom, romPath, sha1Of };

if (require.main === module) {
    const id = process.argv[2] || 'retail';
    const p = romPath(id);
    if (!p) { console.error(`The ${id} ROM is not in the repo folder (see node tools/prebuild.js).`); process.exit(1); }
    console.log(p);
}
