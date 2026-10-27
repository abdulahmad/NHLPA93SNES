# NHLPA Hockey '93 (SNES)

> **📀 Game data is not included.** This repository has the assembly code only. The graphics, team palettes, sprites, sound samples, music, text and the NHLPA player names are extracted from your own copy of the original ROM when you build, and are not in the repo. You need the NHLPA Hockey 93 Super Nintendo ROM, with the file name and SHA-1 listed under [Build](#build), or the build stops.

> **🤝 Making a mod, hack, port or other derivative work from this repo? You must credit me (abdulahmad) and everyone credited in this repo, clearly, in your own repo and in every release. See [Credits and derivative works](#credits-and-derivative-works).**

See [CONTRIBUTING.md](CONTRIBUTING.md) for how changes are made (names, comments, layout, verification).

> **Work in progress:** this disassembly is unfinished and unpolished, and is being actively worked on. Expect labels, file layout and docs to change.

## 🚧 Current Status

- About 75-80% done.
- Remaining: a pass to align it with NHLPA 93 Genesis, checking every asset is extracted correctly, and using the same file names and formats as the Genesis version (e.g. a file called title1 on Genesis is title1 on SNES too).
- Music names, frame lists and animation names still need proper labels.

**AI agent: start with [docs/history/START_HERE.md](docs/history/START_HERE.md).**

Bitwise rebuild of NHLPA Hockey '93 for the Super Nintendo, assembled with asar. The full build is byte-identical to `nhlpa93retail.sfc` (sha1 `76a01492cfb656e9fce0094bca356c312adfea0e`). Every bank is disassembled and named; the source is laid out like the NHLPA 93 Genesis source (one file per bank, one file per routine, routine folders named after the 93G modules).

## Lineage

The SNES port is a hybrid: it began as a port of NHL92 Genesis (likely while NHLPA93 Genesis was in development), then added what NHLPA93 needed. Some things look like 92G rather than 93G (in-game scoreboard layout, possibly title-screen credits colour). NHLPA93 Genesis is the naming source of truth; 92G names are used only where the SNES follows 92G with no 93G counterpart. See `docs/discovery93snes.md`. Related: [NHL94Genesis](https://github.com/abdulahmad/NHL94Genesis), [NHL95Genesis](https://github.com/abdulahmad/NHL95Genesis), [NHLPA93Genesis](https://github.com/abdulahmad/NHLPA93Genesis), [NHL92Genesis](https://github.com/abdulahmad/NHL92Genesis); McMarkis's NHL 94 SNES decomp for SNES-only systems.

## Layout

- `src/nhlpa93snes.asm` top level: includes the 16 bank files `src/banks/bXX_<name>.asm` in order. Each bank file has one `org` and includes its files in exact ROM order: routines in `src/routines/<93G module>/<area>/<Routine>.asm` (one per file), pure `incbin` data blocks in the bank file itself, other data (strings, tables, the team and frame data) in `src/data/<category>/<Name>.asm`, the header and vectors in `src/header/snes_header.asm`. `docs/file-map.md` lists every file per bank.
- `src/ram93s.asm` hardware registers, RAM names and constants (as 93G ram93.asm), `src/macros/snes93.mac` macros.
- `docs/history/symbol_map.csv` the address table (quick-pass names `CODE_xxxxxx` of the named routines), `docs/history/name_map.csv` the rename log (old,new,source), `docs/history/segment_notes.md` the notes of the old ~4 KB slices.
- `tools/split_routines.py` the tool that split the old module files into this layout; `tools/gen_file_map.py` regenerates `docs/file-map.md`.
- `tools/scan_cleanup.py` counts raw addresses, generic labels and noise comments left in `src/`.
- `tools/disasm65816.py` the quick-pass generator (recursive descent from the vectors, REP/SEP/PHP/PLP M/X tracking). Setup only; it wrote the old `bankXX_YYYY` slices.
- `Extracted/` the incbin assets, extracted from the ROM by `tools/extractAssets93s.js` (run by `tools/prebuild.js` on every build; not committed; folders Graphics, Sound, Text as in 93G); `docs/file-formats.md` describes the file formats (`.map.sjim`, `.chr.pak`, `.smap`, `.pal`, ...).
- `tools/snesgfx.py` unpacks the packed streams (a port of `DecompressBytecode`) and renders tiles, maps and screens to PNG.
- `docs/history/SEGMENT_AGENT.md` rules and the per-slice history, `docs/history/PROMPT.md` the per-segment prompt (segment phase, finished), `docs/HANDOFF.md` setup notes and the cleanup progress.

## Build

1. Install node from https://nodejs.org/en/download if it isn't already installed on your machine. No `npm i` is needed: the scripts have no dependencies.

2. Install asar 1.91 into `tools/bin` with `sh tools/setup.sh` (Linux/macOS; needs git, cmake and a C++ compiler) or `tools\setup.ps1` (Windows). An asar 1.91 on PATH also works.

3. Copy the NHLPA Hockey 93 Super Nintendo retail ROM into the `NHLPA93SNES` folder (no copier header). `nhlpa93retail.sfc` is the usual name, but any file name works: the build finds the ROM by its SHA-1 and size (`tools/roms.js`). It is not in the repo (`.sfc`, `.smc` and `.bin` files there are gitignored).

    | ROM | File name | SHA-1 | Size |
    | --- | --- | --- | --- |
    | NHLPA Hockey '93 SNES retail (USA) | `nhlpa93retail.sfc` | `76a01492cfb656e9fce0094bca356c312adfea0e` | 524288 bytes |

4. Run `npm run build:retail` (or `node tools/build.js retail`). It prints one line per step, with a short note under it and the result under that:

    1. **prebuild**: check the ROM and extract graphics, sound and text assets into `Extracted/` (when it is missing or stale).
    2. **names**: `src/data/teamdata93s.asm` has placeholders instead of the NHLPA player names (they are licensed data and are not in the repository). The prebuild extracts the real names from your ROM into `Extracted/Text/PlayerNames.txt`, and this step writes them into a copy, `output/retail/obj/teamdata93s.asm`, which `src/banks/b83_teams.asm` includes. A name must have the length of its placeholder.
    3. **assemble**: asar turns `src/nhlpa93snes.asm` into the ROM image.
    4. **header**: pad the image and store the checksum if the ROM grew (`tools/patchHeader.js`; the stock image is left as it is).
    5. **verify**: compare byte for byte with `nhlpa93retail.sfc`.

    The built ROM is `output/retail/nhlpa93snes.sfc`; `output/retail/obj/` holds asar's log and its symbol file (`nhlpa93snes.sym`, read by `tools/gen_file_map.py` and `tools/scan_cleanup.py`).

Other scripts:
- `npm run assets`: ROM check and asset extraction only (`npm run extractassets` runs the extractor directly; `node tools/extractAssets93s.js --check` compares `Extracted/` with the ROM)
- `npm run clean`: delete `output/` and `Extracted/` (re-extracted by the next build)
- `tools/verify_all.sh`: extracts fresh, builds, and runs the asset and comment checks, printing ALL MATCH
- Add `--verbose` to `node tools/build.js ...` for the full tool output; `--no-color` (or `NO_COLOR`) turns the colors off

# Documentation

- [File formats](docs/file-formats.md): every format in `Extracted/` (`.map.sjim`, `.sanim`, `.smap`, `.chr`, `.pal`, sound files, ...), strings, team data
- [Adding a team](docs/adding-a-team.md)
- [Source file map](docs/file-map.md): every file per bank in ROM order
- [Handoff notes](docs/HANDOFF.md): alignment with 93G, current state

## AI assistance

This project is AI-assisted. The work is directed by a strict ruleset and curated by hand, with the aim of producing correctly labelled and commented code that matches the spirit of what the original source code would have been. We can't guarantee it's perfect, and ultimately this will always be a work in progress. If you see something that needs fixing, raise an issue, or even better, raise a PR.

## Credits and derivative works

Thanks to chaos, StaticEck, McMarkis and Drezz for their help with the disassembly.

Special thanks to smozoma and kingraph, whose past contributions to the NHL modding community made this work easier.

This project is the result of my work (abdulahmad) and the work of the people credited above. If you build anything from it, including mods, ROM or EXE hacks, ports, released forks, tools, or any other derivative work, you must credit us:

- Put the credit in your repo's README, near the top and not buried in a footer, and in the notes of every release you publish, including any text file shipped inside a release archive.
- Name me (abdulahmad) and link to this repository.
- Name everyone credited here: chaos, StaticEck, McMarkis (Mhopkinsinc) and Drezz, with special thanks to smozoma and kingraph.
- If you only use part of this repo (docs, a tool, labels, a file format description), the credit still applies.
- If you are unsure, over-credit.

Credit is the condition for using this work. Please do not release a derivative without it.
