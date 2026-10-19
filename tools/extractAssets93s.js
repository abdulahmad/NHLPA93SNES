#!/usr/bin/env node
// extractAssets93s.js: NHLPA 93 (SNES) asset extractor. Writes the ROM ranges that the source incbins (team palettes in
// teamdata93s.asm, packed graphics and maps, sprite sets, text and sound blocks in the bank files) into Extracted/<Graphics|Sound|Text>/
// (the folders of the NHLPA 93 Genesis project). Extracted/ is not committed. tools/prebuild.js runs this when Extracted/
// is missing or stale; this script writes Extracted/.extract-complete.json last. src/data/README.md describes the formats.
// Usage: node tools/extractAssets93s.js nhlpa93retail.sfc           (write every asset and the marker)
//        node tools/extractAssets93s.js nhlpa93retail.sfc --check   (compare Extracted/ with the ROM, exit 1 on a difference)
// Each entry: file name below Extracted/, first ROM address, end address (exclusive), as SNES LoROM/FastROM addresses
// ($80:8000 is the start of the file). An entry with `pieces` is one file made of several ranges in ROM order.
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const ROOT = path.join(__dirname, '..');
const EXTRACTED = path.join(ROOT, 'Extracted');
const MARKER = path.join(EXTRACTED, '.extract-complete.json');
const ROM_SHA1 = '76a01492cfb656e9fce0094bca356c312adfea0e';
const assets = [
    { file: 'Graphics/RonBarr.map.snesjim', start: 0x80ED38, end: 0x80F36E },
    { file: 'Sound/gamesamples.brr', start: 0x818054, end: 0x82B868 },
    { file: 'Graphics/IceRink.chr.pak', start: 0x82CDA0, end: 0x82F93C },
    { file: 'Graphics/Pals/ASEh.pal', start: 0x838074, end: 0x838094 },
    { file: 'Graphics/Pals/ASEv.pal', start: 0x838094, end: 0x8380B4 },
    { file: 'Graphics/Pals/ASWh.pal', start: 0x838302, end: 0x838322 },
    { file: 'Graphics/Pals/ASWv.pal', start: 0x838322, end: 0x838342 },
    { file: 'Graphics/Pals/BOSh.pal', start: 0x838597, end: 0x8385B7 },
    { file: 'Graphics/Pals/BOSv.pal', start: 0x8385B7, end: 0x8385D7 },
    { file: 'Graphics/Pals/BUFh.pal', start: 0x83883F, end: 0x83885F },
    { file: 'Graphics/Pals/BUFv.pal', start: 0x83885F, end: 0x83887F },
    { file: 'Graphics/Pals/CGYh.pal', start: 0x838AF2, end: 0x838B12 },
    { file: 'Graphics/Pals/CGYv.pal', start: 0x838B12, end: 0x838B32 },
    { file: 'Graphics/Pals/CHIh.pal', start: 0x838D8F, end: 0x838DAF },
    { file: 'Graphics/Pals/CHIv.pal', start: 0x838DAF, end: 0x838DCF },
    { file: 'Graphics/Pals/DETh.pal', start: 0x83903E, end: 0x83905E },
    { file: 'Graphics/Pals/DETv.pal', start: 0x83905E, end: 0x83907E },
    { file: 'Graphics/Pals/EDMh.pal', start: 0x8392E9, end: 0x839309 },
    { file: 'Graphics/Pals/EDMv.pal', start: 0x839309, end: 0x839329 },
    { file: 'Graphics/Pals/HFDh.pal', start: 0x83958A, end: 0x8395AA },
    { file: 'Graphics/Pals/HFDv.pal', start: 0x8395AA, end: 0x8395CA },
    { file: 'Graphics/Pals/LAh.pal', start: 0x83982F, end: 0x83984F },
    { file: 'Graphics/Pals/LAv.pal', start: 0x83984F, end: 0x83986F },
    { file: 'Graphics/Pals/LIh.pal', start: 0x839AEB, end: 0x839B0B },
    { file: 'Graphics/Pals/LIv.pal', start: 0x839B0B, end: 0x839B2B },
    { file: 'Graphics/Pals/MINh.pal', start: 0x839D89, end: 0x839DA9 },
    { file: 'Graphics/Pals/MINv.pal', start: 0x839DA9, end: 0x839DC9 },
    { file: 'Graphics/Pals/MTLh.pal', start: 0x83A01A, end: 0x83A03A },
    { file: 'Graphics/Pals/MTLv.pal', start: 0x83A03A, end: 0x83A05A },
    { file: 'Graphics/Pals/NJh.pal', start: 0x83A2E4, end: 0x83A304 },
    { file: 'Graphics/Pals/NJv.pal', start: 0x83A304, end: 0x83A324 },
    { file: 'Graphics/Pals/NYh.pal', start: 0x83A58F, end: 0x83A5AF },
    { file: 'Graphics/Pals/NYv.pal', start: 0x83A5AF, end: 0x83A5CF },
    { file: 'Graphics/Pals/OTWh.pal', start: 0x83A84B, end: 0x83A86B },
    { file: 'Graphics/Pals/OTWv.pal', start: 0x83A86B, end: 0x83A88B },
    { file: 'Graphics/Pals/PHIh.pal', start: 0x83AA5E, end: 0x83AA7E },
    { file: 'Graphics/Pals/PHIv.pal', start: 0x83AA7E, end: 0x83AA9E },
    { file: 'Graphics/Pals/PITh.pal', start: 0x83AD0E, end: 0x83AD2E },
    { file: 'Graphics/Pals/PITv.pal', start: 0x83AD2E, end: 0x83AD4E },
    { file: 'Graphics/Pals/QUEh.pal', start: 0x83AFA9, end: 0x83AFC9 },
    { file: 'Graphics/Pals/QUEv.pal', start: 0x83AFC9, end: 0x83AFE9 },
    { file: 'Graphics/Pals/SJh.pal', start: 0x83B276, end: 0x83B296 },
    { file: 'Graphics/Pals/SJv.pal', start: 0x83B296, end: 0x83B2B6 },
    { file: 'Graphics/Pals/STLh.pal', start: 0x83B522, end: 0x83B542 },
    { file: 'Graphics/Pals/STLv.pal', start: 0x83B542, end: 0x83B562 },
    { file: 'Graphics/Pals/TBYh.pal', start: 0x83B7CF, end: 0x83B7EF },
    { file: 'Graphics/Pals/TBYv.pal', start: 0x83B7EF, end: 0x83B80F },
    { file: 'Graphics/Pals/TORh.pal', start: 0x83BA06, end: 0x83BA26 },
    { file: 'Graphics/Pals/TORv.pal', start: 0x83BA26, end: 0x83BA46 },
    { file: 'Graphics/Pals/VANh.pal', start: 0x83BCB4, end: 0x83BCD4 },
    { file: 'Graphics/Pals/VANv.pal', start: 0x83BCD4, end: 0x83BCF4 },
    { file: 'Graphics/Pals/WPGh.pal', start: 0x83BF5B, end: 0x83BF7B },
    { file: 'Graphics/Pals/WPGv.pal', start: 0x83BF7B, end: 0x83BF9B },
    { file: 'Graphics/Pals/WSHh.pal', start: 0x83C210, end: 0x83C230 },
    { file: 'Graphics/Pals/WSHv.pal', start: 0x83C230, end: 0x83C250 },
    { file: 'Graphics/SmallFont.chr.pak', start: 0x83C6D8, end: 0x83CC0C },
    { file: 'Graphics/IceRink.snesmap', start: 0x83CCCB, end: 0x83ECAB },
    { file: 'Graphics/IceRinkHor.snesmap', start: 0x83ECAB, end: 0x83F72B },
    { file: 'Graphics/Pals/Rink.snespal', start: 0x83F72B, end: 0x83F82B },
    { file: 'Graphics/Refs.snesmap', start: 0x83FAEC, end: 0x83FDFC },
    { file: 'Graphics/Sprites/set09.pieces', start: 0x84807C, end: 0x848630 },
    { file: 'Graphics/Sprites/set09.chr', start: 0x848630, end: 0x84D630 },
    { file: 'Text/ScoutingReportText.bin', start: 0x84D630, end: 0x84E949 },
    { file: 'Graphics/FaceOff.snesmap', start: 0x84E949, end: 0x84EA39 },
    { file: 'Graphics/HotList.bin', start: 0x84EF3C, end: 0x84F386 },
    { file: 'Graphics/RinkLogoTiles.chr.pak', start: 0x84F386, end: 0x84F532 },
    { file: 'Graphics/PlayoffTiles.chr.pak', start: 0x84F79D, end: 0x84F816 },
    { file: 'Graphics/Sprites/set04.pieces', start: 0x85806C, end: 0x8585A4 },
    { file: 'Graphics/Sprites/set04.chr', start: 0x8585A4, end: 0x85D5A4 },
    { file: 'Graphics/Title1.map.snesjim', start: 0x85D5C0, end: 0x85FBB9 },
    { file: 'Sound/driver.spc700', start: 0x868004, end: 0x868AA9 },
    { file: 'Sound/fmtune_playoff_cmdstream.bin', pieces: [[0x868AA9, 0x868AB1], [0x868AF1, 0x868B01], [0x868B81, 0x868C25], [0x869D79, 0x86A0A6]] },
    { file: 'Sound/fmtune_title_cmdstream.bin', pieces: [[0x868AB1, 0x868AB9], [0x868B01, 0x868B11], [0x868E83, 0x868FE5], [0x8692B6, 0x8692C0], [0x86984A, 0x869D79]] },
    { file: 'Sound/fmtune_unused2_cmdstream.bin', pieces: [[0x868AB9, 0x868AC1], [0x868B11, 0x868B21], [0x868C25, 0x868CFB], [0x8692C0, 0x8692C6], [0x86A0A6, 0x86A4BF]] },
    { file: 'Sound/fmtune_goal_cmdstream.bin', pieces: [[0x868AC1, 0x868AC9], [0x868B21, 0x868B31], [0x868FE5, 0x869051], [0x86952B, 0x869542], [0x8697C2, 0x86984A]] },
    { file: 'Sound/fmtune_periodstart_cmdstream.bin', pieces: [[0x868AC9, 0x868AD1], [0x868B31, 0x868B41], [0x8690B7, 0x86913B], [0x86964A, 0x86969B]] },
    { file: 'Sound/fmtune_lategame_cmdstream.bin', pieces: [[0x868AD1, 0x868AD9], [0x868B41, 0x868B51], [0x869051, 0x8690B7], [0x86969B, 0x8697C2]] },
    { file: 'Sound/fmtune_unused7_cmdstream.bin', pieces: [[0x868AD9, 0x868AE1], [0x868B51, 0x868B61], [0x86913B, 0x869228], [0x86961D, 0x86964A]] },
    { file: 'Sound/fmtune_midperiod_cmdstream.bin', pieces: [[0x868AE1, 0x868AE9], [0x868B61, 0x868B71], [0x869228, 0x8692B6], [0x869542, 0x86961D]] },
    { file: 'Sound/fmtune_unused9_cmdstream.bin', pieces: [[0x868AE9, 0x868AF1], [0x868B71, 0x868B81], [0x868CFB, 0x868E83], [0x8692C6, 0x86952B]] },
    { file: 'Sound/sfx_table.bin', start: 0x86A4BF, end: 0x86A528 },
    { file: 'Sound/sfx_a1_cmdstream.bin', start: 0x86A528, end: 0x86A534 },
    { file: 'Sound/sfx_siren_cmdstream.bin', start: 0x86A534, end: 0x86A548 },
    { file: 'Sound/sfx_crowd0_cmdstream.bin', start: 0x86A548, end: 0x86A554 },
    { file: 'Sound/sfx_crowd1_cmdstream.bin', start: 0x86A554, end: 0x86A560 },
    { file: 'Sound/sfx_crowd2_cmdstream.bin', start: 0x86A560, end: 0x86A56C },
    { file: 'Sound/sfx_crowd3_cmdstream.bin', start: 0x86A56C, end: 0x86A578 },
    { file: 'Sound/sfx_crowd4_cmdstream.bin', start: 0x86A578, end: 0x86A584 },
    { file: 'Sound/sfx_crowd5_cmdstream.bin', start: 0x86A584, end: 0x86A590 },
    { file: 'Sound/sfx_crowd6_cmdstream.bin', start: 0x86A590, end: 0x86A59C },
    { file: 'Sound/sfx_crowd7_cmdstream.bin', start: 0x86A59C, end: 0x86A5A8 },
    { file: 'Sound/sfx_crowdoff_cmdstream.bin', start: 0x86A5A8, end: 0x86A5B4 },
    { file: 'Sound/sfx_check1_cmdstream.bin', start: 0x86A5B4, end: 0x86A5C0 },
    { file: 'Sound/sfx_check2_cmdstream.bin', start: 0x86A5C0, end: 0x86A5CC },
    { file: 'Sound/sfx_playerwall_cmdstream.bin', start: 0x86A5CC, end: 0x86A5D8 },
    { file: 'Sound/sfx_playerwall2_cmdstream.bin', start: 0x86A5D8, end: 0x86A5E4 },
    { file: 'Sound/sfx_shothard_cmdstream.bin', start: 0x86A5E4, end: 0x86A5FB },
    { file: 'Sound/sfx_puckwall1_cmdstream.bin', start: 0x86A5FB, end: 0x86A607 },
    { file: 'Sound/sfx_puckwall2_cmdstream.bin', start: 0x86A607, end: 0x86A613 },
    { file: 'Sound/sfx_puckwall3_cmdstream.bin', start: 0x86A613, end: 0x86A61F },
    { file: 'Sound/sfx_hithigh_cmdstream.bin', start: 0x86A61F, end: 0x86A62B },
    { file: 'Sound/sfx_hitlow_cmdstream.bin', start: 0x86A62B, end: 0x86A637 },
    { file: 'Sound/sfx_shotfh_cmdstream.bin', start: 0x86A637, end: 0x86A643 },
    { file: 'Sound/sfx_shotbh_cmdstream.bin', start: 0x86A643, end: 0x86A64F },
    { file: 'Sound/sfx_puckpost_cmdstream.bin', start: 0x86A64F, end: 0x86A65B },
    { file: 'Sound/sfx_stop1_cmdstream.bin', start: 0x86A65B, end: 0x86A667 },
    { file: 'Sound/sfx_stop2_cmdstream.bin', start: 0x86A667, end: 0x86A673 },
    { file: 'Sound/sfx_shotwiff2_cmdstream.bin', start: 0x86A673, end: 0x86A67F },
    { file: 'Sound/sfx_shotwiff1_cmdstream.bin', start: 0x86A67F, end: 0x86A68B },
    { file: 'Sound/sfx_shotwiff4_cmdstream.bin', start: 0x86A68B, end: 0x86A697 },
    { file: 'Sound/sfx_shotwiff3_cmdstream.bin', start: 0x86A697, end: 0x86A6A3 },
    { file: 'Sound/sfx_crowdboo_cmdstream.bin', start: 0x86A6A3, end: 0x86A6AF },
    { file: 'Sound/sfx_oooh2_cmdstream.bin', start: 0x86A6AF, end: 0x86A6BB },
    { file: 'Sound/sfx_crowdcheer_cmdstream.bin', start: 0x86A6BB, end: 0x86A6C7 },
    { file: 'Sound/sfx_whistle_cmdstream.bin', start: 0x86A6C7, end: 0x86A6EB },
    { file: 'Sound/bootsamples.brr', start: 0x86A7C9, end: 0x86FA3A },
    { file: 'Graphics/Sprites/set02.pieces', start: 0x87805C, end: 0x8783A0 },
    { file: 'Graphics/Sprites/set02.chr', start: 0x8783A0, end: 0x87C3A0 },
    { file: 'Graphics/EASN.map.snesjim', start: 0x87C3A0, end: 0x87C6B4 },
    { file: 'Graphics/FaceOff.chr.pak', start: 0x87C6B4, end: 0x87CABA },
    { file: 'Graphics/TeamBlocks.snesmap', start: 0x87CABA, end: 0x87CE62 },
    { file: 'Graphics/Sprites/set06.pieces', start: 0x87D231, end: 0x87D3E9 },
    { file: 'Graphics/Sprites/set06.chr', start: 0x87D3E9, end: 0x87F3E9 },
    { file: 'Graphics/Ref.chr.pak', start: 0x87F55E, end: 0x87FF78 },
    { file: 'Graphics/GameSetUp.map.snesjim', start: 0x888000, end: 0x88822F },
    { file: 'Graphics/SmallFont.snesmap', start: 0x88822F, end: 0x88832F },
    { file: 'Graphics/Framer.snesmap', start: 0x88871C, end: 0x88872E },
    { file: 'Graphics/Framer.chr', start: 0x88872E, end: 0x8887AE },
    { file: 'Graphics/Sprites/set08.pieces', start: 0x888A47, end: 0x888B73 },
    { file: 'Graphics/Sprites/set08.chr', start: 0x888B73, end: 0x889B73 },
    { file: 'Graphics/TeamBlocks.chr.pak', start: 0x889B73, end: 0x88BC56 },
    { file: 'Graphics/Sprites/set07.pieces', start: 0x88BCA0, end: 0x88BF9C },
    { file: 'Graphics/Sprites/set07.chr', start: 0x88BF9C, end: 0x88EF9C },
    { file: 'Graphics/Sprites/set11.pieces', start: 0x898028, end: 0x8980F0 },
    { file: 'Graphics/Sprites/set11.chr', start: 0x8980F0, end: 0x8990F0 },
    { file: 'Graphics/Sprites/set13.pieces', start: 0x8993F9, end: 0x89995D },
    { file: 'Graphics/Sprites/set13.chr', start: 0x89995D, end: 0x89E95D },
    { file: 'Graphics/RefHor.chr.pak', start: 0x89EB45, end: 0x89F3FB },
    { file: 'Graphics/RefsHor.snesmap', start: 0x89F3FB, end: 0x89FB6B },
    { file: 'Graphics/Sprites/set12.pieces', start: 0x8A80A0, end: 0x8A8880 },
    { file: 'Graphics/Sprites/set12.chr', start: 0x8A8880, end: 0x8AF880 },
    { file: 'Graphics/Arrows.snesmap', start: 0x8AF880, end: 0x8AFAA8 },
    { file: 'Graphics/Sprites/set05.pieces', start: 0x8B847A, end: 0x8B8CCE },
    { file: 'Graphics/Sprites/set05.chr', start: 0x8B8CCE, end: 0x8BFCCE },
    { file: 'Graphics/NHLPALogo.map.snesjim', start: 0x8C8000, end: 0x8C845A },
    { file: 'Graphics/Sprites/set00.pieces', start: 0x8C8526, end: 0x8C8C1A },
    { file: 'Graphics/Sprites/set00.chr', start: 0x8C8C1A, end: 0x8CFC1A },
    { file: 'Graphics/Sprites/set10.pieces', start: 0x8D88B8, end: 0x8D8EC8 },
    { file: 'Graphics/Sprites/set10.chr', start: 0x8D8EC8, end: 0x8DEEC8 },
    { file: 'Graphics/BigFont.chr.pak', start: 0x8DEEC8, end: 0x8DF888 },
    { file: 'Graphics/Sprites/set03.pieces', start: 0x8E8447, end: 0x8E89A7 },
    { file: 'Graphics/Sprites/set03.chr', start: 0x8E89A7, end: 0x8ED9A7 },
    { file: 'Graphics/Sprites/set14.pieces', start: 0x8EDA2F, end: 0x8EEB93 },
    { file: 'Graphics/Sprites/set14.chr', start: 0x8EEB93, end: 0x8EFE73 },
    { file: 'Graphics/BigFont.snesmap', start: 0x8F8000, end: 0x8F8130 },
    { file: 'Graphics/EASN.snesmap', start: 0x8F824D, end: 0x8F8269 },
    { file: 'Graphics/Sprites/set01.pieces', start: 0x8F90F1, end: 0x8F94F9 },
    { file: 'Graphics/Sprites/set01.chr', start: 0x8F94F9, end: 0x8FD4F9 },
];

const romOffset = (a) => ((a >> 16) & 0x7F) * 0x8000 + (a & 0x7FFF);
const sha1Of = (buf) => crypto.createHash('sha1').update(buf).digest('hex');
const rangesOf = (a) => a.pieces || [[a.start, a.end]];
const slice = (rom, a) => Buffer.concat(rangesOf(a).map(([s, e]) => rom.subarray(romOffset(s), romOffset(e))));

const args = process.argv.slice(2);
const romFile = args.find((a) => !a.startsWith('-'));
const check = args.includes('--check');
if (!romFile) {
    console.error('Usage: node tools/extractAssets93s.js <rom_file_path> [--check]');
    process.exit(1);
}
const rom = fs.readFileSync(romFile);
const romSha1 = sha1Of(rom);
if (romSha1 !== ROM_SHA1) {
    console.error(`Unknown ROM: SHA-1 ${romSha1}, ${rom.length} bytes. Expected ${ROM_SHA1} (nhlpa93retail.sfc).`);
    process.exit(1);
}
console.log('ROM: NHLPA Hockey \'93 SNES retail (USA)');

let bad = 0;
const written = [];
for (const a of assets) {
    const out = path.join(EXTRACTED, a.file);
    const data = slice(rom, a);
    if (check) {
        if (!fs.existsSync(out) || !fs.readFileSync(out).equals(data)) { console.log(`differs: Extracted/${a.file}`); bad++; }
    } else {
        fs.mkdirSync(path.dirname(out), { recursive: true });
        fs.writeFileSync(out, data);
        written.push({ path: a.file, size: data.length });
    }
}
// Files in Extracted/ that are not assets: reported by --check, deleted by an extraction.
const names = new Set(assets.map((a) => a.file));
const walk = (d) => (fs.existsSync(d) ? fs.readdirSync(d, { withFileTypes: true }) : []).flatMap((e) => (e.isDirectory() ? walk(path.join(d, e.name)) : [path.join(d, e.name)]));
for (const f of walk(EXTRACTED)) {
    const rel = path.relative(EXTRACTED, f).split(path.sep).join('/');
    if (rel === '.extract-complete.json' || names.has(rel)) continue;
    if (check) console.log(`not an asset: Extracted/${rel}`);
    else { fs.rmSync(f); console.log(`deleted (not an asset): Extracted/${rel}`); }
}
if (check) {
    console.log(`${assets.length - bad} of ${assets.length} assets match the ROM`);
    process.exit(bad ? 1 : 0);
}
fs.writeFileSync(MARKER, JSON.stringify({ rom: 'retail', romSha1, extractor: path.basename(__filename),
    extractorSha1: sha1Of(fs.readFileSync(__filename)), files: written }, null, 1) + '\n');
console.log(`Extracted ${assets.length} assets from NHLPA 93 SNES ROM.`);
