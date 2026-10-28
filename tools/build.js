#!/usr/bin/env node
// build.js: the whole NHLPA 93 (SNES) build, one line per step, on Windows, Linux and macOS (same tool as
// NHLPA93Genesis tools/build.js).
//   node tools/build.js [retail] [--verbose]   full ROM -> output/retail/nhlpa93snes.sfc
//   node tools/build.js --clean                delete output/ and Extracted/
// --no-color (or NO_COLOR) turns the colors off; they are also off when the output is not a terminal.
// retail: assembled with asar 1.91 (tools/bin/asar from tools/setup.sh, else asar on PATH), the header patched if the image
// grew (tools/patchHeader.js; the stock image is left as it is), verified against the ROM (found in the repo folder by its SHA-1 and size, any file name: tools/roms.js).
// The mode has its own folder: output/retail/nhlpa93snes.sfc is the ROM, output/retail/obj/ holds the intermediates
// (asar's log and its symbol file).
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const ROOT = path.join(__dirname, '..');
const WIN = process.platform === 'win32';
const BIN = path.join(ROOT, 'tools', 'bin', WIN ? 'asar.exe' : 'asar');
const MODES = {
    retail: {},
};

const args = process.argv.slice(2);
const verbose = args.includes('--verbose');
const modeName = args.find((a) => MODES[a]) || 'retail';
const mode = MODES[modeName];
const OUT = path.join(ROOT, 'output', modeName);
const OBJ = path.join(OUT, 'obj');
const ROM = 'nhlpa93snes.sfc';
const { ROMS, findRom } = require('./roms');
// The generated file gets each player's id (the number of his placeholder, P001) as a comment at the end of his row.
const idNote = (rest, ph) => rest + (rest.includes(';') ? ' ' : '\t;') + ph.slice(0, 4);
const rel = (p) => path.relative(ROOT, p).split(path.sep).join('/');

// ANSI colors: off when stdout is not a terminal, NO_COLOR is set, or --no-color. Windows 10+ cmd and
// PowerShell take ANSI codes from Node directly.
const color = process.stdout.isTTY && !('NO_COLOR' in process.env) && !args.includes('--no-color');
const sgr = (code) => (t) => (color ? `\x1b[${code}m${t}\x1b[0m` : String(t));
const c = { dim: sgr('2'), cyan: sgr('36'), green: sgr('32'), yellow: sgr('33'), red: sgr('31'), bold: sgr('1') };
// Values (numbers, $hex, output paths) bold; OK / MATCH green; warnings yellow.
const paint = (t) => t
    .replace(/(output\/\S+|\$[0-9A-F]+|\b\d+(?:\.\d+)?s?\b)/g, (m) => c.bold(m))
    .replace(/\b(MATCH|OK)\b/g, (m) => c.green(m))
    .replace(/\b([1-9]\d*)(\x1b\[0m)? (warnings|skipped)/g, (m) => c.yellow(m))
    .replace(/not verified \([^)]*\)/, (m) => c.yellow(m));

let steps = 0;
let n = 0;
// Each step is two lines: "[n/6] <step>  <description>", then the result under the description.
// In a colour terminal the step line shows a spinner and a yellow step name while it runs, and is
// redrawn with a green check or a red cross when it ends (cut to the terminal width so it never
// wraps). Otherwise both lines are printed once, after the step.
const ABOUT = {
    names: 'put the real player names (extracted from the ROM) into a copy of src/data/teamdata93s.asm, which has placeholders',
    prebuild: 'check the retail ROM and extract graphics/sound/text assets into Extracted/',
    assemble: 'asar turns src/nhlpa93snes.asm into the ROM image',
    header: 'pad the image and store the checksum if the ROM grew (the stock image is left as it is)',
    verify: 'compare byte-for-byte with the retail ROM',
    output: 'delete the built ROMs and intermediates in output/',
    Extracted: 'delete extracted graphics/sound assets (rebuilt by the next build)',
};
const live = color;
// Braille spinner and check marks need a UTF-8 terminal; old Windows consoles get ASCII.
const utf8 = WIN ? Boolean(process.env.WT_SESSION || process.env.TERM_PROGRAM || process.env.ConEmuANSI)
    : /utf-?8/i.test(process.env.LC_ALL || process.env.LC_CTYPE || process.env.LANG || '');
const SPIN = utf8 ? ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'] : ['|', '/', '-', '\\'];
const OK = utf8 ? '✅' : 'OK';
const BAD = utf8 ? '❌' : 'X';
const MARK = 2;                                                      // columns of the mark: the emoji are two wide
const wide = (m) => /\p{Extended_Pictographic}/u.test(m) ? 1 : 0;   // extra columns beyond .length
const padMark = (m) => m + ' '.repeat(Math.max(0, MARK - m.length - wide(m)));
const INDENT = ' '.repeat(`[0/0] ${live ? ' '.repeat(MARK + 1) : ''}${''.padEnd(10)} `.length);
let current = null;
let dirty = false;
let timer = null;
let frame = 0;
function header(name, paintName, mark) {
    const head = `[${n}/${steps}] ${live ? `${padMark(mark)} ` : ''}${name.padEnd(10)} `;
    let desc = ABOUT[name] || '';
    const width = live ? (process.stdout.columns || 80) - 1 : Infinity;
    if (head.length + wide(mark) + desc.length > width) desc = desc.slice(0, Math.max(0, width - head.length - wide(mark) - 1)) + (width > head.length ? '…'.slice(0, utf8 ? 1 : 0) : '');
    const markPart = live ? `${paintName(padMark(mark))} ` : '';
    return `${c.cyan(`[${n}/${steps}]`)} ${markPart}${paintName(name.padEnd(10))} ${c.dim(desc)}`;
}
const draw = (text) => process.stdout.write(`\r\x1b[2K${text}`);
function stopSpin() { if (timer) { clearInterval(timer); timer = null; } }
function begin(name) {
    n++;
    current = name;
    dirty = false;
    if (!live) return;
    frame = 0;
    draw(header(name, c.yellow, SPIN[0]));
    timer = setInterval(() => { frame = (frame + 1) % SPIN.length; draw(header(name, c.yellow, SPIN[frame])); }, 80);
}
function finish(name, paintName, mark) {
    if (current !== name) begin(name);
    stopSpin();
    if (!live) console.log(header(name, (t) => t, ''));
    else if (!dirty) draw(`${header(name, paintName, mark)}\n`);
    else console.log(header(name, paintName, mark));
    current = null;
}
// Output is wrapped to the terminal width (a TTY only), each continuation line indented under its text, so long messages stay aligned.
// Colors (ANSI codes) do not count toward the width.
const visible = (s) => s.replace(/\x1b\[[0-9;]*m/g, '');
function wrap(text) {
    const width = process.stdout.columns ? process.stdout.columns - 1 : Infinity;
    const out = [];
    for (const raw of String(text).replace(/\s+$/, '').split(/\r?\n/)) {
        const lead = /^\s*/.exec(raw)[0];
        const room = Math.max(20, width - INDENT.length - lead.length - 2);
        if (visible(raw).length - lead.length <= room + 2) { out.push(raw); continue; }
        let line = lead;
        for (let word of raw.slice(lead.length).split(' ')) {
            while (visible(word).length > room && !word.includes('\x1b')) {   // an unbreakable token (a long path)
                if (line.trim()) { out.push(line); line = lead + '  '; }
                out.push(line + word.slice(0, room)); word = word.slice(room); line = lead + '  ';
            }
            if (line.trim() && visible(line).length + 1 + visible(word).length > room + lead.length + 2) { out.push(line); line = lead + '  '; }
            line += (line.trim() ? ' ' : '') + word;
        }
        out.push(line);
    }
    return out;
}
const step = (name, text) => { finish(name, c.green, OK); console.log(wrap(text).map((l) => INDENT + paint(l)).join('\n')); };
function detail(text) {
    if (!verbose || !text.trim()) return;
    if (live && current && !dirty) { stopSpin(); process.stdout.write('\n'); }
    dirty = true;
    console.log(wrap(text).map((l) => INDENT + l).join('\n'));
}
function fail(name, text, log, label = 'FAILED') {
    finish(name, c.red, BAD);
    console.log(wrap(`${label}: ${text}`).map((l, i) => INDENT + (i ? l : l.replace(label, c.red(label)))).join('\n'));
    if (log) console.log(wrap(log).map((l) => INDENT + l).join('\n'));
    console.log(c.red(`BUILD FAILED at ${name}`));
    process.exit(1);
}
// Child processes run async (spawn) so the spinner keeps turning while the assembler works.
function run(cmd, argv, opts = {}) {
    return new Promise((resolve) => {
        const chunks = [];
        let p;
        try { p = spawn(cmd, argv, { cwd: ROOT, ...opts }); } catch (e) { resolve({ status: -1, out: String(e) }); return; }
        p.stdout.on('data', (d) => chunks.push(d));
        p.stderr.on('data', (d) => chunks.push(d));
        p.on('error', (e) => resolve({ status: -1, out: Buffer.concat(chunks).toString('latin1') + String(e) }));
        p.on('close', (code) => resolve({ status: code, out: Buffer.concat(chunks).toString('latin1') }));
    });
}
// The child tools get the color / emoji choice of this terminal (prebuild.js colors its ROM message with it).
const node = async (script, argv) => {
    const r = await run(process.execPath, [path.join(__dirname, script), ...argv], { env: { ...process.env, ...(color ? { NHL_COLOR: '1' } : {}), NHL_EMOJI: utf8 ? '1' : '0' } });
    r.out = Buffer.from(r.out, 'latin1').toString('utf8');                 // run() reads output as latin1 (the assembler's); these tools write UTF-8
    return r;
};

// asar 1.91 with the options the stock build matches: no checksum fix (patchHeader.js stores it), a WLA symbol file.
async function assemble(name) {
    const base = path.join(OBJ, 'nhlpa93snes');
    const out = path.join(OBJ, ROM);
    fs.rmSync(out, { force: true });
    const argv = ['--fix-checksum=off', '--symbols=wla', `--symbols-path=${base}.sym`, 'src/nhlpa93snes.asm', out];
    // No asar yet (neither tools/bin nor on PATH): fetch it with the setup script (Windows: the prebuilt release; elsewhere: build v1.91).
    if (!fs.existsSync(BIN) && (await run('asar', ['--version'])).status === -1) {
        const setup = WIN
            ? ['powershell', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', path.join(__dirname, 'setup.ps1')]]
            : ['sh', [path.join(__dirname, 'setup.sh')]];
        console.log('                   asar not found: installing asar 1.91 into tools/bin (tools/' + path.basename(setup[1][setup[1].length - 1]) + ')');
        const s = await run(setup[0], setup[1]);
        if (s.status !== 0) fail(name, 'asar 1.91 not found and the automatic install failed (run `sh tools/setup.sh` or `tools\\setup.ps1` yourself, or put asar on PATH)', s.out);
    }
    let r = fs.existsSync(BIN) ? await run(BIN, argv) : await run('asar', argv);
    if (r.status === -1 && !fs.existsSync(BIN)) fail(name, 'asar 1.91 not found: run `sh tools/setup.sh` (Linux/macOS) or `tools\\setup.ps1` (Windows), or put asar on PATH', r.out);
    const logPath = `${base}.log`;
    fs.writeFileSync(logPath, r.out, 'latin1');
    if (r.status !== 0 || !fs.existsSync(out)) fail(name, `assembly failed, see ${rel(logPath)}`, r.out.split(/\r?\n/).filter((l) => l.trim()).slice(0, 40).join('\n'));
    detail(r.out);
    const warnings = (r.out.match(/warning/gi) || []).length;
    return { bin: out, warnings, version: ((await run(fs.existsSync(BIN) ? BIN : 'asar', ['--version'])).out.split(/\r?\n/)[0] || 'asar').replace(/,.*/, '') };
}

// The team data: src/data/teamdata93s.asm holds placeholders instead of the NHLPA player names. The extractor writes the real
// names from the ROM to Extracted/Text/PlayerNames.txt (one per line, in the order of the %Player rows); this copies the source
// to obj/teamdata93s.asm with each placeholder replaced by its name, which src/banks/b83_teams.asm includes. A name must have
// the length of its placeholder: the %Player macro writes the length word, so a different length would move the data after it.
// The copy is two folders deeper than the source, so its relative incbin paths get one more "../".
function buildTeamData() {
    begin('names');
    const srcPath = path.join(ROOT, 'src', 'data', 'teamdata93s.asm');
    const namesPath = path.join(ROOT, 'Extracted', 'Text', 'PlayerNames.txt');
    if (!fs.existsSync(namesPath)) fail('names', `${rel(namesPath)} is missing, run node tools/prebuild.js`);
    const names = fs.readFileSync(namesPath, 'latin1').split('\n');
    if (names[names.length - 1] === '') names.pop();
    let i = 0;
    let out = fs.readFileSync(srcPath, 'latin1').replace(/^([ \t]*%Player\(")([^"]*)(")([^\r\n]*)/gm, (m, a, placeholder, z, rest) => {
        const name = names[i++];
        if (name === undefined) fail('names', `${rel(srcPath)} has more %Player rows than ${rel(namesPath)} has names (${names.length})`);
        if (name.length !== placeholder.length) fail('names', `Player row ${i}: the name '${name}' has ${name.length} characters, its placeholder '${placeholder}' has ${placeholder.length}`);
        return a + name + z + idNote(rest, placeholder);
    });
    if (i !== names.length) fail('names', `${rel(namesPath)} has ${names.length} names, ${rel(srcPath)} has ${i} %Player rows`);
    out = out.replace(/incbin "\.\.\/\.\.\//g, 'incbin "../../../');
    const dest = path.join(OBJ, 'teamdata93s.asm');
    fs.writeFileSync(dest, out, 'latin1');
    step('names', `${i} player names -> ${rel(dest)}`);
}

(async () => {
    if (args.includes('--clean')) {
        steps = 2;
        const walk = (d) => fs.readdirSync(d, { withFileTypes: true }).reduce((a, e) => {
            const f = path.join(d, e.name);
            if (e.isDirectory()) { const r = walk(f); return [a[0] + r[0], a[1] + r[1]]; }
            return [a[0] + 1, a[1] + fs.statSync(f).size];
        }, [0, 0]);
        for (const dir of ['output', 'Extracted']) {
            begin(dir);
            const full = path.join(ROOT, dir);
            if (!fs.existsSync(full)) { step(dir, 'already clean'); continue; }
            const [files, bytes] = walk(full);
            try { fs.rmSync(full, { recursive: true, force: true }); } catch (e) { fail(dir, e.message); }
            step(dir, `removed ${files} files, ${(bytes / 1048576).toFixed(1)} MB`);
        }
        console.log(c.green('CLEAN'));
        return;
    }
    steps = 5;
    fs.mkdirSync(OBJ, { recursive: true });

    // 1. prebuild: ROM check (path, SHA-1, size) and Extracted/ assets.
    {
        begin('prebuild');
        const r = await node('prebuild.js', []);
        if (r.status !== 0) fail('prebuild', 'ROM or asset extraction', r.out);
        let count = '?';
        try { count = JSON.parse(fs.readFileSync(path.join(ROOT, 'Extracted', '.extract-complete.json'), 'utf8')).files.length; } catch (e) { /* keep ? */ }
        step('prebuild', `ROM OK, ${count} assets extracted`);
        detail(r.out);
    }

    // 2. names: the team data with the real player names, which b83_teams.asm includes.
    buildTeamData();

    // 3. assemble: the ROM.
    begin('assemble');
    const a = await assemble('assemble');
    step('assemble', `${a.version}, ${a.warnings} warnings -> ${rel(a.bin)}`);

    // The 93S sound CPU driver (src/data/sound/spcdriver.asm) must equal the extracted Extracted/Sound/driver.spc700.
    {
        const want = fs.readFileSync(path.join(ROOT, 'Extracted', 'Sound', 'driver.spc700'));
        const got = fs.readFileSync(a.bin).subarray(0x30004, 0x30004 + want.length);
        if (!got.equals(want)) fail('assemble', 'spcdriver.asm does not match Extracted/Sound/driver.spc700', '', 'MISMATCH');
        detail(`spcdriver.asm MATCH Extracted/Sound/driver.spc700 (${want.length} bytes)`);
    }

    // 4. header: pad and checksum a grown image; the result is output/retail/nhlpa93snes.sfc.
    begin('header');
    const h = await node('patchHeader.js', [a.bin]);
    if (h.status !== 0) fail('header', 'patchHeader.js failed', h.out);
    const final = path.join(OUT, ROM);
    fs.renameSync(a.bin, final);
    step('header', h.out.trim() ? h.out.trim().replace(/^header \S+: /, '') : `image unchanged (stock size and checksum) -> ${rel(final)}`);

    // 5. verify against the reference ROM.
    begin('verify');
    const refPath = findRom(ROMS.retail).path;
    const r = await node('verifyRom.js', [final, refPath]);
    const first = r.out.split(/\r?\n/).find((l) => l.trim()) || '';
    if (r.status !== 0 || !/^MATCH/.test(first)) fail('verify', rel(final), r.out, 'MISMATCH');
    step('verify', `MATCH ${rel(final)} == ${rel(refPath)}`);
    detail(r.out);
})();
