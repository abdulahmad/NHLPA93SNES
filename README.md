# NHLPA Hockey '93 (SNES)

See [CONTRIBUTING.md](CONTRIBUTING.md) for how changes are made (names, comments, layout, verification).

> **Work in progress:** this disassembly is unfinished and unpolished, and is being actively worked on. Expect labels, file layout and docs to change.

## 🚧 Current Status

- About 75-80% done.
- Remaining: a pass to align it with NHLPA 93 Genesis, checking every asset is extracted correctly, and using the same file names and formats as the Genesis version (e.g. a file called title1 on Genesis is title1 on SNES too).
- Music names, frame lists and animation names still need proper labels.

**AI agent: start with [START_HERE.md](START_HERE.md).**

Bitwise rebuild of NHLPA Hockey '93 for the Super Nintendo, assembled with asar. The full build is byte-identical to `lst/nhlpa93snes.bin` (sha1 `76a01492cfb656e9fce0094bca356c312adfea0e`). Every bank is disassembled and named; the source is laid out like the NHLPA 93 Genesis source (one file per bank, one file per routine, routine folders named after the 93G modules).

## Lineage

The SNES port is a hybrid: it began as a port of NHL92 Genesis (likely while NHLPA93 Genesis was in development), then added what NHLPA93 needed. Some things look like 92G rather than 93G (in-game scoreboard layout, possibly title-screen credits colour). NHLPA93 Genesis is the naming source of truth; 92G names are used only where the SNES follows 92G with no 93G counterpart. See `docs/discovery93snes.md`. Related: [NHL94Genesis](https://github.com/abdulahmad/NHL94Genesis), [NHL95Genesis](https://github.com/abdulahmad/NHL95Genesis), [NHLPA93Genesis](https://github.com/abdulahmad/NHLPA93Genesis), [NHL92Genesis](https://github.com/abdulahmad/NHL92Genesis); McMarkis's NHL 94 SNES decomp for SNES-only systems.

## Layout

- `src/nhlpa93snes.asm` top level: includes the 16 bank files `src/banks/bXX_<name>.asm` in order. Each bank file has one `org` and includes its files in exact ROM order: routines in `src/routines/<93G module>/<Routine>.asm` (one per file), data in `src/data/<category>/<Name>.asm`, the header and vectors in `src/header/snes_header.asm`. `docs/file_map.md` lists every file per bank.
- `src/ram93s.asm` hardware registers, RAM names and constants (as 93G ram93.asm), `src/macros/snes93.mac` macros.
- `docs/name_map.csv` the quick-pass names (`CODE_xxxxxx`) of the named routines; `docs/segment_notes.md` the notes of the old ~4 KB slices.
- `tools/split_routines.py` the tool that split the old module files into this layout; `tools/gen_file_map.py` regenerates `docs/file_map.md`.
- `tools/scan_cleanup.py` counts raw addresses, generic labels and noise comments left in `src/`.
- `lst/nhlpa93snes.bin` reference ROM (committed, as NHL94Genesis does).
- `tools/disasm65816.py` the quick-pass generator (recursive descent from the vectors, REP/SEP/PHP/PLP M/X tracking). Setup only; it wrote the old `bankXX_YYYY` slices.
- `Extracted/` the incbin assets, extracted from the ROM by `tools/extract.py` (run by `tools/prebuild.py` on every build; not committed; folders Graphics, Sound, Text as in 93G); `src/data/README.md` describes the file formats (`.map.snesjim`, `.chr.pak`, `.snesmap`, `.pal`, ...).
- `tools/snesgfx.py` unpacks the packed streams (a port of `DecompressGraphics`) and renders tiles, maps and screens to PNG.
- `SEGMENT_AGENT.md` rules and the per-slice history, `PROMPT.md` the per-segment prompt (segment phase, finished), `docs/HANDOFF.md` setup notes and the cleanup progress.

## Build

Requires asar 1.91 on PATH:

```sh
git clone --depth 1 https://github.com/RPGHacker/asar.git && cd asar
cmake -S src -B build -DCMAKE_BUILD_TYPE=Release -DASAR_GEN_LIB=OFF && cmake --build build -j
cp build/asar/bin/asar ~/.local/bin/
```

Or run `sh tools/setup.sh` (Linux/macOS) or `tools\setup.ps1` (Windows), which install asar 1.91 into `tools/bin`. Then `./build.sh` (or `make`, or `build.ps1` on Windows). It writes `output/nhlpa93snes.sfc` and prints MATCH / MISMATCH.
