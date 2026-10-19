#!/usr/bin/env python3
# extract.py: write the data assets (packed graphics, maps, palettes, sprite sets, text, sound blocks) that the source
# includes by name. The bytes come from the ROM. Output is Extracted/<Graphics|Sound|Text>/ (the folders of the NHLPA 93
# Genesis project), which is not committed. tools/prebuild.py runs this when Extracted/ is missing or stale, and this
# script writes Extracted/.extract-complete.json last. src/data/README.md describes the formats (by file extension).
# Usage: python3 tools/extract.py lst/nhlpa93snes.bin           (writes every asset and the marker)
#        python3 tools/extract.py lst/nhlpa93snes.bin --check   (compares Extracted/ with the ROM, exit 1 on a difference)
# Each entry: file name below Extracted/, first ROM address, end address (exclusive). The addresses are LoROM/FastROM
# ($80:8000 is the start of the file).
import hashlib, json, os, sys
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
EXTRACTED = os.path.join(ROOT, 'Extracted')
MARKER = os.path.join(EXTRACTED, '.extract-complete.json')
ASSETS = [
    ('Graphics/RonBarr.map.snesjim', 0x80ED38, 0x80F36E),
    ('Sound/gamesamples.brr', 0x818054, 0x82B868),
    ('Graphics/IceRink.chr.pak', 0x82CDA0, 0x82F93C),
    ('Graphics/Pals/ASEh.pal', 0x838074, 0x838094),
    ('Graphics/Pals/ASEv.pal', 0x838094, 0x8380B4),
    ('Graphics/Pals/ASWh.pal', 0x838302, 0x838322),
    ('Graphics/Pals/ASWv.pal', 0x838322, 0x838342),
    ('Graphics/Pals/BOSh.pal', 0x838597, 0x8385B7),
    ('Graphics/Pals/BOSv.pal', 0x8385B7, 0x8385D7),
    ('Graphics/Pals/BUFh.pal', 0x83883F, 0x83885F),
    ('Graphics/Pals/BUFv.pal', 0x83885F, 0x83887F),
    ('Graphics/Pals/CGYh.pal', 0x838AF2, 0x838B12),
    ('Graphics/Pals/CGYv.pal', 0x838B12, 0x838B32),
    ('Graphics/Pals/CHIh.pal', 0x838D8F, 0x838DAF),
    ('Graphics/Pals/CHIv.pal', 0x838DAF, 0x838DCF),
    ('Graphics/Pals/DETh.pal', 0x83903E, 0x83905E),
    ('Graphics/Pals/DETv.pal', 0x83905E, 0x83907E),
    ('Graphics/Pals/EDMh.pal', 0x8392E9, 0x839309),
    ('Graphics/Pals/EDMv.pal', 0x839309, 0x839329),
    ('Graphics/Pals/HFDh.pal', 0x83958A, 0x8395AA),
    ('Graphics/Pals/HFDv.pal', 0x8395AA, 0x8395CA),
    ('Graphics/Pals/LAh.pal', 0x83982F, 0x83984F),
    ('Graphics/Pals/LAv.pal', 0x83984F, 0x83986F),
    ('Graphics/Pals/LIh.pal', 0x839AEB, 0x839B0B),
    ('Graphics/Pals/LIv.pal', 0x839B0B, 0x839B2B),
    ('Graphics/Pals/MINh.pal', 0x839D89, 0x839DA9),
    ('Graphics/Pals/MINv.pal', 0x839DA9, 0x839DC9),
    ('Graphics/Pals/MTLh.pal', 0x83A01A, 0x83A03A),
    ('Graphics/Pals/MTLv.pal', 0x83A03A, 0x83A05A),
    ('Graphics/Pals/NJh.pal', 0x83A2E4, 0x83A304),
    ('Graphics/Pals/NJv.pal', 0x83A304, 0x83A324),
    ('Graphics/Pals/NYh.pal', 0x83A58F, 0x83A5AF),
    ('Graphics/Pals/NYv.pal', 0x83A5AF, 0x83A5CF),
    ('Graphics/Pals/OTWh.pal', 0x83A84B, 0x83A86B),
    ('Graphics/Pals/OTWv.pal', 0x83A86B, 0x83A88B),
    ('Graphics/Pals/PHIh.pal', 0x83AA5E, 0x83AA7E),
    ('Graphics/Pals/PHIv.pal', 0x83AA7E, 0x83AA9E),
    ('Graphics/Pals/PITh.pal', 0x83AD0E, 0x83AD2E),
    ('Graphics/Pals/PITv.pal', 0x83AD2E, 0x83AD4E),
    ('Graphics/Pals/QUEh.pal', 0x83AFA9, 0x83AFC9),
    ('Graphics/Pals/QUEv.pal', 0x83AFC9, 0x83AFE9),
    ('Graphics/Pals/SJh.pal', 0x83B276, 0x83B296),
    ('Graphics/Pals/SJv.pal', 0x83B296, 0x83B2B6),
    ('Graphics/Pals/STLh.pal', 0x83B522, 0x83B542),
    ('Graphics/Pals/STLv.pal', 0x83B542, 0x83B562),
    ('Graphics/Pals/TBYh.pal', 0x83B7CF, 0x83B7EF),
    ('Graphics/Pals/TBYv.pal', 0x83B7EF, 0x83B80F),
    ('Graphics/Pals/TORh.pal', 0x83BA06, 0x83BA26),
    ('Graphics/Pals/TORv.pal', 0x83BA26, 0x83BA46),
    ('Graphics/Pals/VANh.pal', 0x83BCB4, 0x83BCD4),
    ('Graphics/Pals/VANv.pal', 0x83BCD4, 0x83BCF4),
    ('Graphics/Pals/WPGh.pal', 0x83BF5B, 0x83BF7B),
    ('Graphics/Pals/WPGv.pal', 0x83BF7B, 0x83BF9B),
    ('Graphics/Pals/WSHh.pal', 0x83C210, 0x83C230),
    ('Graphics/Pals/WSHv.pal', 0x83C230, 0x83C250),
    ('Graphics/SmallFont.chr.pak', 0x83C6D8, 0x83CC0C),
    ('Graphics/IceRink.snesmap', 0x83CCCB, 0x83ECAB),
    ('Graphics/IceRinkHor.snesmap', 0x83ECAB, 0x83F72B),
    ('Graphics/Pals/Rink.snespal', 0x83F72B, 0x83F82B),
    ('Graphics/Refs.snesmap', 0x83FAEC, 0x83FDFC),
    ('Graphics/Sprites/set09.pieces', 0x84807C, 0x848630),
    ('Graphics/Sprites/set09.chr', 0x848630, 0x84D630),
    ('Text/ScoutingReportText.bin', 0x84D630, 0x84E949),
    ('Graphics/HotList.bin', 0x84EF3C, 0x84F386),
    ('Graphics/RinkLogoTiles.chr.pak', 0x84F386, 0x84F532),
    ('Graphics/PlayoffTiles.chr.pak', 0x84F79D, 0x84F816),
    ('Graphics/Sprites/set04.pieces', 0x85806C, 0x8585A4),
    ('Graphics/Sprites/set04.chr', 0x8585A4, 0x85D5A4),
    ('Graphics/Title1.map.snesjim', 0x85D5C0, 0x85FBB9),
    ('Sound/driver.spc700', 0x868004, 0x86A6EB),
    ('Sound/bootsamples.brr', 0x86A7C9, 0x86FA3A),
    ('Graphics/Sprites/set02.pieces', 0x87805C, 0x8783A0),
    ('Graphics/Sprites/set02.chr', 0x8783A0, 0x87C3A0),
    ('Graphics/EASN.map.snesjim', 0x87C3A0, 0x87C6B4),
    ('Graphics/FaceOff.chr.pak', 0x87C6B4, 0x87CABA),
    ('Graphics/Sprites/set06.pieces', 0x87D231, 0x87D3E9),
    ('Graphics/Sprites/set06.chr', 0x87D3E9, 0x87F3E9),
    ('Graphics/Ref.chr.pak', 0x87F55E, 0x87FF78),
    ('Graphics/GameSetUp.map.snesjim', 0x888000, 0x88822F),
    ('Graphics/Framer.chr', 0x88872E, 0x8887AE),
    ('Graphics/Sprites/set08.pieces', 0x888A47, 0x888B73),
    ('Graphics/Sprites/set08.chr', 0x888B73, 0x889B73),
    ('Graphics/TeamBlocks.chr.pak', 0x889B73, 0x88BC56),
    ('Graphics/Sprites/set07.pieces', 0x88BCA0, 0x88BF9C),
    ('Graphics/Sprites/set07.chr', 0x88BF9C, 0x88EF9C),
    ('Graphics/Sprites/set11.pieces', 0x898028, 0x8980F0),
    ('Graphics/Sprites/set11.chr', 0x8980F0, 0x8990F0),
    ('Graphics/Sprites/set13.pieces', 0x8993F9, 0x89995D),
    ('Graphics/Sprites/set13.chr', 0x89995D, 0x89E95D),
    ('Graphics/RefHor.chr.pak', 0x89EB45, 0x89F3FB),
    ('Graphics/RefsHor.snesmap', 0x89F3FB, 0x89FB6B),
    ('Graphics/Sprites/set12.pieces', 0x8A80A0, 0x8A8880),
    ('Graphics/Sprites/set12.chr', 0x8A8880, 0x8AF880),
    ('Graphics/Sprites/set05.pieces', 0x8B847A, 0x8B8CCE),
    ('Graphics/Sprites/set05.chr', 0x8B8CCE, 0x8BFCCE),
    ('Graphics/NHLPALogo.map.snesjim', 0x8C8000, 0x8C845A),
    ('Graphics/Sprites/set00.pieces', 0x8C8526, 0x8C8C1A),
    ('Graphics/Sprites/set00.chr', 0x8C8C1A, 0x8CFC1A),
    ('Graphics/Sprites/set10.pieces', 0x8D88B8, 0x8D8EC8),
    ('Graphics/Sprites/set10.chr', 0x8D8EC8, 0x8DEEC8),
    ('Graphics/BigFont.chr.pak', 0x8DEEC8, 0x8DF888),
    ('Graphics/Sprites/set03.pieces', 0x8E8447, 0x8E89A7),
    ('Graphics/Sprites/set03.chr', 0x8E89A7, 0x8ED9A7),
    ('Graphics/Sprites/set14.pieces', 0x8EDA2F, 0x8EEB93),
    ('Graphics/Sprites/set14.chr', 0x8EEB93, 0x8EFE73),
    ('Graphics/Sprites/set01.pieces', 0x8F90F1, 0x8F94F9),
    ('Graphics/Sprites/set01.chr', 0x8F94F9, 0x8FD4F9),
]
def rom_offset(a): return ((a >> 16) & 0x7F) * 0x8000 + (a & 0x7FFF)
def sha1_of(data): return hashlib.sha1(data).hexdigest()
if __name__ == '__main__':
    rom = open(sys.argv[1], 'rb').read()
    check = '--check' in sys.argv[2:]
    bad = 0
    files = []
    for rel, start, end in ASSETS:
        path = os.path.join(EXTRACTED, rel)
        data = rom[rom_offset(start):rom_offset(end)]
        if check:
            if not os.path.exists(path) or open(path, 'rb').read() != data:
                print(f'differs: Extracted/{rel}'); bad += 1
        else:
            os.makedirs(os.path.dirname(path), exist_ok=True)
            open(path, 'wb').write(data)
            files.append({'path': rel, 'size': len(data)})
    names = {rel for rel, _, _ in ASSETS}
    for dirpath, _, fs in os.walk(EXTRACTED):
        for f in sorted(fs):
            rel = os.path.relpath(os.path.join(dirpath, f), EXTRACTED).replace(os.sep, '/')
            if f != '.extract-complete.json' and rel not in names:
                if check: print(f'not an asset: Extracted/{rel}')
                else: os.remove(os.path.join(dirpath, f)); print(f'deleted (not an asset): Extracted/{rel}')
    if check:
        print(f'{len(ASSETS) - bad} of {len(ASSETS)} assets match the ROM'); sys.exit(1 if bad else 0)
    marker = {'romSha1': sha1_of(rom), 'extractorSha1': sha1_of(open(__file__, 'rb').read()), 'files': files}
    open(MARKER, 'w').write(json.dumps(marker, indent=1) + '\n')
    print(f'Wrote {len(ASSETS)} assets to Extracted/')
