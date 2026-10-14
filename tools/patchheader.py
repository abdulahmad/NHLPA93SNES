#!/usr/bin/env python3
"""Pad an SNES LoROM image and store its checksum.

The stock 512 KB image already carries size $09 and checksum $48A5 / complement
$B75A, so this writes nothing and the file is left byte for byte.

A larger image is padded with $00 up to the next SNES size, the size byte is
set ($0A = 1MB, $0B = 2MB, $0C = 4MB; $09 stays 512 KB), and the checksum and
its complement are stored little-endian at the header. The checksum is the low
16 bits of the sum of every byte, including that pair. A complement pair always
adds $01FE. Cartridge type and SRAM size are left alone.

The finished file is checked: its byte sum must equal the checksum word stored
in the header.
"""
import sys

# file offset of the LoROM header ($80FFC0)
HEADER = 0x7FC0
ROM_SIZE = HEADER + 0x17
CHECKSUM_COMPLEMENT = HEADER + 0x1C
CHECKSUM = HEADER + 0x1E

# (byte length, header size byte). $09 is the retail 512 KB image.
SIZES = (
    (512 * 1024, 0x09),
    (1024 * 1024, 0x0A),
    (2 * 1024 * 1024, 0x0B),
    (4 * 1024 * 1024, 0x0C),
)


def patch(data):
    """Return the patched image. `data` is not modified."""
    for length, size_byte in SIZES:
        if len(data) <= length:
            target, size = length, size_byte
            break
    else:
        raise SystemExit('ROM is larger than 4MB; no SNES size byte fits')
    out = bytearray(data)
    if len(out) < target:
        out.extend(b'\x00' * (target - len(out)))
    out[ROM_SIZE] = size
    # The complement pair sums to $01FE, so the checksum is the sum of every
    # other byte, plus that constant, in 16 bits.
    out[CHECKSUM_COMPLEMENT:CHECKSUM + 2] = b'\x00\x00\x00\x00'
    checksum = (sum(out) + 0x01FE) & 0xFFFF
    complement = checksum ^ 0xFFFF
    out[CHECKSUM_COMPLEMENT] = complement & 0xFF
    out[CHECKSUM_COMPLEMENT + 1] = (complement >> 8) & 0xFF
    out[CHECKSUM] = checksum & 0xFF
    out[CHECKSUM + 1] = (checksum >> 8) & 0xFF
    pair = sum(out[CHECKSUM_COMPLEMENT:CHECKSUM + 2])
    total = sum(out) & 0xFFFF
    if pair != 0x01FE or total != checksum:
        raise SystemExit('checksum check failed: stored $%04X, file sums to $%04X' % (checksum, total))
    return out


def main(argv):
    if len(argv) != 2:
        raise SystemExit('usage: python3 tools/patchheader.py <image.sfc>')
    path = argv[1]
    original = open(path, 'rb').read()
    patched = patch(original)
    if patched == original:
        return
    with open(path, 'wb') as f:
        f.write(patched)
    checksum = patched[CHECKSUM] | (patched[CHECKSUM + 1] << 8)
    complement = patched[CHECKSUM_COMPLEMENT] | (patched[CHECKSUM_COMPLEMENT + 1] << 8)
    print('header %s: %d -> %d bytes, size $%02X, checksum $%04X, complement $%04X' % (
        path, len(original), len(patched), patched[ROM_SIZE], checksum, complement))


if __name__ == '__main__':
    main(sys.argv)
