// prebuild.js: run before every build (tools/build.js, npm run build:*, assets).
// Usage: node tools/prebuild.js
// The ROM must be present (and the right version): the build compares its output with it. If the ROM is missing or
// wrong, stops with the path, file name, SHA-1 and size it must have. Then makes sure Extracted/ is complete, and runs
// the extractor if it is not.

const GAME = "NHLPA Hockey '93 (Super Nintendo)";
const EXTRACTOR = 'tools/extractAssets93s.js';
const { ROMS, findRom, sha1Of } = require('./roms');
const ROM = ROMS.retail;
// ---------------------------------------------------------------------------------------------
const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const ROOT = path.join(__dirname, '..');
const EXTRACTED = path.join(ROOT, 'Extracted');
const MARKER = path.join(EXTRACTED, '.extract-complete.json');

const sizeText = (n) => `${n} bytes (0x${n.toString(16).toUpperCase()}, ${n / 0x100000 >= 1 ? n / 0x100000 + ' MB' : n / 1024 + ' KB'})`;

function romBlock(rom) {
    return [
        `  ${rom.label}`,
        `    Put it in:  ${ROOT}`,
        `                (any file name: it is found by its SHA-1 and size; ${rom.file} is the usual name)`,
        `    SHA-1:      ${rom.sha1}`,
        `    Size:       ${sizeText(rom.size)}`,
    ].join('\n');
}

function stop(lines) {
    console.error('');
    console.error('*** BUILD STOPPED: ROM file needed ***');
    console.error(lines.join('\n'));
    console.error('');
    console.error(`ROMs are not included in the repo. Use your own dump of the ${GAME} cartridge,`);
    console.error('in the repo folder (any file name, no copier header), then run the build again. The assets in Extracted/');
    console.error('are then extracted from it automatically.');
    console.error('');
    process.exit(1);
}

// Is Extracted/ complete? The extractor writes the marker last, listing every file it wrote, the ROM it read and its
// own SHA-1. Any missing or resized file, an unknown ROM or a changed extractor means the folder has to be extracted again.
function extractedState() {
    if (!fs.existsSync(EXTRACTED)) return 'Extracted/ is missing';
    if (!fs.existsSync(MARKER)) return 'Extracted/ is incomplete (no .extract-complete.json marker)';
    let m;
    try { m = JSON.parse(fs.readFileSync(MARKER, 'utf8')); } catch (e) { return 'the Extracted/ marker is unreadable'; }
    if (m.extractorSha1 !== sha1Of(fs.readFileSync(path.join(ROOT, EXTRACTOR)))) return `${EXTRACTOR} changed since the last extraction`;
    if (m.romSha1 !== ROM.sha1) return 'Extracted/ came from an unknown ROM';
    if (!Array.isArray(m.files) || m.files.length === 0) return 'the Extracted/ marker lists no files';
    for (const f of m.files) {
        const p = path.join(EXTRACTED, f.path);
        if (!fs.existsSync(p)) return `Extracted/${f.path} is missing`;
        if (fs.statSync(p).size !== f.size) return `Extracted/${f.path} has the wrong size`;
    }
    return null;
}

// 1. The ROM this build needs: a file in the repo folder with this SHA-1 and size, whatever its name.
const found = findRom(ROM);
if (!found.ok) {
    if (found.reason === 'wrong') {
        stop([`Found ${found.path}, but it is not the right ROM:`,
              `    its SHA-1 is ${found.sha1}, size ${sizeText(found.size)}.`,
              '    (a bad dump, a hack, another revision, or a file with a 512-byte copier header)',
              'This build needs this ROM, exactly the version shown:', romBlock(ROM)]);
    }
    stop(['This build needs this ROM, exactly the version shown:', romBlock(ROM)]);
}
const romPath = found.path;

// 2. Extracted/ assets: extract again if missing or incomplete.
const why = extractedState();
if (!why) {
    console.log('prebuild: ROM OK, Extracted/ assets complete.');
    process.exit(0);
}
console.log(`prebuild: ${why}; extracting assets from ${path.relative(ROOT, romPath)} ...`);
const res = spawnSync(process.execPath, [path.join(ROOT, EXTRACTOR), romPath], { cwd: ROOT, encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 });
const out = (res.stdout || '') + (res.stderr || '');
const after = res.status === 0 ? extractedState() : 'the extractor failed';
if (after) {
    console.error(out);
    console.error(`*** BUILD STOPPED: asset extraction failed (${after}) ***`);
    process.exit(1);
}
for (const l of out.split(/\r?\n/).filter((l) => /^ROM:|^Extracted \d+ assets|^deleted/.test(l))) console.log('prebuild: ' + l);
console.log('prebuild: Extracted/ assets complete.');
