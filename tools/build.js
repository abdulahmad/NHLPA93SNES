#!/usr/bin/env node
// build.js: the whole NHLPA 93 (SNES) build, one line per step, on Windows, Linux and macOS (same tool as
// NHLPA93Genesis tools/build.js).
//   node tools/build.js [retail] [--verbose]   full ROM -> output/retail/nhlpa93snes.sfc
//   node tools/build.js --clean                delete output/ and Extracted/
// --no-color (or NO_COLOR) turns the colors off; they are also off when the output is not a terminal.
// retail: assembled with asar 1.91 (tools/bin/asar from tools/setup.sh, else asar on PATH), the header patched if the image
// grew (tools/patchHeader.js; the stock image is left as it is), verified against nhlpa93retail.sfc.
// The mode has its own folder: output/retail/nhlpa93snes.sfc is the ROM, output/retail/obj/ holds the intermediates
// (asar's log and its symbol file).
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const ROOT = path.join(__dirname, '..');
const WIN = process.platform === 'win32';
const BIN = path.join(ROOT, 'tools', 'bin', WIN ? 'asar.exe' : 'asar');
const MODES = {
    retail: { ref: 'nhlpa93retail.sfc' },
};

const args = process.argv.slice(2);
const verbose = args.includes('--verbose');
const modeName = args.find((a) => MODES[a]) || 'retail';
const mode = MODES[modeName];
const OUT = path.join(ROOT, 'output', modeName);
const OBJ = path.join(OUT, 'obj');
const ROM = 'nhlpa93snes.sfc';
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
    prebuild: 'check the retail ROM and extract graphics/sound/text assets into Extracted/',
    assemble: 'asar turns src/nhlpa93snes.asm into the ROM image',
    header: 'pad the image and store the checksum if the ROM grew (the stock image is left as it is)',
    verify: 'compare byte-for-byte with the retail ROM (nhlpa93retail.sfc)',
    output: 'delete the built ROMs and intermediates in output/',
    Extracted: 'delete extracted graphics/sound assets (rebuilt by the next build)',
};
const live = color;
// Braille spinner and check marks need a UTF-8 terminal; old Windows consoles get ASCII.
const utf8 = WIN ? Boolean(process.env.WT_SESSION || process.env.TERM_PROGRAM || process.env.ConEmuANSI)
    : /utf-?8/i.test(process.env.LC_ALL || process.env.LC_CTYPE || process.env.LANG || '');
const SPIN = utf8 ? ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'] : ['|', '/', '-', '\\'];
const OK = utf8 ? '✓' : 'OK';
const BAD = utf8 ? '✗' : 'X';
const MARK = Math.max(OK.length, BAD.length, 1);
const INDENT = ' '.repeat(`[0/0] ${live ? ' '.repeat(MARK + 1) : ''}${''.padEnd(10)} `.length);
let current = null;
let dirty = false;
let timer = null;
let frame = 0;
function header(name, paintName, mark) {
    const head = `[${n}/${steps}] ${live ? `${mark.padEnd(MARK)} ` : ''}${name.padEnd(10)} `;
    let desc = ABOUT[name] || '';
    const width = live ? (process.stdout.columns || 80) - 1 : Infinity;
    if (head.length + desc.length > width) desc = desc.slice(0, Math.max(0, width - head.length - 1)) + (width > head.length ? '…'.slice(0, utf8 ? 1 : 0) : '');
    const markPart = live ? `${paintName(mark.padEnd(MARK))} ` : '';
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
const step = (name, text) => { finish(name, c.green, OK); console.log(INDENT + paint(text)); };
function detail(text) {
    if (!verbose || !text.trim()) return;
    if (live && current && !dirty) { stopSpin(); process.stdout.write('\n'); }
    dirty = true;
    console.log(text.replace(/\s+$/, '').replace(/^/gm, INDENT));
}
function fail(name, text, log, label = 'FAILED') {
    finish(name, c.red, BAD);
    console.log(`${INDENT}${c.red(label)}: ${text}`);
    if (log) console.log(log.replace(/\s+$/, '').replace(/^/gm, INDENT));
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
const node = (script, argv) => run(process.execPath, [path.join(__dirname, script), ...argv]);

// asar 1.91 with the options the stock build matches: no checksum fix (patchHeader.js stores it), a WLA symbol file.
async function assemble(name) {
    const base = path.join(OBJ, 'nhlpa93snes');
    const out = path.join(OBJ, ROM);
    fs.rmSync(out, { force: true });
    const argv = ['--fix-checksum=off', '--symbols=wla', `--symbols-path=${base}.sym`, 'src/nhlpa93snes.asm', out];
    let r = fs.existsSync(BIN) ? await run(BIN, argv) : await run('asar', argv);
    if (r.status === -1 && !fs.existsSync(BIN)) fail(name, 'asar 1.91 not found: run `sh tools/setup.sh` (Linux/macOS) or `tools\\setup.ps1` (Windows), or put asar on PATH', r.out);
    const logPath = `${base}.log`;
    fs.writeFileSync(logPath, r.out, 'latin1');
    if (r.status !== 0 || !fs.existsSync(out)) fail(name, `assembly failed, see ${rel(logPath)}`, r.out.split(/\r?\n/).filter((l) => l.trim()).slice(0, 40).join('\n'));
    detail(r.out);
    const warnings = (r.out.match(/warning/gi) || []).length;
    return { bin: out, warnings, version: ((await run(fs.existsSync(BIN) ? BIN : 'asar', ['--version'])).out.split(/\r?\n/)[0] || 'asar').replace(/,.*/, '') };
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
    steps = 4;
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

    // 2. assemble: the ROM.
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

    // 3. header: pad and checksum a grown image; the result is output/retail/nhlpa93snes.sfc.
    begin('header');
    const h = await node('patchHeader.js', [a.bin]);
    if (h.status !== 0) fail('header', 'patchHeader.js failed', h.out);
    const final = path.join(OUT, ROM);
    fs.renameSync(a.bin, final);
    step('header', h.out.trim() ? h.out.trim().replace(/^header \S+: /, '') : `image unchanged (stock size and checksum) -> ${rel(final)}`);

    // 4. verify against the reference ROM.
    begin('verify');
    const r = await node('verifyRom.js', [final, mode.ref]);
    const first = r.out.split(/\r?\n/).find((l) => l.trim()) || '';
    if (r.status !== 0 || !/^MATCH/.test(first)) fail('verify', rel(final), r.out, 'MISMATCH');
    step('verify', `MATCH ${rel(final)} == ${mode.ref}`);
    detail(r.out);
})();
