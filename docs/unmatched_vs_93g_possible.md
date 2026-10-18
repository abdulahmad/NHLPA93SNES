# POSSIBLE verdicts (490 rows)

{'RELATED': 61, 'PART': 14, 'NOT': 414, 'SAME(collision)': 1}

Locals (397) are name-similarity only: NOT, conf 15. Nothing reaches confidence >= 70 except StatsScreen -> StatsReport (collision, needs swap).

|kind|name|verdict|93G|new|conf|reason|
|-|-|-|-|-|-|-|
|equate|fadeout|RELATED|palcount / palfadenew (cramfade)||25|SNES-specific or different representation; SNES INIDISP brightness fade state; 93G fades CRAM colours with palcount/palfadenew|
|equate|fadein|RELATED|palcount / palfadenew (cramfade)||25|SNES-specific or different representation; SNES INIDISP brightness fade state; 93G fades CRAM colours with palcount/palfadenew|
|equate|sprflag|RELATED|addframe / addframe2 internals||25|SNES-specific or different representation; SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/|
|equate|sprframe|RELATED|addframe / addframe2 internals||25|SNES-specific or different representation; SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/|
|equate|sprx|RELATED|addframe / addframe2 internals||25|SNES-specific or different representation; SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/|
|equate|spry|RELATED|addframe / addframe2 internals||25|SNES-specific or different representation; SNES sprite engine variable (OAM + VRAM tile cache); 93G addframe passes frame/x/y in registers (d0/|
|equate|impactstep|RELATED|(d7-scaled values computed inline in updateplayers)||25|SNES-specific or different representation; time-step products of d7; 93G multiplies d7 inline each time|
|equate|velstep|RELATED|(d7-scaled values computed inline in updateplayers)||25|SNES-specific or different representation; time-step products of d7; 93G multiplies d7 inline each time|
|equate|gravstep|RELATED|(d7-scaled values computed inline in updateplayers)||25|SNES-specific or different representation; time-step products of d7; 93G multiplies d7 inline each time|
|equate|d7x1024|RELATED|(d7-scaled values computed inline in updateplayers)||25|SNES-specific or different representation; time-step products of d7; 93G multiplies d7 inline each time|
|equate|pausetimer|RELATED|demo timeout in setoptions / Pausemode||25|SNES-specific or different representation; frames before a demo pause ends by itself; 93G polls a timeout in a register|
|equate|fobox|RELATED|sf3fo / dffaceoff||25|SNES-specific or different representation; "faceoff box on screen" ~ 93G dffaceoff (face off sprites on) / sf3fo|
|equate|tickerstart|RELATED|TickerNum||25|SNES-specific or different representation; TickerNum at the start of the intermission; 93G keeps only TickerNum|
|equate|joypad1|RELATED|PadRaw1 / PadRaw2 (Rev B) / Joy1, Joy2||25|SNES-specific or different representation; current controller buttons; 93G reads the hardware (ReadJoy1/2, Rev B PadRaw1/2). Pads 3 and 4 are t|
|equate|joypad2|RELATED|PadRaw1 / PadRaw2 (Rev B) / Joy1, Joy2||25|SNES-specific or different representation; current controller buttons; 93G reads the hardware (ReadJoy1/2, Rev B PadRaw1/2). Pads 3 and 4 are t|
|equate|carriedy|RELATED|None||25|SNES-specific or different representation; pucky while carried, for the shot-from y (puckgoalie); no named 93G variable (93G keeps it in the sh|
|equate|lcplayer|RELATED|(line change player in temp)||25|SNES-specific or different representation; SCnum of the player who opened the line change box; 93G keeps it in a temp/pnum field|
|equate|p3cue|RELATED|sf3fosong / CheckLateGameSong state||25|SNES-specific or different representation; song-trigger bookkeeping of the SNES cue system; 93G triggers songs directly (sf3fosong flag, CheckL|
|equate|midpercue|RELATED|sf3fosong / CheckLateGameSong state||25|SNES-specific or different representation; song-trigger bookkeeping of the SNES cue system; 93G triggers songs directly (sf3fosong flag, CheckL|
|equate|ReplayBufferPtr|RELATED|replaynum (replay record index)||25|SNES-specific or different representation; pointer to the next replay frame record; 93G tracks a frame count (replaynum)|
|equate|colorflag1|RELATED|None||25|SNES-specific or different representation; cleared by setplayercolors, no reader; check 93G setplayercolors for the same clears|
|equate|colorflag2|RELATED|None||25|SNES-specific or different representation; cleared by setplayercolors, no reader|
|equate|vcountmark|RELATED|oldvcount||25|SNES-specific or different representation; vcount snapshot used as an elapsed-time base; 93G oldvcount|
|equate|lastframevc|RELATED|oldvcount||25|SNES-specific or different representation; vcount of the last replay frame shown|
|equate|facefrac|RELATED|(facedir fraction, unnamed)||25|SNES-specific or different representation; turn fraction of facedir; 93G doplayeracc keeps it in the low half of a long|
|equate|nopuckb|RELATED|nopuck (second byte)||25|SNES-specific or different representation; second count down next to nopuck|
|equate|fightagg|RELATED|aggress||25|SNES-specific or different representation; fighting aggression; 93G addinfo adds aggress per fighter|
|equate|sfhormode|RELATED|sfhor (sflags bit)||25|SNES-specific or different representation; byte copy of the horizontal-mode flag; 93G uses sflags bit sfhor|
|equate|pentimer|RELATED|Pencntdwn / updatepentime frame counter||25|SNES-specific or different representation; frames to the next penalty clock second (24 per second = jps); 93G derives it from Vcount/jiffy|
|equate|tmchecks|RELATED|None||25|SNES-specific or different representation; checks stat; unnamed team stat field. 93G uses the raw offset; candidate to name it with the SNES na|
|equate|logochars|RELATED|energybarchars (also logo/cup sprites)||25|SNES-specific or different representation; vram tile-base variable of a screen; 93G keeps the equivalents as rs.w ...chars/...cset words (rinkv|
|equate|refcharshor|RELATED|(ref vram tile bases)||25|SNES-specific or different representation; vram tile-base variable of a screen; 93G keeps the equivalents as rs.w ...chars/...cset words (rinkv|
|equate|refchars|RELATED|(ref vram tile bases)||25|SNES-specific or different representation; vram tile-base variable of a screen; 93G keeps the equivalents as rs.w ...chars/...cset words (rinkv|
|equate|ronbarrchars|RELATED|(Ron Barr tile base in ScoutingReport)||25|SNES-specific or different representation; vram tile-base variable of a screen; 93G keeps the equivalents as rs.w ...chars/...cset words (rinkv|
|equate|scorechars|RELATED|basetileoffset (team block tiles)||25|SNES-specific or different representation; vram tile-base variable of a screen; 93G keeps the equivalents as rs.w ...chars/...cset words (rinkv|
|equate|blankchar|RELATED|(blank char constant)||25|SNES-specific or different representation; vram tile-base variable of a screen; 93G keeps the equivalents as rs.w ...chars/...cset words (rinkv|
|equate|hlsavebuf|RELATED|(StartHL2 .sv save area, unnamed in 93G)||25|SNES-specific or different representation; saves the game state (gmode .. ScoreSumbytes) while a highlight plays; 93G does it in StartHL2 .sv w|
|equate|JOYSTART|RELATED|sbut bit (sbut=7)||25|SNES-specific or different representation; SNES joypad bit masks; 93G has bit numbers ubut/dbut/lbut/rbut/abut/bbut/cbut/sbut for the Genesis p|
|equate|JOYRIGHT|RELATED|rbut bit||25|SNES-specific or different representation; SNES joypad bit masks; 93G has bit numbers ubut/dbut/lbut/rbut/abut/bbut/cbut/sbut for the Genesis p|
|equate|JOYLEFT|RELATED|lbut bit||25|SNES-specific or different representation; SNES joypad bit masks; 93G has bit numbers ubut/dbut/lbut/rbut/abut/bbut/cbut/sbut for the Genesis p|
|equate|JOYDOWN|RELATED|dbut bit||25|SNES-specific or different representation; SNES joypad bit masks; 93G has bit numbers ubut/dbut/lbut/rbut/abut/bbut/cbut/sbut for the Genesis p|
|equate|JOYUP|RELATED|ubut bit||25|SNES-specific or different representation; SNES joypad bit masks; 93G has bit numbers ubut/dbut/lbut/rbut/abut/bbut/cbut/sbut for the Genesis p|
|equate|JOYA|RELATED|abut bit||25|SNES-specific or different representation; SNES joypad bit masks; 93G has bit numbers ubut/dbut/lbut/rbut/abut/bbut/cbut/sbut for the Genesis p|
|equate|INJfight|RELATED|(tmpdst value $112C)||25|SNES-specific or different representation; tmpdst value for a player injured in a fight; 93G uses the literal in the injury code|
|equate|TMPDINJ|RELATED|(tmpdst bit 12)||25|SNES-specific or different representation; injured bit of the box time|
|routine|BRKHalt|PART|Halt||60|both hang forever, but BRKHalt is the SNES BRK vector handler; 93G has no BRK vector|
|routine|vb2_blank|PART|vb2||55|SNES variant of vb2 with screen forced off; keep as variant|
|routine|VBlank_Cram|PART|VBlank||50|SNES vblank, 93G has one VBlank plus screen-specific ones|
|routine|VBlank_CramOnly|PART|VBlank||45|palette-only SNES vblank|
|routine|shotsets|NOT|(inline table in doshot / SetShotMode)||20|inline in 93G, no separate routine to name against|
|routine|CwdFight|NOT|chkhit / FightFall area (inline)||20|inline in 93G, no separate routine to name against|
|routine|FightFall|NOT|chkhit (.fall path) / fightinput||20|inline in 93G, no separate routine to name against|
|routine|nullrtl|PART|rtss||50|bare rtl used as callback; rtss is a shared rts branch target, not the same use|
|routine|printteamname|RELATED|PrintTeamNameAndScore||35|prints one team name|
|routine|addteamstat|NOT|(inline stat adds in ChkShotStat / loadTeamStruct users)||20|inline in 93G, no separate routine to name against|
|routine|show_rink|PART|updatescroll||50|scroll half of updatescroll|
|routine|BitMaskTable|NOT|(inline bit mask table of ReadPassBits / GetShifter)||20|inline in 93G, no separate routine to name against|
|routine|SaveRegsStartHL2|PART|StartHL2||55|SNES wrapper saving pseudo registers then running StartHL2|
|routine|addframe_hi|PART|addframe||45|SNES high-frame path|
|routine|PauseReadJoy|RELATED|getpzjoy||45|similar purpose, different mechanism|
|routine|PauseResume|RELATED|HandleMenuInput||30|menu choice|
|routine|PauseLeave|RELATED|PauseExit||30|leave pause menu|
|routine|SortObjInitTable|NOT|(inline table in SprSort / setsortcords)||20|inline in 93G, no separate routine to name against|
|routine|DrawFrameHi|PART|SetSframe||40|high-range frame variant|
|routine|PrintTeamNames|RELATED|dotb/TeamIcons||35|prints both team names then sets up teams|
|routine|nullrtl85|PART|rtss||40|bank copy of nullrtl|
|routine|StartSong6|NOT|SngTitle||20|SNES-only starter wrapper (cursong, SPC upload, MusicCue); 93G calls song with the Sng* number directly|
|routine|StartSong7|NOT|SngEOP||20|SNES-only starter wrapper (cursong, SPC upload, MusicCue); 93G calls song with the Sng* number directly|
|routine|addframe_end|PART|addframe2||40|tail of addframe|
|routine|DrawGameSetupBack|PART|GameSetUpMap||40|part of setoptions on 93G|
|routine|nullrtl89|PART|rtss||40|bank copy of nullrtl|
|routine|StartSong8|NOT|SngScout||20|SNES-only starter wrapper (cursong, SPC upload, MusicCue); 93G calls song with the Sng* number directly|
|routine|StartSong9|NOT|SngEOP||20|SNES-only starter wrapper (cursong, SPC upload, MusicCue); 93G calls song with the Sng* number directly|
|routine|StartSong1|NOT|SngGoal||20|SNES-only starter wrapper (cursong, SPC upload, MusicCue); 93G calls song with the Sng* number directly|
|routine|StartSong2|NOT|SngPeriodStart||20|SNES-only starter wrapper (cursong, SPC upload, MusicCue); 93G calls song with the Sng* number directly|
|routine|StartSong3|NOT|SngLateGame||20|SNES-only starter wrapper (cursong, SPC upload, MusicCue); 93G calls song with the Sng* number directly|
|routine|StartSong4|NOT|SngPowerPlay||20|SNES-only starter wrapper (cursong, SPC upload, MusicCue); 93G calls song with the Sng* number directly|
|routine|StartSong5|NOT|SngFaceoff||20|SNES-only starter wrapper (cursong, SPC upload, MusicCue); 93G calls song with the Sng* number directly|
|routine|StatsScreen|SAME(collision)|StatsReport|StatsReport|85|wrapper that shows the whole game-stats page, same job as 93G StatsReport; name held by 93S routine that is really the SetHor rink-draw tail, so swap needed|
|routine|IntermissionTick|PART|Intermission||40|ticker part of Intermission|
|routine|addframe_full|NOT|addframe2||15|SNES tile-cache exit; no 93G counterpart|
|routine|PuckcSpots|NOT|(inline table in asspuckc)||20|inline in 93G, no separate routine to name against|
|routine|RosterGoalies|RELATED|GoalieRowText||30|goalie row data|
|routine|RosterG|RELATED|GoalieRowText||30|G label|
|equate|SPFfaceoff|RELATED|(faceoff sprite frame group)||25|SNES-specific or different representation; SNES frame base; the 93G frames93.asm has no SPF equate for this group (frames are in separate graph|
|equate|SPFsmallfont|RELATED|(pad label glyph frames)||25|SNES-specific or different representation; SNES frame base; the 93G frames93.asm has no SPF equate for this group (frames are in separate graph|
|equate|SPFzamboni|RELATED|(zamboni frame group)||25|SNES-specific or different representation; SNES frame base; the 93G frames93.asm has no SPF equate for this group (frames are in separate graph|
|equate|SPFcrowd|RELATED|(crowd sprite frames)||25|SNES-specific or different representation; SNES frame base; the 93G frames93.asm has no SPF equate for this group (frames are in separate graph|
|equate|SPAListEnd|RELATED|SPAlist end (label)||25|SNES-specific or different representation; end of the SPAlist table (93G has SPAlist but no end label)|
|equate|TeamListEnd|RELATED|(TeamList end)||25|SNES-specific or different representation; 93G computes NumofTeams = (*-TeamList)/4 right after the list|
|equate|playoffseatsEnd|RELATED|(playoffseats end)||25|SNES-specific or different representation; end label of the playoff seats table|
|label|vb2_main|RELATED|vb2/IRQ7||45|common vblank tail|
|label|ReturnGoalies_r|RELATED|ReturnGoalies/CPgoalie||40|return half of ReturnGoalies|
