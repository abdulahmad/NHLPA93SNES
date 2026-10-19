# 93S -> 93G source-format alignment (read-only analysis)

Legend: P = priority (H/M/L), E = effort (S <1h, M ~half day, L > day), B = byte-safe? (Y = no ROM change if
the build still says MATCH; V = Y but verify the assembler accepts the form; C = case/semantic care).
Assembler differences that must stay: 93G SNASM68K `dc.b/dc.w/dc.l`, `Label` with no colon, `.0` locals no colon,
single-quoted strings, `\1` macro args; 93S asar `db/dw/dd`, `Label:`, `.x:` , double quotes, `<name>` macro args.
Those are NOT recommendations. Only the structure/style choices are.

## 0. Quick map of what corresponds to what
| 93G | 93S |
|---|---|
| teamdata93.asm | src/data/teamdata93s.asm (+ data/text/Credits.asm for the Credits block) |
| frames93.asm | src/data/frames93s.asm |
| tables93.asm (one file, all tables) | src/tables93s.asm (equates only) + routines/tables/*.asm (7 files) + data/text/*.asm (15) |
| graphics93.asm (one file, incbin + equates) | data/gfx/*.asm (52 files, one per block) |
| sound93.asm (data part) | data/sound/bootsound.asm, gamesound.asm |
| ram93.asm | ram93s.asm (+ Pen*/SFX*/CC consts live there too) |
| macros/genesis93.mac | macros/snes93.mac |
| PAttribColumns / GAttribColumns | data/text/AttribMenuSkater.asm / AttribMenuGoalie.asm |
| PlayerPositionText | data/text/PositionNames.asm |
| bfasciicon | data/gfx/BigFontIndex.asm |
| PerLabels, linelist, GameLabels, Credits | same names (PerLabels.asm, linelist.asm, GameLabels.asm, Credits.asm) |
| PauseText/StartGameText/... (menus) | routines/hockey/Pmenu.asm .mlist/.mlist2 (SNES design differs) |

## 1. Data tables: how they are written

### 1.1 Strings: 93G uses the String macro; 93S writes `dw N / db "..."` by hand
- 93G: tables93.asm:150-222 `String 'Period Over'`, :241 `linelist String 'Sc1'`, :257 `PerLabels String '1',18`;
  teamdata93.asm:141 `StringB 'All Stars East'`; Credits :1517-1579 `String '...'`, `String -1`.
  Control bytes are passed as extra args: hockey93.asm:431 `String CC_SetMap,3,CC_SetX,0,...`.
- 93S: 233 hand-counted `dw N` length words across 33 files, e.g. routines/tables/PenaltyList.asm
  (`dw 13 / db "Period Over"`), routines/tables/linelist.asm (`dw 5 / db "Sc1"`), data/text/PerLabels.asm,
  PositionNames.asm, GameLabels.asm, AttribMenuSkater/Goalie.asm, RosterLineNames.asm, ScoutLabels.asm,
  Credits.asm, PasswordText.asm, GoalBoxText.asm, CreditsBlank.asm; routines/hockey/Pmenu.asm .mlist/.mlist2,
  setoptions.asm (:475,:569-588), getname.asm, GetPassWord.asm, penalty/NewTicker3.asm:46, StartHL2.asm,
  stats/RosterG.asm, DisplayStats.asm, logic/SetLCmode2.asm.
- Only 3 files use the 93S `%String` macro already: data/teamdata93s.asm, text/HandedTextTbl.asm, text/StatusTextTbl.asm.
- Rec 1.1 (P=H, E=M, B=Y): replace `dw N` + `db "..."` pairs by `%String("...")` everywhere the length word
  counts itself + text (the macro already does this). Where a string embeds control bytes, the macro takes only
  one quoted arg: extend it (see 4.x) or keep `dw ?e-?l` form. Mixed text+bytes (`db $BF,$0F,$03,"GOAL!",...`)
  = macro variant with a raw `<bytes>` argument. A build MATCH proves every length was right. Leave
  the PenaltyList `dw 2 / dw $050A,...` (empty-text) entries as `%String("")` -> yields `dw 2` (same bytes).
- Rec 1.2 (P=M, E=S, B=Y): add `CC_*` control-code equates for the SNES print codes and use them in the strings
  as 93G does (ram93.asm:139-146 `CC_SetMap..CC_SetMapAndPosition`). 93S has none (grep `CC_` empty); raw
  `$BF,$0F,$03` (GoalBoxText.asm), `$FF,2,14` (PasswordText.asm), `$12-$14` (PerLabels.asm: "st","nd","rd" tiles).
  Needs a per-code decode from printbig/print first; name them like 93G where the code is the same.

### 1.2 Quote style, wrapping, comment placement
- 93G: single quotes, `dc.b<TAB>`, trailing comment at col 36, wrapped comment continues in same column
  (tables93.asm:3-6, 15-20). Table label comment on the label line (`Penaltylist  ;Penalty number = word offset...`).
  Blank line between logical blocks inside a table (cd0 tables93.asm:15-24: four 16-word blocks separated by blanks).
- 93S: double quotes (asar requirement, ignore); comment style on the label line is the same, BUT:
  - routines/tables/cd0.asm has no block separation and a one-line comment; 93G's long explanation (4 blocks of
    16 words, byte offset $00/$20/$40/$60, time $0c/7/7/3) is missing. Rec 1.3 (P=M,E=S,B=Y): copy the 93G
    comment and the blank lines between blocks (cd0 data is identical).
  - 93G `asstab` lines have a meaningful per-entry comment; 93S has just `; 0`..`; 1C` index (asstab.asm). See 2.1.
  - Data row wrapping: G uses 8 words/line (cd0), 16 bytes (bfasciicon, one row per 16 chars with a char-header
    comment line above each row, tables93.asm:225-240); S BigFontIndex.asm has the same bytes with no per-row
    char header comment. Rec 1.4 (P=L,E=S,B=Y): add the `;  - -! " # $...` header comments over each BigFontIndex row
    and (optional) write bytes as signed decimal like G (-73) or keep hex (G is mixed) - leave hex.
- Hex-case: G is mixed (teamdata/frames upper `$7020`, tables lower `$010c`, `$050a`); S is uppercase, 4-digit
  words (`$000A`) while G writes `$a`/`$0a`. No change recommended (L, would be churn).

### 1.3 Local-label style in tables
- 93G: numeric `.0 .1 ...` for index-ordered tables (frames: `.0-.7`, team: `.0`), words elsewhere
  (`.defl .defr .wingl .wingr .center`, `.l0-.l4`, team `.pld .pad .tn .ls .sr .godds .ta`). docs/conventions.md says
  "Data tables indexed by number stay numeric".
- 93S: team records use the SAME locals (`.0 .pad .sr .godds .ls .pld .tn .ta`, same order) - aligned.
  sublist.asm `.defl .defr .wingl .wingr .center` - aligned.
  DIFFERENT: frames93s.asm uses `.d0 .. .d7` (every table, ~60x8 labels) where 93G uses `.0 .. .7`;
  PlayoffTreeSetup.asm uses `.lvl0..4` where G has `.l0..4` (tables93.asm:302-352).
  Rec 1.5 (P=M,E=S (sed),B=Y): `.d0..d7` -> `.0..7` in frames93s.asm; `.lvlN` -> `.lN` in PlayoffTreeSetup.asm
  (both only referenced inside their file; `.0:` is already legal asar - 139 uses in routines/).
- 93G macro-driven frame tables use the `.a/.aoff/.b/.boff` + `set` helper idiom to step frame numbers
  (frames93.asm:59-67). 93S expands every pair to `SPFx+N` literals (frames93s.asm:110-137) with the row wrapped
  at ~8 pairs and a second `dw` line. Rec 1.6 (P=L,E=L,B=Y): optional, not worth porting the helper idiom
  (asar `!a` defines or `.a = ` aren't `set`-able the same way); leave as is. The `+N` literal form is clearer.
- Frames table header: G `SPAx_table:  ;table of the animation above: direction offsets, flags, frame/time lists`
  then `.t` offsets with `; 0x0012` byte-offset comments; S header `;SPAx frames by direction` and
  `dw .dN-X_table  ; direction N`, `dw 0 ; attributes` (more explicit than G). Rec 1.7 (P=L,E=S,B=Y): keep S text,
  but add G's per-direction `; 0xNNNN` offset comment? NO - low value; skip.

### 1.4 Team record contents (the closest pair)
- Same structure, same label order. Diffs:
  1. G has the field-key legend comment blocks (teamdata93.asm:60-111: `;q - scoring odds offense row...`,
     `;s - shooting ... ;m - aggressiveness`) above `.sr` and `.pld`, plus a `;qreb,hvxx,skpd,cfgo` and
     `;-G,LD,RD,LW,-C,RW,XA,00` column header. S has only the short `; qreb,hvxx,skpd,cfgo` (Boston/ASE) and
     `;unwl,sodp,chga,eytm` (ASE only; none in the other 24 records) and `.ls:` header comment only on ASE.
     Rec 1.8 (P=M,E=S,B=Y): copy the legend once at the top of teamdata93s.asm (one place, not 26x) and the
     column header comments to every record's `.sr/.ls/.pld` as G does in AllStarsEast (G repeats them only in ASE).
  2. G: `.godds` on its own line then `dc.b 197,34`; S `.godds:\tdb 197,34` on the label line (all but ASE).
     G `.sr` then `hex2 ...` on the next line; S `.sr:\t%hex2(...)`. Rec 1.9 (P=L,E=S,B=Y): put data on the next line
     (S already does this for ASE `.godds`, `.ls:`, `.pld:`).
  3. Player lines: G `Player 'Patrick Roy',<tab>335F,AFFF,0100,FFFF` (names padded with tabs so ratings align, no `$`);
     S `%Player("Patrick Roy", $335F,...)` single space. Rec 1.10 (P=L,E=S,B=Y): column-align ratings with tabs
     like G (cosmetic). Macro `$`-prefix requirement is an asar limit (the macro could prepend `$` via
     `$<w1>` - see 4).
  4. List terminator: G `dc.b 0,2`; S `dw 2 ; end of the player list (empty name)`. Same bytes. Align to
     `db 0,2` (P=L,B=Y) or keep (commented is better); optional.
  5. Record header comment: G `Boston  ;team record: Boston (BOS)`; S `Boston: ;team 0`. Rec 1.11 (P=L,E=S,B=Y):
     use G's wording `team record: Boston (BOS)`; S index (team N) is nice - append: `;team record: Boston (BOS), team 0`.
     S also has `; ---- Boston ----` banner lines (blank-line + banner) which G does not. Remove banners (P=L).
  6. Odd-name padding: G Player macro pads odd-length names (even alignment, 68k); S Player has no pad (SNES is
     byte aligned). Behaviour difference, not style; macro comment should say so.
- playoffseats: G blocks of 8 trees separated by blank lines, no per-row comment; S per-row `; tree N`, no blank
  lines, `playoffseatsEnd` + `assert .../16 == 34`. Rec 1.12 (P=L,E=S,B=Y): fine to keep S assert; add blank line
  every 8 trees like G (cosmetic). Count differs (G 34 rows? both 34) - same.

## 2. Offset usage: label-base expressions, `*-Table` equates

### 2.1 asstab / Penaltylist per-entry equates (the main one)
- 93G tables93.asm:27-93: each entry is preceded by `name = (*-asstab)/4` (e.g. `ascore = (*-asstab)/4  ;celebrating
  a goal`), `Pen... equ (*-Penaltylist)` (:98-141); the equate is defined right before its entry, in entry order,
  with the explanation on the equate. The equates live in the table file (not ram93.asm) because they are
  assembled in one pass (CONTRIBUTING 93G sec. 3).
- 93S: values hardcoded: src/tables93s.asm 22 equates `abench = $0B` etc., in NO particular order (abench, apuckc,
  anearest, ashoot, adefd, awingd, acenterd, aeben, aepen, apenalty, ascore, afight...), 6 names missing that G has
  (adefo, awingo, acentero, astanley, adopen, pshad), and ram93s.asm:762-784 `PenEOP = $02 ... PenDelay = $2C`
  (23 equates) away from routines/tables/PenaltyList.asm, which has `; $02 period over` comments. asstab.asm:
  `dd assdefo ; 1`.
- Rec 2.1 (P=H, E=M, B=Y, verify V): move to the table files, ordered by index, with the name and meaning on the
  equate line, as G:
    `adefo = (asstab_entry-asstab)/4` is not expressible with `*` in asar -> use `pc()`:
    `ascore = (pc()-asstab)/4 ;celebrating a goal` placed right before `dd assscore`. Problem: asar needs the equate
    to be known when code `lda.w #ascore` is assembled (forward use) -> asar evaluates `=` with labels on pass 2;
    verify that `lda.b/lda.w #name` sizes are explicit (they are: `.w`/`.b` suffix everywhere) and the .sym
    stays identical. Fallback if asar rejects: keep the numeric equates but order them by index, add the missing six,
    move into the tables files, and add `assert pc()-asstab == 4*ascore` check after each entry.
  Same for PenaltyList: `PenEOP = (pc()-PenaltyList)` before `dw PenDataEOP-PenaltyList` (G tables93.asm:98+),
  with G's wording ("2 period over").
- Rec 2.2 (P=M, E=S, B=Y): rename `PenaltyList` -> `Penaltylist` (G/92 spelling; CONTRIBUTING: copy 92's
  capitalisation exactly). Case-only rename: asar labels are case-sensitive; do it with sed over src/ and record
  in docs/name_map.csv. Also graphics labels, see 5.

### 2.2 TeamList
- G teamdata93.asm:41 `NumofTeams = (*-TeamList)/4` right after the list, then `Playerdata=0 ... GoalieOdds=10`.
- S teamdata93s.asm:8 `NumofTeams = 26` hardcoded at the top, before the list, plus `TeamListEnd:` + `assert`.
- Rec 2.3 (P=M, E=S, B=Y): put the equates AFTER the list: `TeamListEnd:` label then
  `NumofTeams = (TeamListEnd-TeamList)/4`; delete the assert (it becomes tautological). If asar can't forward-resolve
  uses of NumofTeams in earlier banks, keep value+assert. See 3.

### 2.3 PlayoffTreeSetup / sublist / playoffseats
- G `.l1 dc.b 16+8-1  ;level 1: 16+8 team blocks`, `.l4 16+8+4+2+1-1` expression form; S `db 24` plain with comment
  (`;gamelevel 1: 24 team slots`). Rec 2.4 (P=L,E=S,B=Y): use `db 16+8` / `16+8+4` expressions. Note S/G differ in
  semantics (S counts N, G N-1) - keep S's value, express as the sum.
- S has one `PlayoffTreeSetup` row per `db` group with `(graphics, x)` comments - fine.
- G sublist rows use `0+1,8+1,...`: S sublist.asm is identical (aligned).

### 2.4 frames: SPA and SPF numbers
- G frames93.asm: `SPAgready = *-SPAlist` placed immediately before `SPAgready_table:` (8 per animation
  = 61 tables); `SPFskate = SPFskatewp+40  ; 41 (...)` chained.
- S frames93s.asm:5-64 `SPAgready = $0002  ; SPAgready $2: ...` hardcoded in a header block (about 60) and
  asserted per table (`assert SPAgready_table-SPAlist == SPAgready`, ~60 lines); SPF :68-103 `SPFskate = 41 ; 41`
  hardcoded (the comment repeats the value; in some it is a different number: `SPFgdive = 643 ; 519`, the comment
  is the 93G value).
- Rec 2.5 (P=H, E=M, B=Y, verify V): define `SPAx = SPAx_table-SPAlist` (or `pc()-SPAlist` placed before the
  table label) next to each table, delete the header block and the 60 asserts; same issue as 2.1 (forward uses in code
  before bank 82). If forward refs fail, keep the header but order it the same as the table order and keep the asserts.
- Rec 2.6 (P=M, E=S, B=Y): rewrite SPF to chain like G (`SPFskate = SPFskatewp+40`) wherever the SNES gap equals
  G's, and mark exceptions with `; 93G 519` (the existing comment). Add `assert` for the final value. E.g. SPFturnl..
  SPFfinjury follow G exactly; SPFgdive/SPFSiren/SPFcatch/.. are "laid out differently" (frames93s.asm:65-67): keep
  numeric values for those and chain the rest.
- Header comment in S frames93s.asm line 3-4 is ungrammatical/orphaned ("named and ordered like the 68000 /
  frame tables"; "one lower than (no SPFreplay frame)" - missing noun `93G`). Fix text (P=L).

### 2.5 Misc numbers
- gfx data uses hardcoded `assert End-Start == $9C0` (BigFontTiles.asm, NHLPALogo.asm: `$45A`, SpriteSetN:
  `$7C0+896*32`). G uses `equ Sprites+$3574A` (graphics93.asm:52-58 `FrameDataOff`, `SprDataBytes`, `HotList`). S
  HotList.asm `incbin "...HotList.bin":0..$44A` + RinkLogoTiles at $44A: slice offsets hardcoded.
  Rec 2.7 (P=L, E=S, B=Y): name the sizes: `HotListSize = $44A` etc.; fine as is, low.
- AttribMenu*: `dw $0000,$0000 ; bit mask, rating column` repeated 20x; G uses `$0000,0 ;status`/`,$a ;rating` with a
  named comment per type (status/energy/handed/weight/fighting). Rec 2.8 (P=M, E=S, B=Y): equates for the four
  column offsets (`attribjmp` offsets: status 0, energy 2, handed 4, weight 6, fighting 8, rating $A) -
  ram93s already has attribjmp? (check) - and G's trailing comments (`;status`, `;handed`, `;weight`, `;fighting`).

## 3. Ordering of definitions inside files (93S vs 93G)
| file (93G -> 93S) | 93G order | 93S order | change to make |
|---|---|---|---|
| teamdata93.asm -> teamdata93s.asm | `null`, TeamList, NumofTeams, Playerdata..GoalieOdds, records (ASE, ASW, Boston..Winnipeg, Washington), playoffseats, Credits | Playerdata..GoalieOdds, NumofTeams, TeamList(+TeamListEnd), records (same order), playoffseats (Credits in data/text) | move offsets+NumofTeams after TeamList (rec 2.3). `null` entry is 68k-specific (a $310 zero long) - no S counterpart, fine. Header comment (first 6 lines of G) -> S has a 1-line comment: copy G's record-layout paragraph (P=M,B=Y) |
| frames93.asm -> frames93s.asm | SPF block (chained), SPAlist, then per table: `SPAx = *-SPAlist` + `SPAx_table` | SPA block (hardcoded), SPF block (hardcoded), SPAlist, tables each followed by `assert` | SPF before SPA/SPAlist; per-table equate before table (rec 2.5, 2.6) |
| tables93.asm -> tables93s.asm + routines/tables | cd0, asstab(+a*/p* equates inline), Penaltylist(+Pen* equates inline), PenData*, bfasciicon, linelist, PlayerPositionText, PerLabels, sizetab, sublist, priolist, PlayoffTreeSetup, PAttribColumns, GAttribColumns, menus | tables93s.asm: a*/p* equates unordered (equates before, no tables); Pen* in ram93s.asm; tables in per-file | order by entry, co-locate with table (rec 2.1). G has `sizetab` (sprite size code to tile count) - 93S has none (check: grep) |
| graphics93.asm -> data/gfx/*.asm | maps and sprites in one file; `Sprites` then equates (Spritetiles, FrameDataOff, SprDataBytes, HotList) | one file each; HotList in its own file | no reorder needed; keep as is |
| ram93.asm -> ram93s.asm | ports -> structure offsets -> rs vars -> sound consts at end (CC_ codes inside print vars) | HW regs, WRAM, then "constants at the end" (Pen*, SFX*, bits, anim offsets) | G puts Pen*/a* equates in tables93.asm (not RAM); move 93S Pen* (ram93s:762-784) and a* to tables as in 2.1; CC_ equates belong next to printfontset |
| sound93.asm -> data/sound | driver, Z80 blob + incbins; equates (sizes, slots) first | boot/game upload blobs; SPC sample dir | n/a |
Within a team record order is identical in both (`.0 .pad .sr .godds .ls .pld .tn .ta`). Team order in the file is
identical (ASE, ASW, Boston ... Winnipeg, Washington). Check: in S Winnipeg precedes Washington (team 23 then 22) - same as G
(G has Winnipeg line 1366 then Washington 1420). Aligned.

## 4. Macros: genesis93.mac vs snes93.mac
| 93G macro | 93S macro | notes |
|---|---|---|
| `VmInc` (VDP auto-increment) | none | 68k/VDP specific; no counterpart needed. (Note: G uses it once-in-name only, middle93.asm:702 as a comment) |
| `String` (up to 6 args, `dc.b \1..\6`, patches length byte via `org`) | `%String(text)` single arg | 93S must support multiple args / raw bytes to remove hand-written `dw N / db ...`: add `%String2(text, bytes)` or use `"<a>",<b>` var-arity not possible in asar -> define `StringB`-like variants |
| `StringB` (same as String, duplicated, for names) | none | G uses it for team names; S uses `%String` for `.tn/.ta` - fine. Only needed if a distinct name is wanted. (P=L: no action) |
| `HEX2` (`dc.w $\1,$\2,$\3,$\4`, no `$` in call) | `%hex2($w1,$w2,$w3,$w4)` (`db` big-endian bytes, `$` in call) | Names match 93G case-insensitively but case differs: G `HEX2`/uses `hex2`; S `hex2`. Rec 4.1 (P=L): none; but make S take plain hex without `$` to match call sites? asar can't paste `$` in `<w1>`: `$<w1>` works inside macro body, so `%hex2(7020,00D6,9999,9099)` is possible (B=Y,E=S) -> call sites then read exactly like G |
| `PLAYER` (name, 4 words; pads odd name to even, length byte at offset 1 `dc.b 0,len`) | `%Player(name,w1..w4)` (`dw ?e-?l` length word, no pad) | Same name, different layout rule explained in comment; add the "no padding (SNES)" note (P=L). Rec 4.2 (P=L,E=S,B=Y): `$<w1>` prefix like 4.1 so `%Player("Patrick Roy",335F,AFFF,0100,FFFF)` aligns with G text |
| `PIX1`/`PIX` (goalie save odds, 4-digit base-4 per byte) | none | G defines but no call sites in source (rg: 0 uses). 93S lists raw odds bytes? (no table found). Rec 4.3 (P=L): do not port; if a goalie-odds table exists in S, check whether it's raw `db` and adopt PIX if decoded identically |
| - (macro-less, `include`) | `snes_regs.asm`, `incsrc` | n/a |
- Neither side uses macros for code (only data). 93S macros are all lowercase-first (`hex2`) except `Player`,`String` - fine.
- Missing in 93S that the data needs: (a) raw-byte-aware String; (b) `CC_*` equates; (c) possibly a `PadByte`/REV
  pattern - not applicable (one revision).

## 5. Label / header naming style
### 5.1 Table labels (same spelling as 93G where the same item exists)
| 93G | 93S | action (all byte-safe, case/naming only) |
|---|---|---|
| Penaltylist | PenaltyList | rename to `Penaltylist` (92 spelling, CONTRIBUTING sec 2). P=M |
| PlayerPositionText | PositionNames | rename to PlayerPositionText. P=M |
| PAttribColumns / GAttribColumns | AttribMenuSkater / AttribMenuGoalie | rename (same job: attribute column list); P=M. Check name_map for a recorded reason first |
| bfasciicon | BigFontIndex | rename to bfasciicon? S table differs in content (SNES tile indexes) - same role "indexed by ascii-$20"; P=L |
| Teamblocksmap | TeamBlocksMap | G spelling: `Teamblocksmap`. P=L (case-only) |
| GameSetUpMap | GameSetupMap | `GameSetUpMap` (G); P=L |
| Framermap (used) / FramerMap (label line 34) | FramerMap | G is inconsistent; keep S |
| Arrowsmap | PlayoffBracketMap | rename? S content differs (arrow graphics as map); P=L |
| EASNmap | EASNMap, EASNLogoMap | P=L |
| RefMap2 | RefsMapHor | P=L, different content |
| SmallFontMap/BigFontMap/RonBarrMap/IceRinkMap/HotList/Credits/GameLabels/PerLabels/linelist/sublist/priolist/asstab/cd0 | same | aligned |
| TeamList, AllStarsEast, etc., Playerdata... | same | aligned |
- Teams: G list uses plain city names (LongIsland); 93S same. Aligned.
- S file/section "SNES:" prefixes in label comments (`;SNES: big font index...`, PositionNames, RosterLineNames,
  BigFontIndex...) vs 93G rule "no 'only in 9x' tags; 'New in 94/95:' allowed only in file/section headers". Rec 5.1
  (P=L,E=S,B=Y): remove the `SNES:` prefix from label comments (the repo is already 93S); keep "New in 93S" wording
  only in headers if needed.
- Banner comments: S bootsound/gamesound/teamdata/frames use `; ---- Name ----` banners between records;
  G uses a blank line only (and `;====` banner only for sections, see CONTRIBUTING sec 5). Rec 5.2 (P=L,E=S,B=Y): drop
  the `; ---- X ----` banners (teamdata 26x, sound files).
- Colons: G: no colon on labels (SNASM). S: colon (asar-required style per CONTRIBUTING 9). Leave.
- Trailing comment style: G `;comment` with no space after `;` mixed with `; 0x0012`; S 1266 lines `;x` without
  space and 2794 with `; `. Pick one: G convention is `;` immediately followed by text for line-end comments in
  tables (e.g. `dc.l rtss ;`...) and `; 0x...` for hex notes. P=L.

### 5.2 File header comments
- G: every file starts with a tab-led prose header describing contents and relations (tables93.asm:1-6,
  teamdata93.asm:1-6, frames93.asm:1-6, graphics93.asm:1-7, sound93.asm, print93.asm; check_comments.py enforces).
- S: data/text, data/gfx and routines/* files have NO file header (first line is the label + comment), e.g.
  data/gfx/BigFontMap.asm, text/PerLabels.asm; routines/tables/*.asm likewise (comment on the label line).
  Bank files have a 1-line header (`; Bank $83: teams. Files in ROM order`); tables93s.asm/ram93s.asm/macro/
  main have headers; teamdata93s/frames93s have 1-4 lines.
- Rec 5.3 (P=M, E=M, B=Y): CONTRIBUTING (G) sec 4 "Every file starts with a header that says what is in it" -
  add a 2-3 line header to teamdata93s.asm and frames93s.asm (copy G's), and to each data/text and data/gfx file
  (can be generated: first line `; <label comment>` is already there, so a header duplicates it - allowed to skip for
  single-label one-routine files; ADD for multi-label files like frames/teamdata/bootsound/gamesound/sublist).
  Also have `check_comments.py` flag a missing header in files with >1 label.

## 6. File and folder naming / organisation
| aspect | 93G | 93S | recommendation |
|---|---|---|---|
| source layout | one file per module (`<module>93.asm`, 17 files, ~29k lines) included from hockey93.asm in ROM order with address ranges on include lines | one file per routine (471) under `routines/<G module>/`, bank includes `banks/bXX_<name>.asm` in ROM order | keep (SNES-specific benefit: bank cross-check), but make `routines/<area>/` map 1:1 to G module names: present dirs decompress, hockey, logic, main, middle, penalty, print, sound, sram, stats, tables, video. G modules without a dir: checksum, graphics, menu, teamdata, frames, ram, tables (data lives in `data/`). Add `routines/menu/` only if menu code exists |
| data naming | `Extracted/Graphics/*.map.jim, *.anim, Pals/*.pal; Sound/*.bin; Text` (gitignored) | `data/*.chr.pak/.map.pak/.snesmap/.snespal/.brr/.spc700/.bin` (committed) and `src/data/{gfx,text,sound}/*.asm` PascalCase | already documented (data/README.md). Keep extension scheme; align file stems with G (BigFont/SmallFont/Framer/FaceOff/IceRink/Refs/RonBarr/Title1/EASN/TeamBlocks already match; S `Ref.chr.pak`/`RefHor` vs G `Refs.map.jim`/`Refs2` - rename `Ref*` -> `Refs*`? P=L) |
| file name case | G modules lowercase+93; | routines: label-named; MIXED case: `Opening2.asm` vs `asstab.asm`, `getname.asm`, `holdplayer.asm` (label Holdplayer), `puckIChk.asm` (label PuckIChk), `Readjoy1.asm` (label ReadJoy1), `Readjoy2.asm` | rename 4 mismatched files to their exact label case (holdplayer.asm -> Holdplayer.asm, puckIChk.asm -> PuckIChk.asm, Readjoy1/2.asm -> ReadJoy1/2.asm); update bank incsrc; P=L,E=S,B=Y. Note case-insensitive FS (Windows build.ps1) |
| two-label files | n/a | 22 routine files hold >1 label (ResetClock, UpdateTeamSprites, getpde, ChkGoalies, ReturnGoalies, ass*(8), avdgoal, chk4pass, dostop, skateto, SetScore, reenergizeteam, AttribFighting(3), AttribWeight...) | matches "falls through into the next keeps both" (file_map.md); fine |
| asm style for data in routines | tables (cd0, asstab, sublist...) live in `routines/tables/` | `data/text`, `data/gfx` | OK; `routines/tables/` files (cd0, asstab, linelist, priolist, sublist, PenaltyList, PlayoffTreeSetup) are what G calls tables93.asm. Consider moving them under `src/data/tables/` (P=L,E=S,B=Y - include path only) since text tables of the same kind (PerLabels, PositionNames) already sit in data/text. Alternatively move linelist/PositionNames/PerLabels into one place |
| tools | `tools/*.js|py|sh`, camelCase names + `93` suffix (`extractAssets93.js`, `verifyRom.js`, `verify_all.sh`, `diffrom.py`, `fixopcodes.js`) | `tools/*.py|sh|ps1`, snake_case (`gen_file_map.py`, `scan_cleanup.py`, `split_routines.py`, `strip_noise.py`, `patchheader.py`, `snesgfx.py`, `disasm65816.py`), `tools/bin/asar` | Keep language per platform. Align the *verification entry-point* name: G `tools/verify_all.sh` vs S `./build.sh` at root (+ Makefile + build.ps1). Rec 6.1 (P=M,E=S,B=Y): add `tools/verify_all.sh` wrapper (calls build.sh, compares vs retail) and mention in CONTRIBUTING checklist; `check_comments.py` already shared name. One-shot conversion scripts (split_routines.py, strip_noise.py, scan_cleanup.py, patchheader.py, disasm65816.py) are migration tooling: move to `tools/migrate/` or delete once done (P=L) |
| root files | README, CONTRIBUTING, package.json, docs/ | + PROMPT.md, SEGMENT_AGENT.md, START_HERE.md at root, HANDOFF in docs | G root has only README/CONTRIBUTING. Rec 6.2 (P=M,E=S,B=Y): move PROMPT.md, SEGMENT_AGENT.md, START_HERE.md under `docs/` (e.g. `docs/agent/`) or delete (agent hand-off artefacts); update README links |
| docs naming | lowercase-kebab `file-formats.md modding.md retail-vs-reva.md sound-system.md conventions.md`, history in `docs/history/` (`name_map.csv`, `name_review_93.md`) | UPPER_SNAKE (`ADDING_A_TEAM.md`, `HANDOFF.md`), snake (`file-map.md`, `name_review_93s.md`, `unmatched_vs_93g*.md`, `discovery93snes.md`, `segment_notes.md`), `name_map.csv` flat | Rec 6.3 (P=M,E=S,B=Y): create `docs/history/`; move `name_map.csv`, `name_review_93s.md` there (G paths), rename `ADDING_A_TEAM.md` -> `adding-a-team.md` (docs README/CONTRIBUTING links), `file-map.md` -> `file-map.md`, `HANDOFF.md` -> archive or `docs/history/handoff.md`; add `docs/conventions.md` equivalent (naming lineage + local label style - mostly copy G's, replace asar bits). Keep `unmatched_vs_93g*.md` in `docs/history/` |
| name_map schema | `old,new,source` (rename log, ~per rename) | `address,name,auto_name,source,note,file` (address inventory, not a rename log) | They are different artefacts. Rec 6.4 (P=M,E=M,B=Y): add a G-style `docs/history/name_map.csv` (old,new,source) for 93S renames and rename the current address table to `docs/history/symbol_map.csv` (CONTRIBUTING step "Record every rename in the name history file" cannot be done with the current schema). Update tools/gen_file_map.py reader |
| output/build | `output/{retail,reva,revb}`, ROMs `nhlpa93retail.bin` next to src | `output/nhlpa93snes.sfc/.sym`, `lst/nhlpa93snes.bin` (baseline) | S: rename `lst/nhlpa93snes.bin` -> reference ROM like G root `nhlpa93snes.sfc` or `reference/`; `lst/` looks like listing dir - P=L, build-script change |
| top-level asm | `hockey93.asm` (builds everything) | `nhlpa93snes.asm` | G name = module list; S fine |
| extracted/ | `Extracted/` gitignored, regenerated by `extractAssets93.js` | `data/` committed, produced by `tools/snesgfx.py` | document in data/README (exists); keep |

## 7. Prioritised plan (all byte-safe; build.sh must still print MATCH)
1. (H, M) 2.1 Order and relocate `a*/p*` and `Pen*` equates into the tables (per-entry `= (pc()-Table)/N`), add 6 missing
   assignment names; pull asstab/PenaltyList comments to G wording. Biggest style gap vs G; verify asar forward use.
2. (H, M) 1.1 Convert all `dw N / db "text"` pairs to `%String(...)` (233 hand counts; MATCH proves it). Extend macro for
   embedded control bytes; add CC_* equates (1.2).
3. (H, M) 2.5/2.6 Generate SPA equates from tables (`SPAx = SPAx_table-SPAlist` next to each) and chain SPF; drop ~60 asserts.
4. (M, S) 2.3 TeamList: `NumofTeams` computed after the list; equates after TeamList as in G; 1.8 add key-legend comment blocks.
5. (M, S) 1.5 `.d0-.d7` -> `.0-.7`, `.lvlN` -> `.lN`; 1.3 cd0 comment/blocks; 1.4 BigFontIndex row headers.
6. (M, S) 2.2/5.1 case/name renames: Penaltylist, PlayerPositionText, PAttribColumns/GAttribColumns (+ name_map entries).
7. (M, M) 5.3 file headers for multi-label data files; remove `; ---- X ----` banners; strip `SNES:` prefixes.
8. (M, S) 6.1-6.4 docs/history layout, root cleanup, name_map schema, verify_all.sh wrapper.
9. (L, S) 4.1/4.2 macro call-site alignment (`$` in macro), player column alignment, filename case fixes.
10. (L, L) optional: PlayoffTreeSetup sum expressions, HotList size equates, relocate routines/tables to data/tables.

## 8. Items found while reading (not formatting, worth a look)
- data/text/GoalBoxText.asm ends with `unusedFF8F: db 0,0,0,0,0` (ROM-end zero fill inside a text file; belongs in its own
  file or bank footer).
- G linelist reads 'PP1'/'PP2'; S 'Pw1'/'Pw2' (real ROM difference - keep, but note in comment).
- frames93s.asm header comments have dropped words ("one lower than (no SPFreplay...)", "from )" at line ~62).
- ram93s.asm:762-784 PenIcing/PenOffsides etc. lack comments (G has them on the `Pen*` equates).
- G macro PIX/PIX1 has zero call sites in G (dead macro); do not port.
