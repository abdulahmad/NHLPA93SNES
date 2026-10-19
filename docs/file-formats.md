# File formats

Formats of the data in the NHLPA Hockey '93 (SNES) ROM, and of the files in `Extracted/`. The sister document for the Genesis game is
[NHLPA93Genesis docs/file-formats.md](https://github.com/abdulahmad/NHLPA93Genesis/blob/main/docs/file-formats.md); this one uses the same
sections, so the two can be read side by side.

All multi-byte values in the SNES (65816 / SPC700) data are little endian, except the player ratings and the scouting ratings, which are
written as big endian words (as on the Genesis, the team data was ported as it was).

## Extracted/

The `src/**/*.asm` files `incbin` binary assets from `Extracted/{Graphics,Sound,Text}/`, the folder layout of the NHLPA 93 Genesis
project. `Extracted/` is not committed. `tools/extractAssets93s.js` writes it from `nhlpa93retail.sfc` (143 assets, each an exact ROM range),
`tools/prebuild.js` checks the ROM SHA-1 and runs the extraction when `Extracted/` is missing or stale, and `tools/build.js` runs
`prebuild.js` first, so the build stays byte-identical. `node tools/extractAssets93s.js nhlpa93retail.sfc --check` compares the folder with the ROM.

### Names

The extension gives the format. A format that exists in the Genesis game under a name keeps that name here with an **s** in front of the last
part (`s` for SNES): the SNES files are not the same as the Genesis ones, so they must not be mistaken for them.

| Genesis | SNES | Notes |
|---------|------|-------|
| `X.map.jim` | `X.map.sjim` | screen container: map, palette and tiles in one file |
| `Sprites.anim`, `X.anim` | `Sprites<first>_<last>.sanim` | sprite frame sets |
| `X.pal` | `X.pal` (team palettes), `X.spal` (BGR555) | the team palettes are the same bytes as the 93G files |
| inside `X.map.jim` | `X.smap` | the Genesis keeps a map inside its `.map.jim`; the SNES game also has maps that are not packed and share tiles, so they are files of their own |
| inside `X.map.jim` / `X.anim` | `X.chr`, `X.chr.pak` | tiles without a map: 4bpp planar, raw or packed |

### Files

| Extension | Format | Files |
|-----------|--------|-------|
| `.map.sjim` | Packed screen: the same compression as the 93G `.map.jim` (`DecompressBytecode`, see [Packed streams](#packed-streams-pak)), but one stream holding map, palette and tiles, see [Screens](#screens-mapsjim) | `Title1`, `EASN`, `RonBarr`, `GameSetUp`, `NHLPALogo` |
| `.sanim` | Sprite frame set: header, frame index, pieces, tiles, see [Sprite sets](#sprite-sets-sanim) | `Sprites/Sprites001_096` ... `Sprites/Sprites659_720` |
| `.smap` | SNES BG map words, not packed, see [Maps](#maps-smap) | `IceRink`, `IceRinkHor`, `Refs`, `RefsHor`, `BigFont`, `SmallFont`, `TeamBlocks`, `Arrows`, `FaceOff`, `Framer`, `EASN` |
| `.chr.pak` | Packed SNES 4bpp tiles | `IceRink`, `SmallFont`, `BigFont`, `FaceOff`, `Ref`, `RefHor`, `PlayoffTiles` (palette first), `TeamBlocks`, `RinkLogoTiles` |
| `.chr` | SNES 4bpp planar tiles, 32 bytes per 8x8 tile, not packed | `Framer` |
| `.pal` | Team palette, see [Palettes](#palettes) | `Pals/<team>h`, `Pals/<team>v` (52 files) |
| `.spal` | Palette of SNES BGR555 words | `Pals/Rink` |
| `.bin` | Tables or text with their own format, described below | `HotList`, `Text/ScoutingReportText`, `Sound/sfx_table` |
| `_cmdstream.bin` | Command streams of the sound program, see [Sound](#sound) | `Sound/fmtune_<song>`, `Sound/sfx_<name>` |
| `.brr` | SPC700 BRR sound samples | `Sound/bootsamples`, `Sound/gamesamples` |
| `.spc700` | SPC700 sound driver code and tables | `Sound/driver` |

Genesis and SNES side by side:

| | Genesis | SNES |
|-|---------|------|
| Palette word | 9-bit `0000 BBB0 GGG0 RRR0` | BGR555 `0BBBBBGGGGGRRRRR` |
| Tiles | 4bpp, 4 bits per pixel | 4bpp planar, bitplanes 0/1 then 2/3 |
| Map word | priority 15, palette 14-13, vflip 12, hflip 11, tile 10-0 | vflip 15, hflip 14, priority 13, palette 12-10, tile 9-0 |
| Packing | `.map.jim` / `.anim` containers, tiles optionally packed (bit 15 of the tile count) | the same `DecompressBytecode` stream, in `.map.sjim` and `.chr.pak` |
| Sprite pieces | 8 bytes, hardware sprite size code | 4 bytes (6 for the crowd), see [Sprite sets](#sprite-sets-sanim) |
| Sound | Z80 driver, FM patches, PCM samples, 68000 event streams | SPC700 driver (N-SPC style), BRR samples, command streams inside the driver |

## Packed streams (`.pak`)

`DecompressBytecode` (`$86FA3E`, `src/routines/decompress/DecompressBytecode.asm`) unpacks a stream to `$7F0000`. It is the same byte
oriented LZ77 style code as the Genesis one (`src/decompress93.asm` in 93G, where the output goes through a 256 byte ring buffer to VRAM).
The high nibble of an opcode byte selects the handler:

| Opcode | Does |
|--------|------|
| `$00-$1F` | copy the next (opcode & `$1F`) + 1 bytes |
| `$2x` | write (x + 1) zero bytes |
| `$3x` | write the next byte (x + 3) times |
| `$40-$7F` | copy (bits 0-2) + 2 bytes from (bits 3-5) + 1 bytes back |
| `$8x` | copy x + 3 bytes from the distance in the next byte |
| `$9x` | count = 5 bits (x and bit 7 of the next byte) + 3, distance = (bits 0-6 of the next byte) + 1 |
| `$Ax` | count = 6 bits (x and the top 2 bits of the next byte) + 3, distance = (bits 0-5 of the next byte) + 1 |
| `$Bx` | count = 7 bits (x and the top 3 bits of the next byte) + 3, distance = (bits 0-4 of the next byte) + 1 |
| `$C0-$DF` | like `$40-$7F`, but the source walks down: count (bits 0-1) + 2, distance (bits 2-4) + 1 |
| `$Ex` | like `$8x`, source walks down; `$E0 $00` (distance 0) ends the stream |
| `$Fx` | like `$9x`, source walks down |

`tools/snesgfx.py unpack` is a port of it.

## Screens (`.map.sjim`)

A packed stream. The unpacked data holds the map words, then the palette, then the tiles. The sizes are not in the file; the code that
uses a screen knows them. Offsets:

| File | Map | Palette | Tiles | Notes |
|------|-----|---------|-------|-------|
| `Title1.map.sjim` | 32 x 28 at 0 | at $700 | at $800 | title screen (93G `Title1.map.jim`) |
| `RonBarr.map.sjim` | 8 x 9 at 0 | 64 colors at $90 | at $190 | Ron Barr picture (93G `RonBarrMap`) |
| `GameSetUp.map.sjim` | 32 x 32 at 0 | 128 colors at $800 | at $900 | game setup backdrop; `--map-size 0x800 --pal-offset 0x800 --tiles-offset 0x900` |
| `NHLPALogo.map.sjim` | 8 x 10 at 0 | 128 colors at $A0 | at $1A0 | NHLPA logo; `--width 8 --map-size 0xA0 --pal-offset 0xA0 --tiles-offset 0x1A0` |
| `EASN.map.sjim` | 32 x 16 at 0 | none | at $400 | EASN logo backdrop (93G `EASN.map.jim`); `--map-size 0x400 --no-pal` |

## Maps (`.smap`)

Plain arrays of SNES BG map words (not packed): vflip bit 15, hflip 14, priority 13, palette 12-10, tile 9-0. The tiles are in a `.chr.pak`
or `.chr` the game sends to VRAM separately; the tile number is relative to where they are loaded.

| File | Content |
|------|---------|
| `IceRink` | 48 x 85 words, the vertical rink (tiles `IceRink.chr.pak`) |
| `IceRinkHor` | the horizontal rink |
| `Refs` | 7 ref frames of 8 x 7 |
| `RefsHor` | 17 ref frames (horizontal) |
| `BigFont` | 76 words for the top rows, then 76 for the bottom rows (`+$98`); `BigFontIndex` says which characters use them |
| `SmallFont` | 128 words, one per character of the print font (`SmallFontMap`) |
| `TeamBlocks` | 9 x 2 words per team, the team name banners (`Teamblocksmap`) |
| `Arrows` | 276 words (12 wide, 23 high as in the Genesis `Arrows.map.jim`), the playoff bracket (`PlayoffBracketMap`, tiles in `PlayoffTiles.chr.pak`) |
| `FaceOff` | 12 x 10, the face off box |
| `Framer` | 3 x 3 pieces of the frame around the screens (tiles in `Framer.chr`) |
| `EASN` | 7 x 2, the small EASN logo |

## Tiles (`.chr`, `.chr.pak`)

SNES 4bpp planar tiles, 8 x 8 pixels, 32 bytes each: bitplanes 0 and 1 interleaved by row in the first 16 bytes, planes 2 and 3 in the next 16.
`.chr.pak` is the same data packed with the stream above. `PlayoffTiles.chr.pak` starts with its palette (128 colors) before the tiles.

## Sprite sets (`.sanim`)

`FrameSetTable` (`$8FE67D`) lists the 15 frame sets. Each `Graphics/Sprites/Sprites<first frame>_<last frame>.sanim` is one set, byte for byte as it is in the ROM
(`SpriteSetN` in the bank files):

| Offset | Size | Content |
|--------|------|---------|
| 0 | word | number of frames |
| 2 | word | number of pieces |
| 4 | word | number of tiles |
| 6 | word | offset of the pieces from the start of the file |
| 8 | word | offset of the tiles from the start of the file |
| 10 | (frames + 1) words | the number of the first piece of each frame, then the end (so a frame's pieces are `start[i] .. start[i+1]-1`) |
| `pieces` | pieces x 4 or 6 bytes | the pieces of all the frames, first piece on top (OAM order) |
| `tiles` | tiles x 32 bytes | the 4bpp tiles of the set |

Frame numbers (`sprframe`, the `SPF` names in `ram93s.asm`) run on from set to set, starting at 1 (set 0). `src/data/frames93s.asm` has the
animations that step through them.

| Set | File | ROM | Bytes | Frames | Count | Pieces | Tiles | Piece size |
|-----|------|-----|-------|--------|-------|--------|-------|------------|
| 0 | `Sprites001_096.sanim` | `$8C845A` | 30656 | 1-96 | 96 | 445 | 896 | 4 |
| 1 | `Sprites097_144.sanim` | `$8F9085` | 17524 | 97-144 | 48 | 258 | 512 | 4 |
| 2 | `Sprites145_184.sanim` | `$878000` | 17312 | 145-184 | 40 | 209 | 512 | 4 |
| 3 | `Sprites185_224.sanim` | `$8E83EB` | 21948 | 185-224 | 40 | 344 | 640 | 4 |
| 4 | `Sprites225_272.sanim` | `$858000` | 21924 | 225-272 | 48 | 334 | 640 | 4 |
| 5 | `Sprites273_336.sanim` | `$8B83EE` | 30944 | 273-336 | 64 | 533 | 896 | 4 |
| 6 | `Sprites337_352.sanim` | `$87D205` | 8676 | 337-352 | 16 | 110 | 256 | 4 |
| 7 | `Sprites353_383.sanim` | `$88BC56` | 13126 | 353-383 | 31 | 191 | 384 | 4 |
| 8 | `Sprites384_405.sanim` | `$888A0F` | 4452 | 384-405 | 22 | 75 | 128 | 4 |
| 9 | `Sprites406_461.sanim` | `$848000` | 22064 | 406-461 | 56 | 365 | 640 | 4 |
| 10 | `Sprites462_517.sanim` | `$8D883C` | 26252 | 462-517 | 56 | 388 | 768 | 4 |
| 11 | `Sprites518_531.sanim` | `$898000` | 4336 | 518-531 | 14 | 50 | 128 | 4 |
| 12 | `Sprites532_605.sanim` | `$8A8000` | 30848 | 532-605 | 74 | 504 | 896 | 4 |
| 13 | `Sprites606_658.sanim` | `$899383` | 21978 | 606-658 | 53 | 345 | 640 | 4 |
| 14 | `Sprites659_720.sanim` | `$8ED9A7` | 9420 | 659-720 | 62 | 742 | 151 | 6 |

- Sets 0-13 (frames 1-658, `DrawFrame` `$87CE62`): 4-byte pieces: x, y (signed bytes), tile, attributes.
- Set 14 (frames 659-720, `DrawFrameHi` `$85FBB9`): 6-byte pieces: x, y (signed words), tile, attributes. These are the crowd: 659-689 for the
  vertical rink, at `IceRink.smap` pixel positions, and 690-720 for the horizontal rink.
- Attributes: tile bits 8-9 (bits 0-1), palette (bits 2-4), 16 x 16 (bit 5: tiles t, t+1 over t+16, t+17), hflip (6), vflip (7).
  Palette 2 is the home team colors; `sprflag` `$8000` moves it to palette 3, the visitor colors.

Compared with the Genesis `.anim`: the Genesis game keeps one big frame set (`Sprites.anim`) with 8-byte pieces that carry a hardware sprite
size code, and a separate hot spot table; the SNES game splits its frames over 15 sets that are loaded into VRAM one at a time, with 8 x 8 or
16 x 16 pieces.

### Hot spots (`HotList.bin`)

Two signed bytes per frame, x then y: the position of the stick blade (hot spot) relative to the frame origin, read by `GetHot`. The list has
549 pairs, for the frames 1 up to the fight injury frames; the injury frames (`SPFfinjury` .. `SPFPen`) are skipped, `GetHot` shifts the frame
number past them.

## Animations (`src/data/frames93s.asm`)

`SPFxxx` equates give the first frame number of each group of frames (chained: `SPFskate = SPFskatewp+40`). `SPAlist` is the list of
animation tables, one per animation, in the order of the `SPA` numbers; a `SPA` value is the table's offset from `SPAlist` (each `SPAxxx`
equate sits above its table, and an assert checks it). A table is eight word offsets (one per facing direction 0-7, relative to the table),
a flags word (0 or 1: loops), then per direction a list of `frame, time` word pairs; a negative time ends the list. The 93G table has the
same layout (`src/frames93.asm`).

## Palettes

- **`.pal`** (team palettes, `Pals/<team>h.pal` home, `Pals/<team>v.pal` visitor, 32 bytes each): 16 colors, each a big endian word `0000 BBBB
  GGGG RRRR` as in the 93G files (same bytes). `SetTeamColors` (`$80B706`) shifts each up one bit into BGR555. The two files of a team
  are stored back to back in the team record.
- **`.spal`** (`Pals/Rink.spal`): 128 BGR555 words, the game palette (`RinkPalette`), copied to both halves of the CGRAM buffer. Sprite rows 2
  and 3 are overwritten with the home and visitor team colors (`setplayercolors`).

## Text

### Strings

A string is a little endian word that counts itself, then the bytes: `%String("Boston")` is `08 00 "Boston"`. The `%String...` macros in
`src/macros/snes93.mac` build them (93G has `String` and `StringB`; the SNES version does not pad to an even length). The print routine
(`print`, `$80`-bit codes below) reads a string from a1; a string longer than 255 bytes hangs by design.

A byte with bit 7 set is a print control code: palette, priority and font of the text after it, then x and y (`CC_Font1`, `CC_Font2`,
`CC_Font1Pri`, ... in `ram93s.asm`; the byte is `-(priority << 6 | palette << 4 | font)`). `@` is a blank tile. Characters are looked up
in `SmallFontMap` (`SmallFont.smap`).

### `Text/ScoutingReportText.bin`

ASCII paragraphs, each ended by `$0D`, for the scouting report screen (`UpdateScoutingDisplay`): paragraph n for team n (0-25) and a few
fixed ones for the intro and closing lines. Words are separated by spaces; `_` `{` `}` `[` `]` stand for a team name or a player name
(home / away) that the game inserts. `,` and `.` make the typing pause.

## Sound

The game uploads a sound program to the SPC700 and then only writes one byte cues to port 0 (counter on port 1). The program is a Nintendo
N-SPC style sequencer with the songs and effects inside it. There are two uploads, both in the source (`src/data/sound/`): the boot stream
(driver, instrument table, sample directory, boot samples, started at `$0400`) and the in-game stream (sample directory and the game
samples, started at `$0800`). Each upload block is headed by its length and APU address, and an end block of length 0 starts the program.

| File | Content |
|------|---------|
| `driver.spc700` | the SPC700 sound program, loaded at APU `$0400`: sequencer code, note tables, cue pointer table (the first `$AA5` bytes of the driver block). The code is not disassembled |
| `fmtune_<song>_cmdstream.bin` | a song, named like 93G's `fmtune_*_cmdstream`: its order list, its channel set (pointers to 8 channel streams) and the channel streams, joined in address order |
| `sfx_<name>_cmdstream.bin` | one sound effect program: steps `$80` note, `$81` repeat, `$82` pitch sweep, `$83` end, `$84` loop |
| `sfx_table.bin` | the effect program pointers and voices (105 bytes) |
| `bootsamples.brr`, `gamesamples.brr` | the sample blocks of the two uploads: BRR blocks of 9 bytes (16 samples each) |

Cues (port 0): `$00` stop music; `$01`-`$09` songs (boot set: 1 playoff screen, 2 unused, 3 title screen, 9 unused; game set: 4 home goal,
5 period start, 6 third period, 7 unused, 8 mid-period); `$80`-`$87` crowd noise level; `$88` crowd off; `$89`-`$A1` sound effects;
`$F8` re-upload request.

Songs: cue c's order list pointer is the word at `$0E91 + 2c`. An order list is a list of words: a pointer to eight channel pointers (one
set), `$0000` to end, or `$00nn` plus a target for a repeat or jump. Channel streams are durations (with an optional quantise / velocity
byte), notes `$80`-`$C7`, tie `$C8`, rest `$C9`, percussion `$CA`-`$DF` and commands `$E0`-`$FA` (instrument, pan, vibrato, volume, tempo,
transpose, call, pitch envelope, echo, ...). NHL9XStudio's `docs/NHL93S-SOUND.md` has the full description and the MIDI conversion.

## Team data (`src/data/teamdata93s.asm`)

`TeamList` is a table of 26 long pointers (`NumofTeams`), indexed by team number (clubs 0-23, AllStarsEast 24, AllStarsWest 25).
A team record, all words little endian:

| Offset | Content |
|--------|---------|
| `.0`+0 .. +10 | six word offsets from `.0`: `Playerdata`, `Palettedata`, `Teamname`, `LineSets`, `ScoutReport`, `GoalieOdds` |
| `.pad` | home palette, then visitor palette (32 bytes each, `.pal` format) |
| `.sr` | scouting report, 8 bytes: nibbles `qreb,hvxx,skpd,cfgo`. q/r = scoring odds offense/defense row, e = penalty kill deficit, b = power play bonus; h/v = home/visitor bonus; s k p d = shooting, skating, passing, defense; c f g o = checking, fighting, goalkeeping, overall |
| `.godds` | starting goalie weights, 2 bytes (4 nibbles, `PickStartingGoalie`) |
| `.ls` | line sets: 7 lines of 8 bytes (`-G,LD,RD,LW,-C,RW,XA,00`, roster numbers; lines 4-5 are power play 1-2, 6-7 penalty kill 1-2) |
| `.pld` | the roster: player records, then `dw 2` (an empty name) |
| `.tn`, `.ta` | team name and abbreviation, as strings |

A player record: a word that counts itself, the name (ASCII, no terminator), then 8 bytes of ratings, written as four big endian words
`unwl,sodp,chga,eytm`: u/n = uniform number tens/ones, w = weight, l = leg power, s = speed, o/d = offensive/defensive awareness, p = shot
power, c = checking strength, h = shooting hand (glove hand for a goalie), g = stickhandling (glove left saves), a = shooting accuracy
(glove right saves), e = endurance (stick right saves), y = shot/pass decision (stick left saves), t = passing accuracy (consistency),
m = aggressiveness (PIM). A goalie uses the same fields with the meanings in brackets.

After the 26 records: `playoffseats`, 34 trees of 16 team numbers (first round tree order, adjacent pairs meet).

How to add a team: [adding-a-team.md](adding-a-team.md).

## Tools

- `tools/extractAssets93s.js` writes `Extracted/` from the ROM (`--check` compares).
- `tools/snesgfx.py` unpacks and renders the graphics (Pillow for the PNG/GIF output):

```
python tools/snesgfx.py unpack Extracted/Graphics/EASN.map.sjim -o easn.bin
python tools/snesgfx.py unpack --rom 0x80ED38 -o block.bin       # a packed stream still in nhlpa93retail.sfc
python tools/snesgfx.py screen Extracted/Graphics/Title1.map.sjim -o title.png
python tools/snesgfx.py screen Extracted/Graphics/RonBarr.map.sjim --width 8 --map-size 0x90 --pal-offset 0x90 --tiles-offset 0x190 -o ronbarr.png
python tools/snesgfx.py tiles Extracted/Graphics/BigFont.chr.pak --columns 16 -o bigfont.png
python tools/snesgfx.py map Extracted/Graphics/IceRink.smap --tiles Extracted/Graphics/IceRink.chr.pak --width 48 --pal Extracted/Graphics/Pals/Rink.spal -o rink.png
python tools/snesgfx.py sprites 0 -o set00.png                     # frame set 0, labelled with frame numbers and SPF names
python tools/snesgfx.py sprites all -o sprites.png                 # sprites00.png .. sprites14.png
python tools/snesgfx.py sprites --frames 406-461 --team MTL --visitor -o goalie.png
python tools/snesgfx.py sprites --frames 41-48 -o skate.gif        # a .gif output is an animation
python tools/snesgfx.py sprites --frames 659-689 --rink -o crowd.gif   # the crowd frames on the rink map
```

A `.pak` input is unpacked automatically. `--pal FILE[:OFFSET]` takes any file that holds BGR555 words; without it the colors are grey
levels. `sprites` uses the game palette (`Pals/Rink`) with sprite rows 2/3 from the `--team` colors (default BOS; `--visitor-team` for another
visitor). Other options: `--bg RRGGBB|transparent`, `--origin`, `--no-labels`, `--columns`, `--scale`, `--delay` (GIF ms).
