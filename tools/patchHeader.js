#!/usr/bin/env node
// patchHeader.js: pad an SNES LoROM image and store its checksum.
//
// The stock 512 KB image already carries size $09 and checksum $48A5 / complement $B75A, so this writes nothing and the
// file is left byte for byte.
//
// A larger image is padded with $00 up to the next SNES size, the size byte is set ($0A = 1MB, $0B = 2MB, $0C = 4MB;
// $09 stays 512 KB), and the checksum and its complement are stored little-endian at the header. The checksum is the
// low 16 bits of the sum of every byte, including that pair. A complement pair always adds $01FE. Cartridge type and
// SRAM size are left alone. The finished file is checked: its byte sum must equal the checksum word stored in the header.
// Usage: node tools/patchHeader.js <image.sfc>
const fs = require('fs');

// file offset of the LoROM header ($80FFC0)
const HEADER = 0x7FC0;
const ROM_SIZE = HEADER + 0x17;
const CHECKSUM_COMPLEMENT = HEADER + 0x1C;
const CHECKSUM = HEADER + 0x1E;
// [byte length, header size byte]. $09 is the retail 512 KB image.
const SIZES = [[512 * 1024, 0x09], [1024 * 1024, 0x0A], [2 * 1024 * 1024, 0x0B], [4 * 1024 * 1024, 0x0C]];
const sum = (b) => b.reduce((a, v) => a + v, 0);

// Returns the patched image; `data` is not modified.
function patch(data) {
    const fit = SIZES.find(([length]) => data.length <= length);
    if (!fit) throw new Error('ROM is larger than 4MB; no SNES size byte fits');
    const out = Buffer.alloc(fit[0]);
    data.copy(out);
    out[ROM_SIZE] = fit[1];
    // The complement pair sums to $01FE, so the checksum is the sum of every other byte, plus that constant, in 16 bits.
    out.fill(0, CHECKSUM_COMPLEMENT, CHECKSUM + 2);
    const checksum = (sum(out) + 0x01FE) & 0xFFFF;
    const complement = checksum ^ 0xFFFF;
    out.writeUInt16LE(complement, CHECKSUM_COMPLEMENT);
    out.writeUInt16LE(checksum, CHECKSUM);
    const pair = sum(out.subarray(CHECKSUM_COMPLEMENT, CHECKSUM + 2));
    const total = sum(out) & 0xFFFF;
    if (pair !== 0x01FE || total !== checksum) {
        throw new Error(`checksum check failed: stored $${checksum.toString(16).toUpperCase()}, file sums to $${total.toString(16).toUpperCase()}`);
    }
    return out;
}

module.exports = { patch };

if (require.main === module) {
    const file = process.argv[2];
    if (!file) { console.error('usage: node tools/patchHeader.js <image.sfc>'); process.exit(1); }
    try {
        const original = fs.readFileSync(file);
        const patched = patch(original);
        if (!patched.equals(original)) {
            fs.writeFileSync(file, patched);
            const hex = (n) => '$' + n.toString(16).toUpperCase().padStart(4, '0');
            console.log(`header ${file}: ${original.length} -> ${patched.length} bytes, size $${patched[ROM_SIZE].toString(16).toUpperCase().padStart(2, '0')}, ` +
                `checksum ${hex(patched.readUInt16LE(CHECKSUM))}, complement ${hex(patched.readUInt16LE(CHECKSUM_COMPLEMENT))}`);
        }
    } catch (e) { console.error(e.message); process.exit(1); }
}
