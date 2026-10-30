# Adding a team

`NumofTeams` is 26 in `src/ram93s.asm`: clubs 0-23, AllStarsEast 24, AllStarsWest 25. That file is included before the team data, so the count stays a constant. The stock bytes stay the same while the count is 26.

## Tables

| What | Where | One entry | Check |
|---|---|---|---|
| TeamList | `src/data/teamdata93s.asm` | `dd` long pointer, 4 bytes | `(TeamListEnd-TeamList)/4 == NumofTeams` |
| team record | after TeamList, or in bank $90 when it does not fit | one record (the shortest, Ottawa, is 531 bytes; Boston is 680) | the TeamList entry points at its label |
| Teamblocksmap | `src/banks/b87_sprites_refs.asm` | 36 bytes, a 9 x 2 tile block | `(TeamBlocksMapEnd-Teamblocksmap)/36 == NumofTeams` |
| playoffseats | `src/data/teamdata93s.asm` | 16 team numbers | `(playoffseatsEnd-playoffseats)/16 == 34` |

Leave 34 alone. playoffseats is 34 trees, not the team count.

`src/routines/hockey/setoptions.asm` already takes the count from `NumofTeams`: the two demo ranges that feed `randoma`, and the Team 1 and Team 2 counts in `.pslim`.

Leave these alone. The number is the same and the meaning is not the team count:

- `#$001A` as the roster stride (`tmgoals`, `pchecks`, `tmboxlist`, and the routines that step by it), and `#$001A` used as a coordinate, crowd frame, goalie distance, scouting byte, impact, wall object, `pnothing`, or a saved register.
- Playoff Team 1 stays `lda.w #$0018`.
- `NewPO` stays `cmp.w #24`. A team number of 24 or higher is clamped to team 23.

## Bank $83

Bank $83 ends with 354 bytes of `$FF`. `unusedFF83`, at the end of `src/routines/logic/assgoalietopuck.asm`, is that fill.

A new `dd` in TeamList needs the same number of `$FF` bytes deleted from that fill, so the bank does not grow and the banks after $83 stay put. One pointer is 4 bytes, so delete 4 bytes of the fill.

A full record does not fit in 354 bytes. Add bank $90 (see "Adding bank $90" below), assemble the record there, and point the TeamList entry at its label.

## Bank $87

Teamblocksmap is in the middle of bank $87. The bank ends with 9 bytes of `$FF` (`unusedFF87`), so one 36-byte row does not fit.

`assepen` is the last routine in `src/banks/b87_sprites_refs.asm` (127 bytes, then the 9-byte fill). `asstab` reaches it with `dd assepen`, so the routine and its fill can move into bank $90 (see "Adding bank $90" below). `SetSframe`, just after the map, uses `jmp.w addframe_end`, so those two stay together in bank $87. The next bank's org pads the gap.

Bank $8B ends on the `rtl` of `skatetopuckinit` and has no spare fill.

## Sprite-set headers

`src/routines/main/Start.asm` sums the word at offset 2 of every long pointer in `FrameSetTable` and hangs unless that sum is `$131D`. Those words are the sprite-set headers. Leave them alone when a set moves.

## Where a new bank goes

Bank $80 keeps an unconditional `org`. Each bank file after it orgs only when `pc()` has not already reached that address. On the stock tree the PC arrives exactly there, so the org is skipped and the bytes match. If a bank grows, a later org must not rewind over the new bytes. A 65816 instruction that straddles a 32 KB bank does not run. Keep each routine inside one bank.

## Adding bank $90

The retail ROM is 512 KB (banks $80-$8F), and the default build has no bank $90. To add it:

1. Create `src/banks/b90_expanded.asm` with the guarded org:

   ```
   ; Bank $90: expanded. Overflow team records and routines moved out of a full bank.
   if pc() < $908000
   	org $908000
   endif
   ```

2. Add `incsrc "banks/b90_expanded.asm"` as the last bank include in `src/nhlpa93snes.asm`, after `b8F_frontend.asm`.
3. Put the overflow team record, or the routine moved out of a full bank (such as `assepen` from bank $87), in that file. Code that reaches it from another bank needs a long address (`dd`, `jsl`/`jml`).
4. Build with `npm run build:retail`. The image is now larger than 512 KB, so `tools/patchHeader.js` pads it with `$00` to 1 MB, sets the size byte to `$0A`, and stores the new checksum (see Header below). The image no longer matches the retail ROM, so the build ends with a verify MISMATCH; that is expected.


## Header

`src/header/snes_header.asm` keeps size byte `$09`, complement `$B75A`, checksum `$48A5`. `tools/build.js` assembles with `--fix-checksum=off`, then runs `tools/patchHeader.js` on the image (`output/retail/nhlpa93snes.sfc`).

On the retail image the patch writes nothing, so `npm run build:retail` still matches. Running it on `nhlpa93retail.sfc` leaves `$48A5` and `$B75A`.

On a larger image the patch pads with `$00` to the next SNES size, sets the size byte, and stores the checksum and its complement, little-endian. It checks that the finished file sums to the word it stored.

| size byte | image |
|---|---|
| `$09` | 512 KB |
| `$0A` | 1 MB |
| `$0B` | 2 MB |
| `$0C` | 4 MB |

The checksum is the low 16 bits of the sum of every byte, including the checksum pair. A complement pair always adds `$01FE`. Cartridge type stays ROM only. SRAM size stays 0. There is no cart save RAM.

## check bankcross

Leave `check bankcross off`. Turning it on fails the stock assemble: asar 1.91 deprecates it and reports `Ebank_border_crossed` on the in-game sample `incbin`, which runs from bank $81 into $82. `b82` starts where that stream ends. No other stock bank crosses. Do not use `bankcheck half` or `bankcheck full`.
