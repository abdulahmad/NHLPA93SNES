# NHLPA 93 SNES vs NHLPA 93 Genesis: every item the report shows as unmatched

> **Status.** This analysis was made before the renames of the pull request that adds it. Applied there: the roster player routines
> (`UpdateRosterPlayers` ... `ClearRosterName`), `FinalizeTextBuffer`, `GetGoalieCount`, `InitScoutingDisplay`, `PrintScoutRatings`, `remap`,
> `TeamRosterScreen`, `find3d`, and the sound equates `SFXoooh2`, `SFXbglass`, `SFXcrowdcheer`. Rows below that name them still show the old
> 93S name. Not applied: names that would collide with an existing 93S symbol, case-only differences, and the LIKELY / POSSIBLE rows, which
> rest on names and comments (about 30 routine bodies were read) and need a body check first.


Source: `nhl-disasm-report` data for 93S (routine groups tree, `cmp.93G` empty) against NHLPA93Genesis `main`, plus 92G for lineage. Confidence: **EXACT** same item (different spelling, or same name hidden from the report), **LIKELY** same job, **POSSIBLE** related but not one to one, **NO MATCH** SNES-only.

> **Second pass.** The LIKELY rows were body checked (`unmatched_vs_93g_likely.md`), the POSSIBLE rows classified
> (`unmatched_vs_93g_possible.md`) and the name collisions analysed (`unmatched_vs_93g_collisions.md`). Applied (confidence 70% or more):
> `Restart` -> `Opening2`, `PlayoffScreenOpening4` -> `Opening3`, `PlayerNumName` -> `getname`, `PlayerShortName` -> `FormatPlayerNumInitial`,
> `PutDigits2` -> `ConvertByteToDigits`, `revplayeracc` -> `noturn`, `GetPadTeam` -> `seta2`, `TickerTeam` -> `PrintGameInfo`,
> `PrintStringFromList` -> `Fprint_list` (the 92/93G `Fprint` prints a format string), `ScoutNamePos` -> `setoptions_printpos2`,
> `passbits` stays `passbits` (93G is renamed back to it). Swaps: `StatsScreen` is now `StatsReport` (the game stats page) and the old 93S `StatsReport`, the tail of
> `SetHor`, is `SetHor_rink`; `randomd0s` (the A register 0..A-1 variant) is `randomas` and `randomd0sd0` is `randomd0s`.
> Not applied: the PART rows (confidence 60 or less, they keep their own names), `aggress` / `GGSleft` (93G itself uses `aggress` for both
> $73 and $75 in code and comments, so the swap needs a decision), `GetRosterEntry` (holder not verified), `setplayercolors_palbuffer` (the name
> `setplayercolors` is a different SNES routine that calls it), and the bank copies `jdtab8F` / `dirtab8F` (already `<93G name><bank>`).


## Totals

| kind | EXACT | LIKELY | POSSIBLE | NO MATCH |
|---|---|---|---|---|
| routine | 25 | 32 | 39 | 31 |
| equate | 155 | 38 | 52 | 110 |
| label | 28 | 1 | 2 | 13 |

Local labels (`.x`): 408 routines exist in both games; 93S has 3069 local labels, 93G 1983, 1071 share a name; 84 routines have identical local sets. 397 similar-name pairs (weak) are in the JSON.

## Blind spots of the report that explain many "unmatched" rows

* **`rs` variables are skipped.** 93G defines its RAM variables with `name rs.w n` (ram93.asm); the include tree ignores `rs` lines, so 122 SNES equates with the same name as a 93G variable show as unmatched. Another 22 (`a*`/`p*` assignment names) are `name = (*-asstab)/4` expressions in 93G tables93.asm. These are all EXACT.
* **`name equ *` labels are skipped.** 93G `PauseExit` (also `SetRCords`, `nonshift`, `dobar`) is a code label written as `equ *`, so SNES `PauseExit` shows as unmatched.
* **Labels are not compared.** The 21 `PenData*` labels, `AttribRating`, `AttribPrintPct`, `rtss`, `runspeed`, `stopna`, `assreplace` exist in 93G under the same name but the report only matches routine rows.
* **92G-only routines.** `GetPassWord`, `DecodePW`, `PWtoBits`, `PWprint`, `ResetPassWord` exist in 92G; 93G replaced the password screen with backup RAM, so 93S keeps 92 code that 93G dropped.

## Finding: the "Scout*" routines are the setoptions roster players

`ScoutPlayersRun` is called from `setoptions` and animates the two roster players in the team blocks. In 93G that is `UpdateRosterPlayers` (also called from setoptions .wait). The 93S names and comments say "scouting report" (a different screen, `ScoutingReport` / `PrintScoutRatings`). 12 routines are the same code under different names: ScoutPlayersRun = UpdateRosterPlayers, ScoutTeamStep = UpdateRosterPlayer, ScoutPlayerExit = SlideOutRosterPlayer, ScoutNextPlayer = SetupNextPlayer, ScoutPickScript = PickRosterAnim, ScoutScriptPick / ScoutScriptPickG = SkaterRosterAnims / GoalieRosterAnims, ScoutScripts = RosterAnimScripts, ScoutLineOrder = RosterOrderTable, DrawScoutPlayers = UpdateTeamSprites, EraseScoutName = ClearRosterName, ScoutNamePos (inline data).

## Routines (127)

| 93S routine | folder | confidence | 93G | why |
|---|---|---|---|---|
| checkpuckcoll_ccx | hockey | EXACT | checkpuckcoll .ccx | 93G puckstick comment: "d0 = distance^2 (from checkpuckcoll .ccx)": the local label .ccx of checkpuckcoll became its own routine on SNES |
| dirtab8F | logic | EXACT | dirtab | bank copy of dirtab |
| DrawScoutPlayers | hockey | EXACT | UpdateTeamSprites | the "scouting report" player animation in 93S is the setoptions roster-player animation of 93G (sprite list for the two roster players); the SNES names and comments say scouting report, which is a different screen (93G ScoutingReport/PrintScoutRatings) |
| EraseScoutName | hockey | EXACT | ClearRosterName | the "scouting report" player animation in 93S is the setoptions roster-player animation of 93G (erase the 12x2 name area); the SNES names and comments say scouting report, which is a different screen (93G ScoutingReport/PrintScoutRatings) |
| GetRosterEntry89 | hockey | EXACT | GetRosterEntry | a0 = roster record of player d0 of team a2 |
| GoalieCount | logic | EXACT | GetGoalieCount | d0 = goalies on team a2 (93G reads the nibbles of the goalie odds word) |
| InitScoutDisplay | hockey | EXACT | InitScoutingDisplay | same routine, spelled differently |
| jdtab8F | middle | EXACT | jdtab | "a copy for checksso" of the direction table in the bank that uses it |
| MesAreaDone | hockey | EXACT | FinalizeTextBuffer | end a string built in mesarea, a1 = mesarea (length word, pad byte) |
| PauseExit | hockey | EXACT | PauseExit (equ *) | same label in 93G, but defined as `PauseExit equ *` so the report did not see it as a routine |
| PlayoffScreenOpening4 | hockey | EXACT | Opening4 | playoff screen, then scouting report |
| projxy | video | EXACT | find3d | project a rink position (x,y,z) to screen coordinates, off screen when far (93G find3d returns osflag $4E20; SNES OFFSCREEN = $4E20) |
| RemapTiles | video | EXACT | remap | copy tiles with each pixel colour remapped through a table (93G remap, two colour nibbles per byte) |
| ScoutCompare | hockey | EXACT | PrintScoutRatings | print the scouting ratings of team [a0], marking the edge over [a2] = 93G PrintScoutRatings |
| ScoutLineOrder | hockey | EXACT | RosterOrderTable | the "scouting report" player animation in 93S is the setoptions roster-player animation of 93G (order of line slots shown); the SNES names and comments say scouting report, which is a different screen (93G ScoutingReport/PrintScoutRatings) |
| ScoutNextPlayer | hockey | EXACT | SetupNextPlayer | the "scouting report" player animation in 93S is the setoptions roster-player animation of 93G (team palette, x offset -40, next order slot, pick script); the SNES names and comments say scouting report, which is a different screen (93G ScoutingReport/PrintScoutRatings) |
| ScoutPickScript | hockey | EXACT | PickRosterAnim | the "scouting report" player animation in 93S is the setoptions roster-player animation of 93G (best qualifying rating picks the script); the SNES names and comments say scouting report, which is a different screen (93G ScoutingReport/PrintScoutRatings) |
| ScoutPlayerExit | hockey | EXACT | SlideOutRosterPlayer | the "scouting report" player animation in 93S is the setoptions roster-player animation of 93G (erase name, set the slide-out flag (tmflags bit 2)); the SNES names and comments say scouting report, which is a different screen (93G ScoutingReport/PrintScoutRatings) |
| ScoutPlayersRun | hockey | EXACT | UpdateRosterPlayers | the "scouting report" player animation in 93S is the setoptions roster-player animation of 93G (called from setoptions on both); the SNES names and comments say scouting report, which is a different screen (93G ScoutingReport/PrintScoutRatings) |
| ScoutScriptPick | hockey | EXACT | SkaterRosterAnims | the "scouting report" player animation in 93S is the setoptions roster-player animation of 93G (skater (minimum, script) per rating); the SNES names and comments say scouting report, which is a different screen (93G ScoutingReport/PrintScoutRatings) |
| ScoutScriptPickG | hockey | EXACT | GoalieRosterAnims | the "scouting report" player animation in 93S is the setoptions roster-player animation of 93G (goalie (minimum, script) per rating); the SNES names and comments say scouting report, which is a different screen (93G ScoutingReport/PrintScoutRatings) |
| ScoutScripts | hockey | EXACT | RosterAnimScripts | the "scouting report" player animation in 93S is the setoptions roster-player animation of 93G (animation scripts); the SNES names and comments say scouting report, which is a different screen (93G ScoutingReport/PrintScoutRatings) |
| ScoutTeamStep | hockey | EXACT | UpdateRosterPlayer | the "scouting report" player animation in 93S is the setoptions roster-player animation of 93G (team changed -> PickStartingGoalie, slide out, step the animation); the SNES names and comments say scouting report, which is a different screen (93G ScoutingReport/PrintScoutRatings) |
| TeamRoster | stats | EXACT | TeamRosterScreen | Team Roster screen |
| updatepwrplay_clr | penalty | EXACT | updatepwrplay .clrpwrplay | 93G updatepwrplay local label .clrpwrplay (the Rev B edit); SNES made it a routine |
| DisplayStats_sslist | penalty | LIKELY | TeamStatTextTbl | the stat rows DisplayStats shows (93G TeamStatTextTbl) |
| DrawFrame | video | LIKELY | SetSframe | draw a sprite frame made of small pieces (93G SetSframe "draw one sprite frame") |
| FfoInitTable | video | LIKELY | (inline ffo list in defaultsprites) | start positions/frames of rink-scroll objects, inline in 93G defaultsprites |
| findpc_calc | logic | LIKELY | findpc (second goal line half) | findpc per goal line; 93G findpc computes both lines in one routine |
| GetPadTeam | hockey | LIKELY | seta2 | "a2 = the team of the controller that paused" = 93G seta2 "Set a2 to tmstruct of pause joystick" |
| GetPeriodTime_timetab | hockey | LIKELY | (inline table in GetPeriodTime) | period length table 5/10/20 min, 30 s; inline in 93G GetPeriodTime |
| InitSortObjects | video | LIKELY | defaultsprites2 / SprSort | clear sort objects and set up arrows, rink-scroll objects and players from tables (93G defaultsprites2 + SprSort) |
| InitTicker | penalty | LIKELY | InitScores | start the score ticker for the other games (93G InitScores, called from StartGame) |
| MusicCue | sound | LIKELY | song | play a music cue = 93G song / play_sfx_or_music_track with a song number |
| PauseMenu | hockey | LIKELY | Pausemode (.0 / .loop) | draw menu and read pad: 93G Pausemode InitMenuState + .loop |
| PlayerNumName | hockey | LIKELY | getname | mesarea = number and name of roster player d0 of team a2; called from GetNameandAttrib like 93G getname ("NN First Last") |
| PlayerShortName | hockey | LIKELY | FormatPlayerNumInitial | number, first initial and last name ("NN F. Last"); called from ShowGoalBox like 93G FormatPlayerNumInitial |
| Pmenu | hockey | LIKELY | DrawMenuScreen | draw pause menu items with the current one highlighted = 93G DrawMenuScreen / UpdateMenuSelection |
| PrintPerLabel | penalty | LIKELY | PerLabels / PeriodLabelTable | label of the current period (93G PerLabels in tables93, used by printscores1/NewTicker3) |
| PrintStringFromList | penalty | LIKELY | Fprintsmall / AdvanceStringPtr | print string d0 of the String list [a1] (93G Fprintsmall prints it, AdvanceStringPtr only advances) |
| PutDigits2 | middle | LIKELY | ConvertByteToDigits | two digit number as two characters with blank leading zero (93G ConvertByteToDigits) |
| QueueSound | sound | LIKELY | sfx | queue a sound number for the driver = 93G sfx (play_sfx_or_music_track), plus SNES queue handling |
| random | middle | LIKELY | randomd0 (seed step) | 93G randomd0 contains the same LCG (seed*$BB40E62D+1) inline; 93S splits the seed step (random) from the range scaling (randoma) |
| randoma | middle | LIKELY | randomd0 | A = 0..A-1 range random = 93G randomd0 (d0 = range) |
| randomd0sd0 | middle | LIKELY | randomd0s | signed range random (-range < n < range) = 93G randomd0s; 93S name only differs |
| Readjoy12 | middle | LIKELY | ReadJoy1 + ReadJoy2 (ReadJoy) | read pads 1 and 2, d1 = new presses of both = 93G ReadJoy1/ReadJoy2 |
| Restart | hockey | LIKELY | Begin | cold start: reset hardware and RAM, defaults, then title = 93G Begin |
| revplayeracc | logic | LIKELY | noturn (-> playeracc) | 93G noturn "reverse the acc. direction when skating backwards, then falls into playeracc" = revplayeracc |
| ScoutNamePos | hockey | LIKELY | (inline in ClearRosterName / UpdateRosterPlayer) | the "scouting report" player animation in 93S is the setoptions roster-player animation of 93G (where the name is printed); the SNES names and comments say scouting report, which is a different screen (93G ScoutingReport/PrintScoutRatings) |
| setplayercolors_palbuffer | hockey | LIKELY | setplayercolors | converts both teams' colours to the palette buffer (93G setplayercolors "copy in correct color data for each team"); SNES also converts 0BGR->BGR555 |
| setplayercolors_sp | hockey | LIKELY | setplayercolors (.sp) | one team half of setplayercolors |
| sfx8F | sound | LIKELY | sfx | "queue the sound pushed before the call" = 93G sfx (one word on the stack); the 8F suffix is the bank copy |
| ShowRinkRows | video | LIKELY | updatescroll | queue the rink map rows brought on screen by the vertical scroll = 93G updatescroll "queue rink map rows on the dma list" |
| SsoInitTable | video | LIKELY | (inline sso list in defaultsprites) | 93G has the sso start positions as inline data lists in defaultsprites (Xcord/Ycord) |
| TickerNext | penalty | LIKELY | NewTicker2 | go to next ticker game (93G NewTicker2 "goto next ticker") |
| TickerTeam | penalty | LIKELY | PrintGameInfo / PrintTeamNameAndScore | one ticker line: team name and score (93G PrintGameInfo "print team d0's name ... and score d1") |
| unusedEnergyBar | video | LIKELY | dobar / linebar | builds an energy bar of d0 in the message area (93G dobar: draw energy bar for energy level d0) |
| addframe_end | video | POSSIBLE | addframe2 | tail of addframe: clears flip/sprite flags |
| addframe_full | video | POSSIBLE | addframe2 | SNES tile-cache-full exit; 93G has no sprite tile cache |
| addframe_hi | video | POSSIBLE | addframe | high-frame-number path of addframe (SNES frame sets above 255) |
| addteamstat | penalty | POSSIBLE | (inline stat adds in ChkShotStat / loadTeamStruct users) | "add d0 to a team stat for player X's team" is a helper shared by stat code; 93G adds to $xx(a2) inline |
| BitMaskTable | hockey | POSSIBLE | (inline bit mask table of ReadPassBits / GetShifter) | the 16 single-bit masks used by the playoff code; the 68000 uses bset/btst or shifts |
| BRKHalt | hockey | POSSIBLE | Halt (checksum93.asm) / crash | both are the "hang forever" vector handlers; 93G has no BRK vector, its exception vectors are Illinst/AddError/ZeroDiv -> crash |
| CwdFight | logic | POSSIBLE | chkhit / FightFall area (inline) | crowd reaction + push-back on a punch; 93G does this inline in chkhit (SFXhithigh, crowd level +$50) |
| DrawFrameHi | video | POSSIBLE | SetSframe | same for frame numbers in the high range |
| DrawGameSetupBack | hockey | POSSIBLE | GameSetUpMap (setoptions) | draws the game setup backdrop with the NHLPA logo; in 93G part of setoptions (GameSetUpMap graphic) |
| FightFall | logic | POSSIBLE | chkhit (.fall path) / fightinput | loser of the fight gets the other player a PenFighting penalty and may be injured; inline in 93G chkhit |
| IntermissionTick | penalty | POSSIBLE | Intermission (ticker part) | intermission: show next ticker score from time to time, then highlights = part of 93G Intermission/NewTicker |
| nullrtl | hockey | POSSIBLE | rtss | a bare rtl used as do-nothing callback, like 93G rtss |
| nullrtl85 | hockey | POSSIBLE | rtss | bank copy of nullrtl |
| nullrtl89 | penalty | POSSIBLE | rtss | bank copy of nullrtl |
| PauseLeave | hockey | POSSIBLE | Pausemode / PauseExit | leave the pause menu |
| PauseReadJoy | hockey | POSSIBLE | getpzjoy / MenuWaitVblank | wait for a new press of the pad that paused (93G getpzjoy, ProcessInputWithRepeat) |
| PauseResume | hockey | POSSIBLE | Pausemode .loop (HandleMenuInput) | menu choice Resume Game; 93G handles it in menu code (HandleMenuInput) |
| printteamname | penalty | POSSIBLE | PrintTeamNameAndScore / dotb | prints team d3's name at printx and moves down; 93G prints names with dotb and PrintTeamNameAndScore |
| PrintTeamNames | hockey | POSSIBLE | dotb / TeamIcons | print both team names then set up the teams (93G TeamIcons draws the team name bars with dotb) |
| PuckcSpots | hockey | POSSIBLE | (inline table in asspuckc) | spots the puck carrier skates to; unlabelled data in 93G asspuckc |
| RosterG | stats | POSSIBLE | GoalieRowText | the "G" position label of goalie rows |
| RosterGoalies | stats | POSSIBLE | GoalieRowText | goalie row numbers of the roster screen vs the goalie page text |
| SaveRegsStartHL2 | hockey | POSSIBLE | StartHL2 | SNES wrapper that saves the pseudo registers then runs StartHL2 |
| shotsets | logic | POSSIBLE | (inline table in doshot / SetShotMode) | x offset + height per shot direction; 93G keeps this table inline (shotsets-like dc.w data in logic93.asm), unlabelled |
| show_rink | video | POSSIBLE | updatescroll / SetScroll2 | sets the rink scroll from the camera position (Hpos/Vpos); 93G does this in updatescroll and SetScroll2 |
| SortObjInitTable | video | POSSIBLE | (inline table in SprSort / setsortcords) | start positions, frames, assignments of the players, inline in 93G |
| StartSong1 | sound | POSSIBLE | SngGoal ($30, song 1 = home goal) | SNES per-song starter; 93G calls song with the Sng* number directly (no starter routine). Number order follows 93G sound numbers; verify against the SNES cue table |
| StartSong2 | sound | POSSIBLE | SngPeriodStart ($31) | SNES per-song starter; 93G calls song with the Sng* number directly (no starter routine). Number order follows 93G sound numbers; verify against the SNES cue table |
| StartSong3 | sound | POSSIBLE | SngLateGame ($32, third period) | SNES per-song starter; 93G calls song with the Sng* number directly (no starter routine). Number order follows 93G sound numbers; verify against the SNES cue table |
| StartSong4 | sound | POSSIBLE | SngPowerPlay ($33) | SNES per-song starter; 93G calls song with the Sng* number directly (no starter routine). Number order follows 93G sound numbers; verify against the SNES cue table |
| StartSong5 | sound | POSSIBLE | SngFaceoff ($34, mid-period) | SNES per-song starter; 93G calls song with the Sng* number directly (no starter routine). Number order follows 93G sound numbers; verify against the SNES cue table |
| StartSong6 | sound | POSSIBLE | SngTitle ($35) | SNES per-song starter; 93G calls song with the Sng* number directly (no starter routine). Number order follows 93G sound numbers; verify against the SNES cue table |
| StartSong7 | sound | POSSIBLE | SngEOP ($36, unused here) | SNES per-song starter; 93G calls song with the Sng* number directly (no starter routine). Number order follows 93G sound numbers; verify against the SNES cue table |
| StartSong8 | sound | POSSIBLE | SngScout ($37, unused here) | SNES per-song starter; 93G calls song with the Sng* number directly (no starter routine). Number order follows 93G sound numbers; verify against the SNES cue table |
| StartSong9 | sound | POSSIBLE | SngEOP (playoff screen) | SNES per-song starter; 93G calls song with the Sng* number directly (no starter routine). Number order follows 93G sound numbers; verify against the SNES cue table |
| StatsScreen | penalty | POSSIBLE | PlayerStatsScreen / StatsReport | show the game stats until A or a minute passes; 93S already has StatsReport/DisplayStats, so this is the wrapper (93G StatsReport does the same in one routine) |
| vb2_blank | video | POSSIBLE | vb2 | SNES variant of vb2 (palette-fade-only vblank) with the screen forced off |
| VBlank_Cram | video | POSSIBLE | VBlank | SNES vblank: transfer list, scroll, palette; 93G has one VBlank plus screen-specific VBlank_Playoff/_StanleyCup/_TitleScreen/_SetOptions |
| VBlank_CramOnly | video | POSSIBLE | VBlank | SNES vblank that only sends the palette (93G: cramfade/CopyPaletteToCRAM called from VBlank); 93G has one VBlank plus screen-specific VBlank_Playoff/_StanleyCup/_TitleScreen/_SetOptions |
| ClearSprites | video | NO MATCH |  | move all OAM entries off screen; 93G rebuilds the sprite table in setvideo/DumpSprites |
| CopyWords | middle | NO MATCH |  | word copy helper; the 68000 version is a dbf loop inline or DecompressBytecode copy |
| DecodePW | hockey | NO MATCH |  | password screen code exists in 92G (DecodePW, PWtoBits, GetPassWord, PWprint, ResetPassWord) but 93G has no password screen: GameOver saves to backup RAM (EncodePW/ReadPassBits only keep the bits in passbits). Closest 93G: ContinuePlayoffs |
| divs | middle | NO MATCH |  | 65816 software multiply/divide helper; 93G uses the 68000 MULS/MULU/DIVS/DIVU instructions inline |
| divs16 | middle | NO MATCH |  | 65816 software multiply/divide helper; 93G uses the 68000 MULS/MULU/DIVS/DIVU instructions inline |
| divu | middle | NO MATCH |  | 65816 software multiply/divide helper; 93G uses the 68000 MULS/MULU/DIVS/DIVU instructions inline |
| divu16 | middle | NO MATCH |  | 65816 software multiply/divide helper; 93G uses the 68000 MULS/MULU/DIVS/DIVU instructions inline |
| GetPassWord | hockey | NO MATCH |  | password entry/print routine: 92G has it, 93G replaced it with backup RAM saves (BackupRAM_Save/Load); 93S still has passwords |
| HBdefault | video | NO MATCH |  | default H/V-timer handler, SNES only |
| HBjsr | hockey | NO MATCH |  | SNES H/V-timer IRQ stub; the Genesis game uses no horizontal interrupt (93G has only VBjsr) |
| InitPPU | video | NO MATCH |  | SNES PPU/I-O register reset; 93G Begin/SegaInit set up the VDP |
| marktexthi | video | NO MATCH |  | SNES text-layer dirty range |
| marktextlo | video | NO MATCH |  | SNES text-layer dirty range (93G prints straight to VDP) |
| muls16 | middle | NO MATCH |  | 65816 software multiply/divide helper; 93G uses the 68000 MULS/MULU/DIVS/DIVU instructions inline |
| muls32 | middle | NO MATCH |  | 65816 software multiply/divide helper; 93G uses the 68000 MULS/MULU/DIVS/DIVU instructions inline |
| mulu | middle | NO MATCH |  | 65816 software multiply/divide helper; 93G uses the 68000 MULS/MULU/DIVS/DIVU instructions inline |
| mulu16 | middle | NO MATCH |  | 65816 software multiply/divide helper; 93G uses the 68000 MULS/MULU/DIVS/DIVU instructions inline |
| mulu32 | middle | NO MATCH |  | 65816 software multiply/divide helper; 93G uses the 68000 MULS/MULU/DIVS/DIVU instructions inline |
| PWprint | hockey | NO MATCH |  | password entry/print routine: 92G has it, 93G replaced it with backup RAM saves (BackupRAM_Save/Load); 93S still has passwords |
| PWtoBits | hockey | NO MATCH |  | password entry/print routine: 92G has it, 93G replaced it with backup RAM saves (BackupRAM_Save/Load); 93S still has passwords |
| QueueBackmapDMA | video | NO MATCH |  | SNES background map upload (93G transfers through DumpSprites/dodmalist) |
| QueueTextDMA | video | NO MATCH |  | SNES text-layer upload |
| ResetPassWord | hockey | NO MATCH |  | password entry/print routine: 92G has it, 93G replaced it with backup RAM saves (BackupRAM_Save/Load); 93S still has passwords |
| sndqreset | sound | NO MATCH |  | SNES sound command queue to the SPC700; 93G sends commands to the Z80 buffer (UploadCommandBufferToZ80) |
| SPCBootUpload | sound | NO MATCH |  | SPC700 sound program/sample upload; no Genesis counterpart (93G p_initialZ80 loads the Z80 program) |
| SPCGameUpload | sound | NO MATCH |  | SPC700 sound program/sample upload; no Genesis counterpart (93G p_initialZ80 loads the Z80 program) |
| SPCUpload | sound | NO MATCH |  | SPC700 sound program/sample upload; no Genesis counterpart (93G p_initialZ80 loads the Z80 program) |
| VBlank_List | video | NO MATCH | VBlank | SNES one-shot vblank that runs only the transfer list; 93G has one VBlank plus screen-specific VBlank_Playoff/_StanleyCup/_TitleScreen/_SetOptions |
| VBlank_long | video | NO MATCH | VBlank | SNES long-jump entry into VBlank; 93G has one VBlank plus screen-specific VBlank_Playoff/_StanleyCup/_TitleScreen/_SetOptions |
| VBlank_SprPal | video | NO MATCH | VBlank | SNES one-shot vblank that also sends the sprite palettes; 93G has one VBlank plus screen-specific VBlank_Playoff/_StanleyCup/_TitleScreen/_SetOptions |
| VBlank_VScroll | video | NO MATCH | VBlank | SNES one-shot vblank: vertical scroll + transfer list; 93G has one VBlank plus screen-specific VBlank_Playoff/_StanleyCup/_TitleScreen/_SetOptions |

## Equates and variables (355)

### Same name in 93G (144)

`asv`, `BigFontChars`, `bosgames`, `c1playernum`, `c2playernum`, `ChkCnt`, `collflag`, `cont1team`, `cont2team`, `crowdcnt`, `crowdframe`, `crowdlevel`, `crowdstep`, `deltax`, `deltay`, `demoflag`, `DispAttribCtr`, `DMAList`, `DMAlistend`, `evalue`, `ExtraChars`, `faceoffvrcset`, `fodir1`, `fodir2`, `fodropx`, `fodropy`, `fofdata`, `fofdata2`, `fox`, `foy`, `Framercset`, `gameclock`, `gamelevel`, `gamenum`, `glovecords`, `gmode`, `gsp`, `HmAwBonus`, `HomeTeam`, `Hpos`, `Hscroll`, `iflags`, `InjCntDown`, `lastplayer`, `lastsfx`, `lj1`, `lj2`, `lldisp`, `ltplayer`, `ltx`, `lty`, `mesarea`, `nibblebuffer`, `Oldrow`, `oldvcount`, `OOlist`, `OOlistpos`, `OptLine`, `OptPen`, `OptPerlen`, `OptPlayMode`, `padcont`, `PadControlBits`, `palbuffer`, `passdir`, `passReceiverPlayerNum`, `passspeed`, `PBnum`, `PenaltyBufferEnd`, `PenBuf`, `PenCharging`, `Pencntdwn`, `PenCrossChk`, `PenDelay`, `PenEOG`, `PenEOP`, `PenFighting`, `PenFighting2`, `PenGhold`, `PenGoal`, `PenHolding`, `PenHooking`, `PenIcing`, `PenInst`, `PenInterference`, `penmsgtimer`, `PenNoText`, `PenOffsides`, `PenOOP`, `PenRoughing`, `PenRoughing2`, `PenSlashing`, `PenTripping`, `PenWhistle`, `PerTimeTotal`, `PKBonus`, `PlayerScrollCtr`, `PlList`, `pojoy`, `postarts`, `potree`, `potreeteam`, `PPBonus`, `printa`, `printfontset`, `printm`, `printx`, `printy`, `puckcross`, `PushWidthBuf`, `RefCnt`, `RefPen`, `RefStep`, `Satt`, `ScoreSum`, `ScoreSumbytes`, `ScoutingReportTimer`, `screentimer`, `seed`, `SelectedPlayerIdx`, `sflags`, `sflags3`, `shotplayer`, `smallfontchars`, `TempPlOffset`, `TestList`, `ThirdPBonus`, `threat`, `TickerNum`, `tpassbits`, `vbint`, `vcount`, `VertLineScrolling`, `VisTeam`, `Vpos`, `Vscroll`, `wcradiusx`, `wcradiusy`, `WinBits`, `xc1`, `yc1`, `yleader`, `Ylist`, `zamx`

### Other equates (211)

| 93S | file | confidence | 93G | why |
|---|---|---|---|---|
| OFFSCREEN | ram93s.asm | EXACT | osflag | off screen marker $4E20 (93G osflag) |
| OptPlayers | ram93s.asm | EXACT | OptNOP | players option (93G OptNOP, 92 OptNOP) |
| OptTeam1 | ram93s.asm | EXACT | Opt1team | team 1 option (93G Opt1team) |
| OptTeam2 | ram93s.asm | EXACT | Opt2team | team 2 option (93G Opt2team) |
| printfont | ram93s.asm | EXACT | printfontset | font number from the print control code = 93G printfontset (CC_SetFont) |
| puckobj | ram93s.asm | EXACT | puckscnum | object index of the puck (93G puckscnum = 14; SNES index*2) |
| repeatdelay | ram93s.asm | EXACT | repeatdelayframes | ProcessInputWithRepeat frames to the next repeat; 93G name repeatdelayframes |
| ReplayBufferEnd | ram93s.asm | EXACT | replayend | end of the replay area |
| ReplayBufferStart | ram93s.asm | EXACT | replaystart | start of the replay frame area |
| ssox | ram93s.asm | EXACT | Xcord | structure-of-arrays form of the 93G sso objects; x (93G Xcord = 0, first word of an sso object) |
| ssoy | ram93s.asm | EXACT | Ycord | structure-of-arrays form of the 93G sso objects; y (93G Ycord = 2) |
| crowdvol | ram93s.asm | LIKELY | asv | crowd noise volume last sent to the sound driver = 93G asv "analog sound volume (crowd noise)" |
| ffoattr | ram93s.asm | LIKELY | pads / glovestruct attribute (sort object field) | structure-of-arrays form of the 93G ffo objects (pads, ffosize bytes each); attribute |
| ffoframe | ram93s.asm | LIKELY | pads / glovestruct frame (sort object field) | structure-of-arrays form of the 93G ffo objects (pads, ffosize bytes each); frame |
| ffox | ram93s.asm | LIKELY | pads / glovestruct Xpos (object field) | structure-of-arrays form of the 93G ffo objects (pads, ffosize bytes each); x |
| ffoxofs | ram93s.asm | LIKELY | pads / glovestruct VRoffs (object field) | structure-of-arrays form of the 93G ffo objects (pads, ffosize bytes each); x offset of the label sprites |
| ffoy | ram93s.asm | LIKELY | pads / glovestruct Ypos (object field) | structure-of-arrays form of the 93G ffo objects (pads, ffosize bytes each); y |
| ffoz | ram93s.asm | LIKELY | pads / glovestruct Zpos (object field) | structure-of-arrays form of the 93G ffo objects (pads, ffosize bytes each); z |
| GGSleft | ram93s.asm | LIKELY | aggress (goalie glove-left byte $73) | 92 name for the goalie byte $73; 93G aggress = $73 and the puckgoalie .list uses it for goalies |
| notdemo | ram93s.asm | LIKELY | demoflag | $FFFF once a player set up the game, 0 after the demo = inverse sense of 93G demoflag |
| OldXfrac | ram93s.asm | LIKELY | OldXpos+2 (unnamed in 93G) | 93G sort object coordinates are longs; the SNES splits integer and fraction into two word arrays. 93G reads the fraction as 2(a3)-style offsets without a name |
| OldYfrac | ram93s.asm | LIKELY | OldYpos+2 (unnamed in 93G) | 93G sort object coordinates are longs; the SNES splits integer and fraction into two word arrays. 93G reads the fraction as 2(a3)-style offsets without a name |
| OldZfrac | ram93s.asm | LIKELY | OldZpos+2 (unnamed in 93G) | 93G sort object coordinates are longs; the SNES splits integer and fraction into two word arrays. 93G reads the fraction as 2(a3)-style offsets without a name |
| padlast1 | ram93s.asm | LIKELY | lj1 / lj2 | "buttons at the last ReadPads" = 93G lj1/lj2 (joystick debounce last state) |
| passbits | ram93s.asm | LIKELY | passbits | playoff password bits (5 words, no checksum in 93G; 128-bit/8 words on 93S) |
| pchecks | ram93s.asm | LIKELY | team struct $11C(a2) bytes (no name in 93G) | checks per roster player (93G $11C). 93G uses the raw offset; candidate to name it with the SNES name |
| psitem | ram93s.asm | LIKELY | menuitem | pause menu item (92 psitem); 93G menu state is menuitem/menulist/menudraw |
| SFXoverglass | ram93s.asm | LIKELY | SFXbglass | same event in 93G: SFXbglass |
| SFXsaveaway | ram93s.asm | LIKELY | SFXoooh2 / song $D | same event in 93G: SFXoooh2 / song $D |
| SFXsavehome | ram93s.asm | LIKELY | SFXcrowdcheer / song $B | same event in 93G: SFXcrowdcheer / song $B |
| ssoattr | ram93s.asm | LIKELY | attribute (sso object field) | structure-of-arrays form of the 93G sso objects; attribute |
| ssoframe | ram93s.asm | LIKELY | frame (sso object field) | structure-of-arrays form of the 93G sso objects; frame |
| ssoz | ram93s.asm | LIKELY | Zpos (sso object field) | structure-of-arrays form of the 93G sso objects; z |
| tmboxlist | ram93s.asm | LIKELY | team struct $9A(a2) bytes (no name in 93G) | penalty box list (93G $9A(a2)). 93G uses the raw offset; candidate to name it with the SNES name |
| tmfowon | ram93s.asm | LIKELY | team struct faceoffs won (no name in 93G) | unnamed team struct field (offset not named in 93G). 93G uses the raw offset; candidate to name it with the SNES name |
| tmgoals | ram93s.asm | LIKELY | team struct $B4(a2) bytes (no name in 93G) | goals per roster player (93G $B4; goals against for goalies). 93G uses the raw offset; candidate to name it with the SNES name |
| tmlcchoice | ram93s.asm | LIKELY | team struct $2E(a2) (no name in 93G) | line change row chosen (93G logic93 $2E(a2)). 93G uses the raw offset; candidate to name it with the SNES name |
| tmnear | ram93s.asm | LIKELY | team struct $2A(a2) long (no name in 93G) | nearest distance^2 to the puck (assnearest). 93G uses the raw offset; candidate to name it with the SNES name |
| tmpasscomp | ram93s.asm | LIKELY | team struct $12(a2) (no name in 93G) | completed passes (93G passtoa0 "addq.w #1,$12(a2) count passes"). 93G uses the raw offset; candidate to name it with the SNES name |
| TMPDBENCH | ram93s.asm | LIKELY | tmpdst = -2 (bench) | tmpdst state values; 93G documents them in comments (tmpdst: -2 bench / -1 ice / 0+ box) without equates |
| TMPDICE | ram93s.asm | LIKELY | tmpdst = -1 (ice) | tmpdst state values; 93G documents them in comments (tmpdst: -2 bench / -1 ice / 0+ box) without equates |
| TMPDOUT | ram93s.asm | LIKELY | tmpdst = -3 (out of the game) | tmpdst state values; 93G documents them in comments (tmpdst: -2 bench / -1 ice / 0+ box) without equates |
| tmteam | ram93s.asm | LIKELY | team struct $28(a2) (no name in 93G) | team number of the struct (93G setteams/InitTeamStructure store it at $28). 93G uses the raw offset; candidate to name it with the SNES name |
| tmtouch1 | ram93s.asm | LIKELY | team struct $18(a2) (no name in 93G) | touch list: last touch (93G logic93 clears $18/$1A/$1C(a2)). 93G uses the raw offset; candidate to name it with the SNES name |
| tmtouch2 | ram93s.asm | LIKELY | team struct $1A(a2) (no name in 93G) | second last touch. 93G uses the raw offset; candidate to name it with the SNES name |
| tmtouch3 | ram93s.asm | LIKELY | team struct $1C(a2) (no name in 93G) | third last touch. 93G uses the raw offset; candidate to name it with the SNES name |
| Xfrac | ram93s.asm | LIKELY | Xpos+2 (low word of the Xpos long) (unnamed in 93G) | 93G sort object coordinates are longs; the SNES splits integer and fraction into two word arrays. 93G reads the fraction as 2(a3)-style offsets without a name |
| Yfrac | ram93s.asm | LIKELY | Ypos+2 (unnamed in 93G) | 93G sort object coordinates are longs; the SNES splits integer and fraction into two word arrays. 93G reads the fraction as 2(a3)-style offsets without a name |
| Zfrac | ram93s.asm | LIKELY | Zpos+2 (unnamed in 93G) | 93G sort object coordinates are longs; the SNES splits integer and fraction into two word arrays. 93G reads the fraction as 2(a3)-style offsets without a name |
| blankchar | ram93s.asm | POSSIBLE | (blank char constant) | vram tile-base variable of a screen; 93G keeps the equivalents as rs.w ...chars/...cset words (rinkvrcset, crowdvrcset, basetileoffset, energybarchars) |
| carriedy | ram93s.asm | POSSIBLE |  | pucky while carried, for the shot-from y (puckgoalie); no named 93G variable (93G keeps it in the shot data buffer) |
| colorflag1 | ram93s.asm | POSSIBLE |  | cleared by setplayercolors, no reader; check 93G setplayercolors for the same clears |
| colorflag2 | ram93s.asm | POSSIBLE |  | cleared by setplayercolors, no reader |
| d7x1024 | ram93s.asm | POSSIBLE | (d7-scaled values computed inline in updateplayers) | time-step products of d7; 93G multiplies d7 inline each time |
| facefrac | ram93s.asm | POSSIBLE | (facedir fraction, unnamed) | turn fraction of facedir; 93G doplayeracc keeps it in the low half of a long |
| fadein | ram93s.asm | POSSIBLE | palcount / palfadenew (cramfade) | SNES INIDISP brightness fade state; 93G fades CRAM colours with palcount/palfadenew |
| fadeout | ram93s.asm | POSSIBLE | palcount / palfadenew (cramfade) | SNES INIDISP brightness fade state; 93G fades CRAM colours with palcount/palfadenew |
| fightagg | ram93s.asm | POSSIBLE | aggress | fighting aggression; 93G addinfo adds aggress per fighter |
| fobox | ram93s.asm | POSSIBLE | sf3fo / dffaceoff | "faceoff box on screen" ~ 93G dffaceoff (face off sprites on) / sf3fo |
| gravstep | ram93s.asm | POSSIBLE | (d7-scaled values computed inline in updateplayers) | time-step products of d7; 93G multiplies d7 inline each time |
| hlsavebuf | ram93s.asm | POSSIBLE | (StartHL2 .sv save area, unnamed in 93G) | saves the game state (gmode .. ScoreSumbytes) while a highlight plays; 93G does it in StartHL2 .sv without a named buffer |
| impactstep | ram93s.asm | POSSIBLE | (d7-scaled values computed inline in updateplayers) | time-step products of d7; 93G multiplies d7 inline each time |
| INJfight | ram93s.asm | POSSIBLE | (tmpdst value $112C) | tmpdst value for a player injured in a fight; 93G uses the literal in the injury code |
| JOYA | ram93s.asm | POSSIBLE | abut bit | SNES joypad bit masks; 93G has bit numbers ubut/dbut/lbut/rbut/abut/bbut/cbut/sbut for the Genesis pad (SNES has R/L shoulders too) |
| JOYDOWN | ram93s.asm | POSSIBLE | dbut bit | SNES joypad bit masks; 93G has bit numbers ubut/dbut/lbut/rbut/abut/bbut/cbut/sbut for the Genesis pad (SNES has R/L shoulders too) |
| JOYLEFT | ram93s.asm | POSSIBLE | lbut bit | SNES joypad bit masks; 93G has bit numbers ubut/dbut/lbut/rbut/abut/bbut/cbut/sbut for the Genesis pad (SNES has R/L shoulders too) |
| joypad1 | ram93s.asm | POSSIBLE | PadRaw1 / PadRaw2 (Rev B) / Joy1, Joy2 | current controller buttons; 93G reads the hardware (ReadJoy1/2, Rev B PadRaw1/2). Pads 3 and 4 are the SNES multitap |
| joypad2 | ram93s.asm | POSSIBLE | PadRaw1 / PadRaw2 (Rev B) / Joy1, Joy2 | current controller buttons; 93G reads the hardware (ReadJoy1/2, Rev B PadRaw1/2). Pads 3 and 4 are the SNES multitap |
| JOYRIGHT | ram93s.asm | POSSIBLE | rbut bit | SNES joypad bit masks; 93G has bit numbers ubut/dbut/lbut/rbut/abut/bbut/cbut/sbut for the Genesis pad (SNES has R/L shoulders too) |
| JOYSTART | ram93s.asm | POSSIBLE | sbut bit (sbut=7) | SNES joypad bit masks; 93G has bit numbers ubut/dbut/lbut/rbut/abut/bbut/cbut/sbut for the Genesis pad (SNES has R/L shoulders too) |
| JOYUP | ram93s.asm | POSSIBLE | ubut bit | SNES joypad bit masks; 93G has bit numbers ubut/dbut/lbut/rbut/abut/bbut/cbut/sbut for the Genesis pad (SNES has R/L shoulders too) |
| lastframevc | ram93s.asm | POSSIBLE | oldvcount | vcount of the last replay frame shown |
| lcplayer | ram93s.asm | POSSIBLE | (line change player in temp) | SCnum of the player who opened the line change box; 93G keeps it in a temp/pnum field |
| logochars | ram93s.asm | POSSIBLE | energybarchars (also logo/cup sprites) | vram tile-base variable of a screen; 93G keeps the equivalents as rs.w ...chars/...cset words (rinkvrcset, crowdvrcset, basetileoffset, energybarchars) |
| midpercue | ram93s.asm | POSSIBLE | sf3fosong / CheckLateGameSong state | song-trigger bookkeeping of the SNES cue system; 93G triggers songs directly (sf3fosong flag, CheckLateGameSong trigger time) |
| nopuckb | ram93s.asm | POSSIBLE | nopuck (second byte) | second count down next to nopuck |
| p3cue | ram93s.asm | POSSIBLE | sf3fosong / CheckLateGameSong state | song-trigger bookkeeping of the SNES cue system; 93G triggers songs directly (sf3fosong flag, CheckLateGameSong trigger time) |
| pausetimer | ram93s.asm | POSSIBLE | demo timeout in setoptions / Pausemode | frames before a demo pause ends by itself; 93G polls a timeout in a register |
| pentimer | ram93s.asm | POSSIBLE | Pencntdwn / updatepentime frame counter | frames to the next penalty clock second (24 per second = jps); 93G derives it from Vcount/jiffy |
| playoffseatsEnd | data/teamdata93s.asm | POSSIBLE | (playoffseats end) | end label of the playoff seats table |
| refchars | ram93s.asm | POSSIBLE | (ref vram tile bases) | vram tile-base variable of a screen; 93G keeps the equivalents as rs.w ...chars/...cset words (rinkvrcset, crowdvrcset, basetileoffset, energybarchars) |
| refcharshor | ram93s.asm | POSSIBLE | (ref vram tile bases) | vram tile-base variable of a screen; 93G keeps the equivalents as rs.w ...chars/...cset words (rinkvrcset, crowdvrcset, basetileoffset, energybarchars) |
| ReplayBufferPtr | ram93s.asm | POSSIBLE | replaynum (replay record index) | pointer to the next replay frame record; 93G tracks a frame count (replaynum) |
| ronbarrchars | ram93s.asm | POSSIBLE | (Ron Barr tile base in ScoutingReport) | vram tile-base variable of a screen; 93G keeps the equivalents as rs.w ...chars/...cset words (rinkvrcset, crowdvrcset, basetileoffset, energybarchars) |
| scorechars | ram93s.asm | POSSIBLE | basetileoffset (team block tiles) | vram tile-base variable of a screen; 93G keeps the equivalents as rs.w ...chars/...cset words (rinkvrcset, crowdvrcset, basetileoffset, energybarchars) |
| sfhormode | ram93s.asm | POSSIBLE | sfhor (sflags bit) | byte copy of the horizontal-mode flag; 93G uses sflags bit sfhor |
| SPAListEnd | data/frames93s.asm | POSSIBLE | SPAlist end (label) | end of the SPAlist table (93G has SPAlist but no end label) |
| SPFcrowd | data/frames93s.asm | POSSIBLE | (crowd sprite frames) | SNES frame base; the 93G frames93.asm has no SPF equate for this group (frames are in separate graphics: FaceOffSprites, ZamSprites, CrowdSprites) |
| SPFfaceoff | data/frames93s.asm | POSSIBLE | (faceoff sprite frame group) | SNES frame base; the 93G frames93.asm has no SPF equate for this group (frames are in separate graphics: FaceOffSprites, ZamSprites, CrowdSprites) |
| SPFsmallfont | data/frames93s.asm | POSSIBLE | (pad label glyph frames) | SNES frame base; the 93G frames93.asm has no SPF equate for this group (frames are in separate graphics: FaceOffSprites, ZamSprites, CrowdSprites) |
| SPFzamboni | data/frames93s.asm | POSSIBLE | (zamboni frame group) | SNES frame base; the 93G frames93.asm has no SPF equate for this group (frames are in separate graphics: FaceOffSprites, ZamSprites, CrowdSprites) |
| sprflag | ram93s.asm | POSSIBLE | addframe / addframe2 internals | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprframe | ram93s.asm | POSSIBLE | addframe / addframe2 internals | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprx | ram93s.asm | POSSIBLE | addframe / addframe2 internals | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| spry | ram93s.asm | POSSIBLE | addframe / addframe2 internals | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| TeamListEnd | data/teamdata93s.asm | POSSIBLE | (TeamList end) | 93G computes NumofTeams = (*-TeamList)/4 right after the list |
| tickerstart | ram93s.asm | POSSIBLE | TickerNum | TickerNum at the start of the intermission; 93G keeps only TickerNum |
| tmchecks | ram93s.asm | POSSIBLE |  | checks stat; unnamed team stat field. 93G uses the raw offset; candidate to name it with the SNES name |
| TMPDINJ | ram93s.asm | POSSIBLE | (tmpdst bit 12) | injured bit of the box time |
| vcountmark | ram93s.asm | POSSIBLE | oldvcount | vcount snapshot used as an elapsed-time base; 93G oldvcount |
| velstep | ram93s.asm | POSSIBLE | (d7-scaled values computed inline in updateplayers) | time-step products of d7; 93G multiplies d7 inline each time |
| a0 | ram93s.asm | NO MATCH |  | SNES direct-page copy of the 68000 register of the same name (port artefact, not a 93G variable) |
| a1 | ram93s.asm | NO MATCH |  | SNES direct-page copy of the 68000 register of the same name (port artefact, not a 93G variable) |
| a2 | ram93s.asm | NO MATCH |  | SNES direct-page copy of the 68000 register of the same name (port artefact, not a 93G variable) |
| a3 | ram93s.asm | NO MATCH |  | SNES direct-page copy of the 68000 register of the same name (port artefact, not a 93G variable) |
| a4 | ram93s.asm | NO MATCH |  | SNES direct-page copy of the 68000 register of the same name (port artefact, not a 93G variable) |
| attrxflip | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| attryflip | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| backmap | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| BOOTSAMPLESIZE | ram93s.asm | NO MATCH |  | SPC700 sound program addresses/sizes |
| brightness | ram93s.asm | NO MATCH | palcount / palfadenew (cramfade) | SNES INIDISP brightness fade state; 93G fades CRAM colours with palcount/palfadenew |
| charofs | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| charofs2 | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| cheatpads | ram93s.asm | NO MATCH |  | last three pad presses for the unreached .cheat code; no 93G variable |
| cheercnt | ram93s.asm | NO MATCH |  | crowd cheers still to play after a goal; the Genesis drives the cheer through the sfx call and Crowdlevel (no counter variable found) |
| cheervc | ram93s.asm | NO MATCH |  | vcount of the last cheer; no 93G variable |
| cuetimer | ram93s.asm | NO MATCH |  | SNES hardware/port state (PPU, IRQ timer, SPC700 sound queue, 65816 helper); the Genesis sound state is in sound93.asm (Z80_command_buffer etc.) |
| cursong | ram93s.asm | NO MATCH |  | SNES hardware/port state (PPU, IRQ timer, SPC700 sound queue, 65816 helper); the Genesis sound state is in sound93.asm (Z80_command_buffer etc.) |
| d0 | ram93s.asm | NO MATCH |  | SNES direct-page copy of the 68000 register of the same name (port artefact, not a 93G variable) |
| d1 | ram93s.asm | NO MATCH |  | SNES direct-page copy of the 68000 register of the same name (port artefact, not a 93G variable) |
| d2 | ram93s.asm | NO MATCH |  | SNES direct-page copy of the 68000 register of the same name (port artefact, not a 93G variable) |
| d3 | ram93s.asm | NO MATCH |  | SNES direct-page copy of the 68000 register of the same name (port artefact, not a 93G variable) |
| d4 | ram93s.asm | NO MATCH |  | SNES direct-page copy of the 68000 register of the same name (port artefact, not a 93G variable) |
| d5 | ram93s.asm | NO MATCH |  | SNES direct-page copy of the 68000 register of the same name (port artefact, not a 93G variable) |
| d6 | ram93s.asm | NO MATCH |  | SNES direct-page copy of the 68000 register of the same name (port artefact, not a 93G variable) |
| d7 | ram93s.asm | NO MATCH |  | SNES direct-page copy of the 68000 register of the same name (port artefact, not a 93G variable) |
| dmabank | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| dmalen | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| dmasize | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| dmasrc | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| dmavram | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| DPCLEAREND | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| farptr | ram93s.asm | NO MATCH |  | SNES hardware/port state (PPU, IRQ timer, SPC700 sound queue, 65816 helper); the Genesis sound state is in sound93.asm (Z80_command_buffer etc.) |
| GAMESAMPLESIZE | ram93s.asm | NO MATCH |  | SPC700 sound program addresses/sizes |
| goalcue | ram93s.asm | NO MATCH |  | song-trigger bookkeeping of the SNES cue system; 93G triggers songs directly (sf3fosong flag, CheckLateGameSong trigger time) |
| hbint | ram93s.asm | NO MATCH |  | SNES hardware/port state (PPU, IRQ timer, SPC700 sound queue, 65816 helper); the Genesis sound state is in sound93.asm (Z80_command_buffer etc.) |
| hcount | ram93s.asm | NO MATCH |  | SNES hardware/port state (PPU, IRQ timer, SPC700 sound queue, 65816 helper); the Genesis sound state is in sound93.asm (Z80_command_buffer etc.) |
| JMLOPCODE | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| jmlvector | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| JOYL | ram93s.asm | NO MATCH |  | SNES joypad bit masks; 93G has bit numbers ubut/dbut/lbut/rbut/abut/bbut/cbut/sbut for the Genesis pad (SNES has R/L shoulders too) |
| joypad3 | ram93s.asm | NO MATCH |  | current controller buttons; 93G reads the hardware (ReadJoy1/2, Rev B PadRaw1/2). Pads 3 and 4 are the SNES multitap |
| joypad4 | ram93s.asm | NO MATCH |  | current controller buttons; 93G reads the hardware (ReadJoy1/2, Rev B PadRaw1/2). Pads 3 and 4 are the SNES multitap |
| JOYR | ram93s.asm | NO MATCH |  | SNES joypad bit masks; 93G has bit numbers ubut/dbut/lbut/rbut/abut/bbut/cbut/sbut for the Genesis pad (SNES has R/L shoulders too) |
| mula | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| mulb | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| mulcnt | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| mulneg | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| mulres | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| mulsign | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| padnew1 | ram93s.asm | NO MATCH |  | newly pressed buttons; 93G ReadJoy returns them in d0/d1 instead of storing them |
| padvcount | ram93s.asm | NO MATCH |  | SNES reads the pads once per frame; no 93G variable |
| PassWord | ram93s.asm | NO MATCH |  | 92G PassWord char buffer; 93G dropped the password screen (passbits holds only the bits) |
| percue | ram93s.asm | NO MATCH |  | song-trigger bookkeeping of the SNES cue system; 93G triggers songs directly (sf3fosong flag, CheckLateGameSong trigger time) |
| pspeed | ram93s.asm | NO MATCH |  | SNES only (\|Xvel\|+\|Yvel\| after a burst, read by the hit code) |
| pwlength | ram93s.asm | NO MATCH |  | password text size constants; 92G has them, 93G has no password text |
| PWrange | ram93s.asm | NO MATCH |  | password text size constants; 92G has them, 93G has no password text |
| rndb1 | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| rndb2 | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| SattHi | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| sfxmutetime | ram93s.asm | NO MATCH |  | SNES hardware/port state (PPU, IRQ timer, SPC700 sound queue, 65816 helper); the Genesis sound state is in sound93.asm (Z80_command_buffer etc.) |
| SFXshothard | ram93s.asm | NO MATCH |  | SNES sfx cue number with no 93G equate; 93G uses SFXplayerwall/SFXpuckbody etc. for the same events |
| SFXstop | ram93s.asm | NO MATCH |  | SNES sfx cue number with no 93G equate; 93G uses SFXplayerwall/SFXpuckbody etc. for the same events |
| sndbank | ram93s.asm | NO MATCH |  | SNES hardware/port state (PPU, IRQ timer, SPC700 sound queue, 65816 helper); the Genesis sound state is in sound93.asm (Z80_command_buffer etc.) |
| sndlock | ram93s.asm | NO MATCH |  | SNES hardware/port state (PPU, IRQ timer, SPC700 sound queue, 65816 helper); the Genesis sound state is in sound93.asm (Z80_command_buffer etc.) |
| sndptr | ram93s.asm | NO MATCH |  | SNES hardware/port state (PPU, IRQ timer, SPC700 sound queue, 65816 helper); the Genesis sound state is in sound93.asm (Z80_command_buffer etc.) |
| sndqin | ram93s.asm | NO MATCH |  | SNES hardware/port state (PPU, IRQ timer, SPC700 sound queue, 65816 helper); the Genesis sound state is in sound93.asm (Z80_command_buffer etc.) |
| sndqout | ram93s.asm | NO MATCH |  | SNES hardware/port state (PPU, IRQ timer, SPC700 sound queue, 65816 helper); the Genesis sound state is in sound93.asm (Z80_command_buffer etc.) |
| sndqueue | ram93s.asm | NO MATCH |  | SNES hardware/port state (PPU, IRQ timer, SPC700 sound queue, 65816 helper); the Genesis sound state is in sound93.asm (Z80_command_buffer etc.) |
| sndsettle | ram93s.asm | NO MATCH |  | SNES hardware/port state (PPU, IRQ timer, SPC700 sound queue, 65816 helper); the Genesis sound state is in sound93.asm (Z80_command_buffer etc.) |
| SPCBOOTSAMPLES | ram93s.asm | NO MATCH |  | SPC700 sound program addresses/sizes |
| SPCDRIVER | ram93s.asm | NO MATCH |  | SPC700 sound program addresses/sizes |
| SPCDRIVERSIZE | ram93s.asm | NO MATCH |  | SPC700 sound program addresses/sizes |
| SPCINSTR | ram93s.asm | NO MATCH |  | SPC700 sound program addresses/sizes |
| SPCRESUME | ram93s.asm | NO MATCH |  | SPC700 sound program addresses/sizes |
| SPCSAMPLEDIR | ram93s.asm | NO MATCH |  | SPC700 sound program addresses/sizes |
| SPCSAMPLES | ram93s.asm | NO MATCH |  | SPC700 sound program addresses/sizes |
| sprbigslot | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprbigslotend | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprclock | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprcount | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprframetime | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprhflip | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprnodraw | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprox | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sproy | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprpal | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprpattr | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprpieces | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| sprpriority | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprsetofs | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprslot | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprslotend | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprslotlife | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprslottime | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprtile | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| sprtileptr | ram93s.asm | NO MATCH |  | SNES hardware/port state (PPU, IRQ timer, SPC700 sound queue, 65816 helper); the Genesis sound state is in sound93.asm (Z80_command_buffer etc.) |
| sprvflip | ram93s.asm | NO MATCH |  | SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/d1/a3) |
| temp2b | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| textdirtyhi | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| textdirtylo | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| textmap | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| textsave | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| tickervc | ram93s.asm | NO MATCH |  | vcount when the ticker box was last shown; no 93G variable |
| tmp0 | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| tmp1 | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| tmp2 | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| unpackbuf | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| unusedchars | ram93s.asm | NO MATCH |  | 14 tiles after the faceoff box, set but never read |
| vbactive | ram93s.asm | NO MATCH |  | SNES hardware/port state (PPU, IRQ timer, SPC700 sound queue, 65816 helper); the Genesis sound state is in sound93.asm (Z80_command_buffer etc.) |
| vramrow | ram93s.asm | NO MATCH |  | 65816/SNES port scratch, text-layer, DMA-entry or OAM bookkeeping with no Genesis variable |
| xsave | ram93s.asm | NO MATCH |  | SNES hardware/port state (PPU, IRQ timer, SPC700 sound queue, 65816 helper); the Genesis sound state is in sound93.asm (Z80_command_buffer etc.) |

## Global labels inside routine files (44)

| 93S label | confidence | 93G | why |
|---|---|---|---|
| assreplace | EXACT | assreplace | same label (93G assinsert/assreplace) |
| AttribPrintPct | EXACT | AttribPrintPct | same label in 93G stats93.asm |
| AttribRating | EXACT | AttribRating | same label in 93G stats93.asm |
| ChkGoalies_CPG | EXACT | CPgoalie | 93G CPgoalie "see if computer should pull his goalie", entered from ChkGoalies |
| PenDatacharge | EXACT | PenDatacharge | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDatacross | EXACT | PenDatacross | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDatadelay | EXACT | PenDatadelay | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDataEOG | EXACT | PenDataEOG | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDataEOP | EXACT | PenDataEOP | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDatafight | EXACT | PenDatafight | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDatafight2 | EXACT | PenDatafight2 | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDataGhold | EXACT | PenDataGhold | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDataGoal | EXACT | PenDataGoal | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDataHold | EXACT | PenDataHold | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDatahook | EXACT | PenDatahook | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDataice | EXACT | PenDataice | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDataInst | EXACT | PenDataInst | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDataint | EXACT | PenDataint | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDataNoText | EXACT | PenDataNoText | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDataoffsides | EXACT | PenDataoffsides | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDatarough | EXACT | PenDatarough | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDatarough2 | EXACT | PenDatarough2 | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDataslash | EXACT | PenDataslash | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDatatrip | EXACT | PenDatatrip | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| PenDatawhistle | EXACT | PenDatawhistle | same label in 93G tables93.asm (Penaltylist rows); the report only compares routine rows, not labels |
| rtss | EXACT | rtss | same label; 93G has rtss and rtss2 |
| runspeed | EXACT | runspeed | acc speed equate above dirtab |
| StopNA | EXACT | stopna | same label (case) |
| DrawScoutPlayer | LIKELY | AddTeamSpriteFrame | addframe for object X at its position (93G AddTeamSpriteFrame adds the player sprite and a GameSetupMap frame) |
| ReturnGoalies_r | POSSIBLE | ReturnGoalies / CPgoalie | return half of ReturnGoalies; 93G falls into CPgoalie |
| vb2_main | POSSIBLE | vb2 / IRQ7 tail | common vblank tail (vcount, sound tick, fades); 93G vb2 falls into IRQ7 which also counted Vcount in 92 |
| unused008D | NO MATCH |  | SNES bank fill (unused bytes up to the end of a bank/internal header) |
| unused008E | NO MATCH |  | SNES bank fill (unused bytes up to the end of a bank/internal header) |
| unusedFF | NO MATCH |  | SNES bank fill (unused bytes up to the end of a bank/internal header) |
| unusedFF82 | NO MATCH |  | SNES bank fill (unused bytes up to the end of a bank/internal header) |
| unusedFF83 | NO MATCH |  | SNES bank fill (unused bytes up to the end of a bank/internal header) |
| unusedFF84 | NO MATCH |  | SNES bank fill (unused bytes up to the end of a bank/internal header) |
| unusedFF85 | NO MATCH |  | SNES bank fill (unused bytes up to the end of a bank/internal header) |
| unusedFF86 | NO MATCH |  | SNES bank fill (unused bytes up to the end of a bank/internal header) |
| unusedFF87 | NO MATCH |  | SNES bank fill (unused bytes up to the end of a bank/internal header) |
| unusedFF88 | NO MATCH |  | SNES bank fill (unused bytes up to the end of a bank/internal header) |
| unusedFF89 | NO MATCH |  | SNES bank fill (unused bytes up to the end of a bank/internal header) |
| unusedFF8A | NO MATCH |  | SNES bank fill (unused bytes up to the end of a bank/internal header) |
| unusedFF8C | NO MATCH |  | SNES bank fill (unused bytes up to the end of a bank/internal header) |

## Local labels

Routines with the most different local labels (93S locals / 93G locals / shared):

| routine | 93S | 93G | shared |
|---|---|---|---|
| checkpuckcoll | 10 | 11 | 1 |
| ReplayMode | 31 | 17 | 8 |
| clockcont_0 | 12 | 10 | 2 |
| setoptions | 61 | 39 | 31 |
| SPAgready_table | 8 | 13 | 0 |
| SPAgready2_table | 8 | 11 | 0 |
| SPAgglover_table | 8 | 11 | 0 |
| SPAgglovel_table | 8 | 11 | 0 |
| SPAgstickr_table | 8 | 11 | 0 |
| SPAgstickl_table | 8 | 11 | 0 |
| SPAgstackr_table | 8 | 10 | 0 |
| SPAgstackl_table | 8 | 10 | 0 |

Weak name-similarity pairs (e.g. `puckgoalie .b1/.1`, `EvadePC .xa/.x`, `printbig .w0/.0`, `setoptions .vwait/.wait`) are in `unmatched93s.json` with kind `local`; the SNES port mostly renamed numeric locals (`.0`, `.1`) to words and split 68000 fall-through paths into separate labels.
