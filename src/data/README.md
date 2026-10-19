# Extracted/ (binary assets)

The `src/**/*.asm` files `incbin` binary assets from `Extracted/{Graphics,Sound,Text}/`, the folder layout of the NHLPA 93 Genesis
project. `Extracted/` is not committed. `tools/extract.py` writes it from `lst/nhlpa93snes.bin` (107 assets, each an exact ROM range),
`tools/prebuild.py` checks the ROM SHA-1 and runs the extraction when `Extracted/` is missing or stale, and `build.sh` / `build.ps1`
run `prebuild.py` first, so the build stays byte-identical. This file lives next to the sources that include the assets.
The file extension gives the format. The SNES formats are not the same as the Genesis (93G/94G) `.map.jim` / `.pal` / `.tiles` files
of the same names, so the SNES files get their own extensions, except the team palettes, which are byte-identical to the 93G `.pal` files.

| Extension | Format | Files |
|-----------|--------|-------|
| `.map.snesjim` | SNES flavour of the 93G jim screen container: the same compression (`DecompressBytecode`, see Packed streams), but one stream of map, palette and tiles (see Screens below) | `Title1`, `EASN`, `RonBarr`, `GameSetUp`, `NHLPALogo` |
| `.chr.pak` | Packed SNES 4bpp tiles | `IceRink`, `SmallFont`, `BigFont`, `FaceOff`, `Ref`, `RefHor`, `PlayoffTiles` (palette first), `TeamBlocks`, `RinkLogoTiles` |
| `.chr` | SNES 4bpp planar tiles, 32 bytes per 8x8 tile, not packed | `Sprites/setNN.chr`, `Framer` |
| `.pieces` | Sprite frame pieces (see Sprites below) | `Sprites/setNN.pieces` |
| `.snesmap` | SNES BG map words, not packed: vflip 15, hflip 14, priority 13, palette 12-10, tile 9-0 | `IceRink` (48 x 85), `IceRinkHor`, `Refs` (7 ref frames of 8 x 7), `RefsHor` (17 frames), `BigFont` (76 + 76 words), `SmallFont` (128 words), `TeamBlocks` (9 x 2 per team), `Arrows` (23 x 12, `PlayoffBracketMap`), `FaceOff` (12 x 10), `Framer` (3 x 3 pieces), `EASN` (7 x 2, the small logo) |
| `.pal` | Team palette, 16 colours per row, 93G colour words `0000 BBBB GGGG RRRR`, high byte first (same bytes as the 93G `.pal` files), which `SetTeamColors` ($80B706) converts to BGR555 | `Pals/<team>h`, `Pals/<team>v` |
| `.snespal` | Palette of SNES BGR555 words | `Pals/Rink` |
| `.brr` | SPC700 BRR sound samples (the sample block of an SPC upload stream) | `bootsamples`, `gamesamples` |
| `.spc700` | SPC700 sound driver code, uploaded to APU $0400 | `driver` |
| `.bin` | Tables or text with their own format, described where they are included | `HotList` (the 549 hot spot pairs), `Text/ScoutingReportText` |

Genesis vs SNES, for comparison:

| | Genesis | SNES |
|-|---------|------|
| Palette word | 9-bit `0000 BBB0 GGG0 RRR0` | BGR555 `0BBBBBGGGGGRRRRR` |
| Tiles | 4bpp packed, 4 bits per pixel | 4bpp planar, bitplanes 0/1 then 2/3 |
| Map word | priority 15, palette 14-13, vflip 12, hflip 11, tile 10-0 | vflip 15, hflip 14, priority 13, palette 12-10, tile 9-0 |
| Packing | `.jim` / `.anim` containers | the `DecompressBytecode` stream below |

## Packed streams (`.pak`)

`DecompressBytecode` (`$86FA3E`, `src/routines/decompress/DecompressBytecode.asm`) unpacks a stream to `$7F0000`. Control bytes:

- `$00-$1F`: copy the next n+1 bytes
- `$2x`: write n+1 zero bytes
- `$3x`: write the next byte n+3 times
- `$40-$7F`, `$8x`, `$9x`, `$Ax`, `$Bx`: copy from earlier output, going up
- `$C0-$DF`, `$Ex`, `$Fx`: copy from earlier output, going down
- `$E0 $00`: end of stream

## Screens (`.map.snesjim`)

The unpacked data holds the map words, then the palette, then the tiles. Offsets:

| File | Map | Palette | Tiles | Notes |
|------|-----|---------|-------|-------|
| `Title1.map.snesjim` | 32 x 28 at 0 | at $700 | at $800 | title screen (93G `Title1.map.jim`) |
| `RonBarr.map.snesjim` | 8 x 9 at 0 | 64 colours at $90 | at $190 | Ron Barr picture (93G `RonBarrMap`) |
| `GameSetUp.map.snesjim` | 32 x 32 at 0 | 128 colours at $800 | at $900 | game setup backdrop; `--map-size 0x800 --pal-offset 0x800 --tiles-offset 0x900` |
| `NHLPALogo.map.snesjim` | 8 x 10 at 0 | 128 colours at $A0 | at $1A0 | NHLPA logo; `--width 8 --map-size 0xA0 --pal-offset 0xA0 --tiles-offset 0x1A0` |
| `EASN.map.snesjim` | 32 x 16 at 0 | none | at $400 | EASN logo backdrop (93G `EASN.map.jim`); `--map-size 0x400 --no-pal` |

## Sprites (`Extracted/Graphics/Sprites/setNN`)

`FrameSetTable` ($8FE67D) lists the 15 frame sets. Each set's header in `src/data/gfx/SpriteSet*.asm` (`SpriteSetN:`) gives the frame,
piece and tile counts and the first piece of each frame (`.frames`). `setNN.pieces` holds the pieces and `setNN.chr` the 4bpp tiles.
Frame numbers (`sprframe`, the `SPF` names in `ram93s.asm`) run on from set to set, starting at 1 (set 0).

- Sets 0-13 (frames 1-658, `DrawFrame` $87CE62): 4-byte pieces: x, y (signed bytes), tile, attributes.
- Set 14 (frames 659-720, `DrawFrameHi` $85FBB9): 6-byte pieces: x, y (signed words), tile, attributes. These are the crowd:
  659-689 for the vertical rink, at `IceRink.snesmap` pixel positions, and 690-720 for the horizontal rink.
- Attributes: tile bits 8-9 (bits 0-1), palette (bits 2-4), 16 x 16 (bit 5: tiles t, t+1 over t+16, t+17), hflip (6), vflip (7).
  Palette 2 is the home team colours; `sprflag` $8000 moves it to palette 3, the visitor colours.
- The first piece is on top (OAM order).

## tools/snesgfx.py

This script unpacks and renders the assets above, for checking a guess about what a block holds. Rendering needs Pillow
(`python -m pip install pillow`); `unpack` does not.

```
python tools/snesgfx.py unpack Extracted/Graphics/EASN.map.snesjim -o easn.bin
python tools/snesgfx.py unpack --rom 0x80ED38 -o block.bin       # a packed stream still in lst/nhlpa93snes.bin
python tools/snesgfx.py screen Extracted/Graphics/Title1.map.snesjim -o title.png
python tools/snesgfx.py screen Extracted/Graphics/RonBarr.map.snesjim --width 8 --map-size 0x90 --pal-offset 0x90 --tiles-offset 0x190 -o ronbarr.png
python tools/snesgfx.py tiles Extracted/Graphics/BigFont.chr.pak --columns 16 -o bigfont.png
python tools/snesgfx.py map Extracted/Graphics/IceRink.snesmap --tiles Extracted/Graphics/IceRink.chr.pak --width 48 --pal Extracted/Graphics/Pals/Rink.snespal -o rink.png
python tools/snesgfx.py sprites 0 -o set00.png                     # frame set 0, labelled with frame numbers and SPF names
python tools/snesgfx.py sprites all -o sprites.png                 # sprites00.png .. sprites14.png
python tools/snesgfx.py sprites --frames 406-461 --team MTL --visitor -o goalie.png
python tools/snesgfx.py sprites --frames 41-48 -o skate.gif        # a .gif output is an animation
python tools/snesgfx.py sprites --frames 659-689 --rink -o crowd.gif   # the crowd frames on the rink map
```

A `.pak` input is unpacked automatically. `--pal FILE[:OFFSET]` takes any file that holds BGR555 words. Without it, colours are grey levels.
`sprites` uses the game palette: `Pals/Rink` with sprite rows 2/3 from the `--team` colours (default BOS; `--visitor-team` for another visitor).
Other options: `--bg RRGGBB|transparent`, `--origin` (marks sprx/spry), `--no-labels`, `--columns`, `--scale`, `--delay` (GIF ms).
