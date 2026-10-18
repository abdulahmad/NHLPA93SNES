## Local names (2026-10-14)

Signed-compare overflow tails (`bmi` / `bvs` / `bvc`) are `.neg`, `.neg1`, `.neg2`, ... in source order. The earlier `.vN` pass is unchanged. `assdefd` had one leftover `.gt1` tail; it is `.neg2`, and the later tails in that routine moved to `.neg3` and `.neg4`. A `bcc` test is not that pattern. Where 93 Genesis already names the label, that name stays (`CompShoot` `.lt`). `holdcheck` has no 93G label on the facing test, so a facing delta under 3 is `.close`. `remap` has no 93G routine: the pixel bits are `.bit3`..`.bit0` and the video-memory store is `.vram`.

Locals renamed only where 93 Genesis has no such label: `TitleScreen` `.clearvr` (16 video-memory words), `VBjsr` `.rti`, `UpdateRosterPlayer` `.space`, `updatepentime` `.stay`, `updatepwrplay` `.diff`, `chkprogress` `.over`, `Fprint_list` `.step`, `DrawFrame` / `DrawFrameHi` `.nextpiece`, `printbig` `.nextch`, `chk4pass` `.miss` (the 93G `.ok` join stays). Unused labels with no branch were removed from `prefmes` and `passtoa0`.

Left on their 93 Genesis names: `TryAddPlayerToList` `.no`, `UpdateScoutingDisplay` `.cont`, `checkcoll` `.xx`, `checkwindow` `.ok`, `assbench` / `asspenalty` `.ok`, `assgoalie` `.out`, `chk4shot` `.no1`, `GetNameandAttrib` `.skip`. `.loop`, `.next`, `.done` and `.exit` stay. `.cont1` stays: it is the controller-1 side of `cont1team` / `cont2team`.

Inline comments from 93 Genesis, on the matching instruction: `holdcheck` (facing, the puck carrier, the second hold anim, the two penalties), `chkprogress` (the minutes search, `temp1 = 120*60`), `GetNameandAttrib` (the roster record, the rating sum). The `holdcheck` header had X and a2 swapped: a2 is the one holding, X is the opponent.

Still open: `.go`, `.set`, `.clr`, `.hi`, `.lo`, `.x` and `.add` (read each one; keep a name that matches 93G), the `assgoalie` `.outx` / `.out2` / `.outn` family, the rest of the 93G inline comments, and the hockey routines that were not body-checked (67 of that folder were read).

## Expanded banks and the team count (2026-10-14)

The stock image still matches (`76a01492cfb656e9fce0094bca356c312adfea0e`). No team was added. How to add one is `docs/ADDING_A_TEAM.md`.

- `check bankcross` stays off. Turning it on fails the stock assemble: asar 1.91 warns `Wfeature_deprecated` (`check bankcross on` is the old name of `bankcheck on`, and it points at `bankcheck full` or `bankcheck half`) and then errors `Ebank_border_crossed` on the in-game sample `incbin` in `src/data/sound/gamesound.asm`. That stream runs from bank $81 into $82, and `b82` starts where it ends. No other stock bank crosses. `bankcheck half` and `bankcheck full` were not tried; the cross is the sample data, so the check stays off.
- `src/header/snes_header.asm` keeps size `$09`, complement `$B75A`, checksum `$48A5`. `build.sh` and `build.ps1` still pass `--fix-checksum=off`, then run `python3 tools/patchheader.py` on `output/nhlpa93snes.sfc`. On the retail image the patch writes nothing. On a larger image it pads with `$00` to the next SNES size (`$0A` = 1MB, `$0B` = 2MB, `$0C` = 4MB), stores the checksum and its complement little-endian, and checks that the finished file sums to that word. A complement pair always adds `$01FE`. Cartridge type stays ROM only. SRAM size stays 0. There is no cart save RAM. Running the patch on `lst/nhlpa93snes.bin` leaves `$48A5` and `$B75A`.
- Each bank file after `$80` orgs only when `pc()` has not already reached that address. On the stock tree the PC arrives exactly there, so the org is skipped. Bank `$80` stays an unconditional org. `src/banks/b90_expanded.asm` is included last and writes no bytes in the stock build. `tools/gen_file_map.py` reads the guarded org; `docs/file_map.md` was regenerated.
- `NumofTeams` stays 26 (clubs 0-23, AllStarsEast 24, AllStarsWest 25). TeamList, TeamBlocksMap and playoffseats (34 trees, left alone) are asserted. The two demo `randoma` ranges and the Team 1 and Team 2 counts in `setoptions` `.pslim` use `NumofTeams`. Playoff Team 1 stays `lda.w #$0018`. `NewPO` stays `cmp.w #24`.

Next: a new team follows `docs/ADDING_A_TEAM.md`. Bank `$83`'s `$FF` fill is 354 bytes (`unusedFF83`); a record does not fit, so it is assembled in bank `$90` and TeamList points at it. Bank `$87` ends with 9 bytes of `$FF`, so a TeamBlocksMap row needs `assepen` and its fill moved to bank `$90`. `DrawFrame` and `addframe_end` stay together. The `FrameSetTable` header sum checked at startup is `$131D`; leave the sprite-set headers alone.

## Animation and sprite-frame immediates (2026-10-13)

Replaced the remaining raw SPA and SPF immediates with equates that already exist in `src/ram93s.asm`. No new equates were added.

| file | count | symbols |
|---|---|---|
| routines/logic/dopass.asm | 3 | SPAgswing, SPApassf, SPApassb |
| routines/logic/fightinput.asm | 4 | SPAfight, SPAfhigh, SPAflow, SPAfgrab |
| routines/hockey/holdcheck.asm | 5 | SPAflail, SPAHold2 (load and compare), SPAHold, SPAhook2 |
| routines/logic/assstanley.asm | 1 | SPAstanley |
| routines/logic/asseben.asm | 1 | SPAwallright |
| routines/logic/puckshadow.asm | 1 | SPFpuck |
| routines/video/FfoInitTable.asm | 4 | SPFpad+2, SPFpad, SPFpad+1, SPFgloves |
| routines/video/SortObjInitTable.asm | 16 | SPFskatewp (12 player rows), SPFgoal, SPFgoal+1, SPFpuck+1, SPFpuck |
| routines/hockey/updateplayers.asm | 2 | SPFfinjury, SPFPen |
| routines/logic/GetHot.asm | 1 | SPFPen |

38 replacements of immediates that already had equates. The SNES sprite-set frames that have no 68000 SPF base now have their own:

| file | symbol |
|---|---|
| routines/video/checkfo.asm | SPFfaceoff-1 |
| routines/video/setffo.asm | SPFsmallfont |
| routines/video/showzam.asm | SPFzamboni |
| routines/video/showcrowd.asm | SPFcrowd-1 |
| routines/video/addframe.asm, addframe_hi.asm | SPFcrowd |
| routines/logic/GetHot.asm | SPFPen-SPFfinjury, (HotListEnd-HotList)/2+1 |

Still numeric, as in 93 Genesis: `showcrowd.asm` local crowd frames `#$001A` and `#$001D`, and +31 for the horizontal rink.

## Current state (file layout reorganization, 2026-10-12)

Moving to the bank/routine layout: `src/banks/bXX_<name>.asm` (one per bank: `org` + includes in ROM order),
`src/routines/<module>/<Routine>.asm` (one routine per file), `src/data/<category>/<Name>.asm`. Split mechanically with
`tools/split_routines.py migrate <bank> <bankfile>`; every step builds MATCH.

Done: all 16 banks migrated, every step MATCH. Bank files: b80_engine, b81_sfx, b82_sfx_rink, b83_teams, b84_scouting, b85_title_gfx,
b86_sound_driver, b87_player_sprites, b88_title_playoffs, b89_replay_music, b8A_playoffbracket_credits, b8B_opening, b8C_skate_sprites,
b8D_fonts, b8E_gameloop, b8F_frontend. The old `src/<module>_bXX.asm`, `src/frames.asm`, `src/main.asm` and `src/gfx/` are gone.
Rules for new routines: SEGMENT_AGENT.md Layout note. Judgment calls: small tables of code modules stay in `routines/<module>/`
(e.g. jdtab, dirtab, PenaltyList, linelist); text tables (GameLabels, PerLabels, ScoutLabels, PositionNames, RosterLineNames,
AttribMenuSkater/Goalie) moved to `data/text/`; the sprite animation list and tables (SPAList and every SPA*_table) are one file, `data/frames93s.asm`; `unusedFFxx` fills merged
into the routine before; `XxxEnd` end labels stay in their table's file; GameSamples (bank $81) runs into $82, so b82 starts at $82B86C.
Data merges: bank $83 team data (TeamList..playoffseats) is one file `data/teamdata93s.asm` (`data/teams/` gone; Credits moved to
`data/text/Credits.asm`); bank $81 sound is `data/sound/gamesound.asm` (GameSoundUpload, GameSampleDir, GameSamples); bank $86 is
`data/sound/bootsound.asm` (BootSoundUpload, SPCDriver, BootInstruments, BootSampleDir, BootSamples).
Module audit: every `routines/<module>/` file checked against 93G (ref93) then 92G; misplaced ones moved (UnpackNibbles,
WeightedRandomSelect -> middle; DoHiLights, StartHL2, ClearTeamStats, VBjsr -> hockey; updatesound -> video; by judgment HBjsr,
BRKHalt -> hockey (interrupt vectors beside VBjsr), noturn -> logic (playeracc), TeamRosterScreen, RosterG, RosterGoalies -> stats
(93G TeamRosterScreen/GoalieRowText)). SNES-only routines otherwise stay with the module of their 93G caller/neighbour.
Cleanup 2026-10-12: `src/ram93s.asm` comments no longer end by repeating the variable name (208 lines; space-joined forms like `68k d0`, `pflags bit pfgoal` and case-different 68k names like `PassBits` kept on purpose). Signed-compare overflow locals in `src/routines/` renamed `.vN` -> `.neg`, `.neg1`, `.neg2`, ... per routine scope (148 labels, 49 files; no `.vN` left).
Next: the cleanup items below (93G inline comments, generic locals) now work per routine file.

## Previous state (name review)

Name review pass, one file per push; checklist in `docs/name_review_93s.md` (ticked = done). `src/logic_b80.asm` done (all 6060 lines). `src/hockey_b80.asm` done (all 6484 lines). Every file on the checklist is done. Local naming conventions used: register save/restore loops `.save`/`.restore` (d regs) and `.savea`/`.resta` (a regs); 93G local names where the routine matches (e.g. ScoutingReport `.pl/.same/.top/.upd`, setoptions `.nopo/.ii0/.ii1/.iil1/.2/.3/.4`, checkagr `.nojoy/.far`); copy loops named by what they copy (`.clrtext`, `.blocktiles`, `.ronpal`, ...). Rename history goes in `docs/name_map.csv` only. `src/hockey_b8F.asm` and `src/hockey_b88.asm` are done.

# Setup handoff (2026-10-09)

- ROM: LoROM/FastROM ($30), 4 Mbit, header at ROM $7FC0 (`$80FFC0`), checksum $48A5 / complement $B75A.
- Vectors (bank $80): RESET $8000; NMI $80B4 (native and emulation, also COP/ABORT); BRK native $80B2; IRQ $8390.
  Note: NMI shares $80B4 with COP/ABORT; check whether $80B4 is a real NMI handler or an RTI stub with the real NMI elsewhere (e.g. jumped via RAM).
- Quick pass: `python3 tools/disasm65816.py lst/nhlpa93snes.bin src` (do not rerun after edits). 1962 entry labels; ~40 KB (7.6%) decoded as code, ~484 KB left as db. Most code is in $80 (55%) and $8F (27%), $88 (12%). Small decodes in other banks may be false (jsl into data).
- Biggest gap: indirect jumps/jump tables and code only reached through them; every bank except $80/$8F is mostly unresolved.
- asar notes: branch operands must be labels (a literal is not a target address in asar); all operand sizes written with .b/.w/.l; `check bankcross off`, `--fix-checksum=off`.
- Open decisions: whether to split banks into logical files (penalty, teamdata, ...) now or as segments are worked; asset extraction (graphics incbins) tooling. NHL92 Genesis reference: https://github.com/abdulahmad/NHL92Genesis.

## Cleanup progress (source cleanup pass, 2026-10-10)

Branch `cursor/source-cleanup-fbaa`. Every commit builds MATCH. Counts come from `python3 tools/scan_cleanup.py` (after `./build.sh`).

- Byte-dump comments: removed before this pass (d0c7a3d); none left.
- Task 1 (names for addresses): done. ROM pointer immediates and bank bytes use labels (`#label`, `#label>>16`, `#label&$FFFF`), `jml jmlvector`/`jml Opening2`, `unpackbuf` ($7F0000), `mesarea` pointers, team record offsets (Playerdata..ScoreOdds), all 8 DMA channels and register value constants in `src/inc/snes_regs.asm`. HotList's last 428 bytes are a packed tile stream: `RinkLogoTiles`. `ScoutPicMap` is the 93G `FaceOffMap`.
- Task 2 (generic names): done. `;auto: CODE_xxxxxx` traces moved to `docs/name_map.csv`; the 442 `.lN` locals renamed by use; far trampolines named.
- Task 3 (Genesis comments): header comments of 290 routines with a 93G/92G counterpart brought over (93G text first, `SNES:` line after). Every routine has a header comment. Inline 93G comments are not copied (not done).
- Task 4 (file layout): done. The `bankXX_YYYY` slices are regrouped into 93G module files, one file per module per bank: `src/main.asm`, `src/frames.asm`, `src/{hockey,logic,middle,penalty,video,stats,sound,teamdata}_bXX.asm`, and graphics/sprite data in `src/gfx/{graphics,sprites}_bXX.asm`. Each file keeps the original `org` per block (247 blocks), so every byte stays at its address. `src/nhlpa93snes.asm` includes them all. The file-by-block list is in `docs/file_map.md`, the old slice header notes are in `docs/segment_notes.md`, and the `file` column of `docs/name_map.csv` gives the new file. Committed one bank per commit ($81 and $82 together because the GameSamples unit spans both).
- Task 5 (final scan, `tools/scan_cleanup.py`, 92 files):

  | count | before (main) | now |
  |---|---|---|
  | raw address operands | 15 | 4 |
  | raw pointer immediates | 9 | 0 |
  | raw bank-byte immediates | 30 | 0 |
  | noise / byte-dump comments | 0 | 0 |
  | generic `CODE_`/`DATA_` labels | 0 | 0 |
  | `;auto:` traces | 435 | 0 |
  | `.lN` auto locals (refs) | 971 | 0 |
  | globals without a header comment | - | 0 |

Per bank: banks $80-$8F all went through tasks 1-4. Code is mostly in $80, $88 and $8F; the other banks are mostly data in `src/gfx/` and `teamdata_*`.

Left as is (with reason):
- 4 operands `lda.w $0000,y` / `sta.w $0000,y` (in `penalty_b80`/the old bank80_D000/bank84_F000 code). The base really is zero (Y holds a full address), so no label applies.
- Bank-suffixed data/RAM names (`sfx8F`, `PixelRemap83`, `jdtab8F`, `dirtab8F`, `unusedFFxx`). No 93G counterpart is confirmed yet.

What's next:
- Copy the important 93G inline comments, matching them instruction by instruction.
- Rename the remaining generic locals (`.go`, `.set`, `.clr`, `.hi`, `.lo`, `.x`, `.add`, ...) by reading the code. The `.zero` / `.skip` / `.lt` / signed-compare pass is in the 2026-10-14 local-names note.
- Split the larger `hockey_bXX`/`logic_bXX` files further once more routines are identified, and keep `docs/file_map.md` in step with them.

## Routine header rewrite (2026-10-12)
Each `src/routines/<module>/*.asm` opens with one plain-English header comment on the label line (93G file header style):
what the routine does, no `SNES:` second line, no ROM addresses or banks, no stray values. One commit per module folder, MATCH.
- Done: all folders (main, stats, sound, video, middle, penalty, logic, hockey), 448 files.
- Next: none. Inline comments inside the routines were not touched.

### Follow-up check (2026-10-12)
- Unused labels StartSong4, StartSong7, StartSong8, ContinuePlayoffs, unusedEnergyBar: no source references beyond their incsrc lines. Raw ROM search for their addresses as 16/24-bit values found only false hits (SPC700 driver bytes for StartSong7, `jmp Bcheck_rtl` for ContinuePlayoffs). "Unused" kept.
- routines/logic: every routine body read; 24 headers corrected.
- routines/hockey: 67 of the folder's routines read (sampled across sizes and topics, not all); 8 headers corrected. The rest of hockey was not body-checked.
