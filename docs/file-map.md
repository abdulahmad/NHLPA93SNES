# Source file map

`src/nhlpa93snes.asm` includes one file per bank (`src/banks/bXX_<name>.asm`). Bank $80 sets its address with `org`.
Each later bank orgs only when `pc()` has not already reached that address, so a bank that grew is not rewound.
On the stock tree the PC arrives exactly there and the org is skipped. A bank file then includes its routine and data
files in exact ROM order. Routines are in `src/routines/<93G module>/<area>/<Routine>.asm`
(one routine per file; a routine that falls through into the next keeps both). Data blocks that are only an `incbin` sit in the bank file itself, at their ROM position (listed here by label); other data is in `src/data/<category>/<Name>.asm`.
The SNES internal header and vectors are in `src/header/snes_header.asm` (end of bank $80).
The ROM is 512 KB (banks $80-$8F). Bank $90 is not in the default build; docs/adding-a-team.md says how to add it.
Regenerate this file with `python3 tools/gen_file_map.py` after `npm run build:retail`.

## src/banks/b80_engine.asm

org `$808000`.

- `$808000` routines/main/Start.asm
- `$8080B2` routines/hockey/interrupts/BRKHalt.asm
- `$8080B4` routines/hockey/interrupts/VBjsr.asm
- `$8080CE` routines/video/interrupts/vb2_blank.asm
- `$8080DE` routines/video/interrupts/vb2.asm (also vb2_main)
- `$80812F` routines/video/interrupts/VBlank_long.asm
- `$808133` routines/video/interrupts/VBlank.asm
- `$8081C5` routines/video/interrupts/VBlank_SprPal.asm
- `$808250` routines/video/interrupts/VBlank_List.asm
- `$808293` routines/video/interrupts/VBlank_VScroll.asm
- `$8082E0` routines/video/interrupts/VBlank_Cram.asm
- `$808361` routines/video/interrupts/VBlank_CramOnly.asm
- `$808390` routines/hockey/interrupts/HBjsr.asm
- `$8083A3` routines/video/interrupts/HBdefault.asm
- `$8083AB` routines/logic/skating/goalieacc.asm
- `$808404` routines/logic/skating/dostop.asm (also stopna)
- `$808496` routines/middle/math/muls16.asm
- `$8084C4` routines/hockey/teams/getpde.asm (also rtss)
- `$8084E7` routines/logic/skating/MaxSpeed.asm
- `$808527` routines/logic/computer/check4bench.asm
- `$808598` routines/logic/offsides/checkob.asm
- `$808681` routines/logic/computer/chk4lc.asm
- `$8086E3` routines/logic/puck/chk4shot.asm
- `$8087F7` routines/logic/puck/CompShoot.asm
- `$808834` routines/logic/assignments/assnearest.asm
- `$808B15` routines/logic/computer/check4check.asm
- `$808BAD` routines/logic/skating/burst.asm
- `$808C2D` routines/logic/skating/skatetopuck.asm
- `$808D8A` routines/logic/controls/Sweepcheck.asm
- `$808D95` routines/logic/offsides/chkpk.asm
- `$808D9F` routines/logic/offsides/chkpk2.asm
- `$808DB5` routines/logic/assignments/assshoot.asm
- `$808DE9` routines/logic/controls/SetShotMode.asm
- `$808E33` routines/logic/controls/ShotMode.asm
- `$808E78` routines/logic/puck/doshot.asm
- `$8090EB` routines/logic/puck/doshot_shotsets.asm
- `$80910F` routines/logic/assignments/asspassrec.asm
- `$80915C` routines/logic/assignments/assfight.asm
- `$809330` routines/logic/contact/chkhit.asm
- `$809493` routines/logic/contact/chkhit_cwd.asm
- `$8094CB` routines/logic/contact/chkhit_fall.asm
- `$809595` routines/logic/assignments/assfwatch.asm
- `$8096A8` routines/logic/assignments/assfaceoff.asm
- `$8096F9` routines/logic/assignments/assexit.asm
- `$80970D` routines/logic/assignments/assfaceoffpl.asm
- `$8097A3` routines/middle/math/randomd0.asm
- `$8097AC` routines/logic/puck/pucknorm.asm
- `$80988A` routines/logic/puck/findpc.asm
- `$8098C2` routines/logic/puck/findpc_calc.asm
- `$80996C` routines/middle/math/divs.asm
- `$8099C7` routines/logic/puck/a2touchpuck.asm
- `$809AA8` routines/logic/offsides/a2offsides.asm
- `$809B0A` routines/logic/animation/GetHot.asm
- `$809B7A` routines/logic/offsides/PuckIChk.asm
- `$809BC3` routines/logic/offsides/ChkOffsides.asm
- `$809CC2` routines/logic/offsides/ClearOffsidesIfAllPlayers.asm
- `$809D17` routines/hockey/collisions/checkpuckcoll.asm
- `$809D8A` routines/hockey/collisions/checkpuckcoll_ccx.asm
- `$809F15` routines/hockey/collisions/puckstick.asm
- `$80A07D` routines/hockey/collisions/puckglue.asm
- `$80A121` routines/hockey/collisions/deflect.asm
- `$80A148` routines/logic/controls/setc1player.asm
- `$80A15E` routines/logic/controls/setc2player.asm
- `$80A174` routines/logic/controls/restorepl.asm
- `$80A1B4` routines/hockey/teams/makepde.asm
- `$80A21A` routines/hockey/collisions/puckbody.asm
- `$80A2FA` routines/hockey/collisions/puckgoalie.asm
- `$80A52A` routines/logic/puck/pucknothing.asm
- `$80A550` routines/logic/puck/puckfaceoff.asm
- `$80A70F` routines/logic/lines/SetLCmode.asm
- `$80A748` routines/logic/lines/SetLCmode2.asm
- `$80A828` routines/penalty/scoreboard/ClrHor.asm
- `$80A87C` routines/logic/puck/puckfaceoff2.asm
- `$80ACC4` routines/logic/puck/updatefaceoff.asm
- `$80AD34` routines/logic/puck/Endfaceoff.asm
- `$80AE36` routines/logic/skating/dirtab.asm
- `$80AE56` routines/middle/math/randomd0_seed.asm
- `$80AE8B` routines/middle/math/randomd0A.asm
- `$80AE9D` routines/logic/controls/changeplayer.asm
- `$80AFA8` routines/logic/skating/vtoa.asm
- `$80B006` routines/logic/animation/SetSPA.asm
- `$80B01A` routines/hockey/game/ResetBench.asm
- `$80B086` routines/hockey/game/forcepldata.asm
- `$80B138` routines/hockey/players/Setplass.asm
- `$80B15D` routines/hockey/teams/setplayer.asm
- `$80B3E7` routines/hockey/util/ClampNibble.asm
- `$80B3F8` routines/hockey/game/resetplstuff.asm
- `$80B49D` routines/logic/assignments/assinsert.asm (also assreplace)
- `$80B4C1` routines/hockey/game/setupice.asm
- `$80B6D5` routines/hockey/display/setplayercolors.asm
- `$80B706` routines/hockey/display/setplayercolors_palbuffer.asm
- `$80B72C` routines/hockey/display/setplayercolors_sp.asm
- `$80B76B` routines/hockey/util/nullrtl.asm
- `$80B76C` routines/hockey/display/SprSort.asm
- `$80B7FA` routines/hockey/game/DoGameFrame.asm
- `$80B80D` routines/hockey/game/periodicevents.asm
- `$80B84C` routines/penalty/energy/AvgCline.asm
- `$80B8D8` routines/middle/math/divu16.asm
- `$80B90C` routines/print/printz.asm
- `$80B92D` routines/print/print.asm
- `$80B9F4` routines/penalty/scoreboard/updatepwrplay.asm
- `$80BAAF` routines/penalty/scoreboard/updatepwrplay_clr.asm
- `$80BABC` routines/penalty/scoreboard/PrintTeamNameAndScore_name.asm
- `$80BAF2` routines/logic/computer/ChkGoalies.asm (also ChkGoalies_CPG)
- `$80BB5A` routines/hockey/teams/setpersonel.asm
- `$80BCB0` routines/hockey/teams/SetPlList.asm
- `$80BDEB` routines/hockey/teams/TryAddPlayerToList.asm
- `$80BE47` routines/logic/computer/ReturnGoalies.asm (also ReturnGoalies_r)
- `$80BE89` routines/logic/computer/CPgoalie.asm
- `$80BED1` routines/hockey/display/updatecrowdf.asm
- `$80BF6A` routines/tables/Penaltylist.asm (also PenDataEOP, PenDataEOG, PenDataGoal, PenDataNoText, PenDataice, PenDataoffsides, PenDataGhold, PenDatadelay, PenDatawhistle, PenDatacharge, PenDataslash, PenDatatrip, PenDatarough2, PenDatarough, PenDatahook, PenDatacross, PenDataint, PenDataHold, PenDatafight, PenDatafight2, PenDataInst)
- `$80C18F` routines/penalty/penalties/AddPenalty.asm
- `$80C1B0` routines/penalty/penalties/AddPenalty2.asm
- `$80C278` routines/hockey/collisions/freezewindow.asm
- `$80C28B` routines/sound/sfx.asm
- `$80C2B4` routines/hockey/replay/updatereplay.asm
- `$80C3D4` routines/hockey/input/demoread.asm
- `$80C40B` routines/middle/input/ReadJoy1.asm
- `$80C429` routines/middle/input/ReadJoy2.asm
- `$80C447` routines/middle/input/ReadJoy.asm
- `$80C45D` routines/middle/input/jdtab.asm
- `$80C46D` routines/hockey/players/updateplayers.asm
- `$80C894` routines/hockey/collisions/checkcoll.asm
- `$80CA1D` routines/hockey/collisions/checkwallcoll.asm
- `$80CBB1` routines/middle/math/Sroot.asm
- `$80CBE5` routines/middle/math/divu.asm
- `$80CC1E` routines/hockey/collisions/wallcollb.asm
- `$80CCDE` routines/hockey/collisions/wallcoll.asm
- `$80CEC9` routines/logic/puck/puckflip.asm
- `$80CEE7` routines/hockey/collisions/checkgoal.asm
- `$80D12E` routines/stats/ChkShotStat.asm
- `$80D16F` routines/stats/ChkShotStat_add.asm
- `$80D182` routines/hockey/game/Goal.asm
- `$80D329` routines/penalty/penalties/PenGoalStuff.asm
- `$80D3D3` routines/hockey/collisions/checkgoalp.asm
- `$80D4C5` routines/hockey/collisions/CheckBump.asm
- `$80D573` routines/hockey/collisions/checkplcoll.asm
- `$80D632` routines/hockey/collisions/checkcx.asm
- `$80D87B` routines/sound/newcheck.asm
- `$80D88B` routines/hockey/collisions/checkint.asm
- `$80D933` routines/hockey/collisions/FallDown.asm
- `$80DB12` routines/hockey/collisions/checkcheck.asm
- `$80DC95` routines/hockey/collisions/checkfight.asm
- `$80DE89` routines/hockey/collisions/SetInst.asm
- `$80DF3F` routines/logic/controls/doinput.asm
- `$80E073` routines/logic/controls/faceoffinput.asm
- `$80E0C5` routines/logic/controls/Holdplayer.asm
- `$80E0E1` routines/logic/controls/setpads.asm
- `$80E13E` routines/hockey/display/updateanim.asm
- `$80E1E8` routines/hockey/collisions/checkwindow.asm
- `$80E35E` routines/video/sprites/setvideo.asm
- `$80E3C9` routines/video/rink/updatescroll.asm
- `$80E3E7` routines/video/objects/checkfo.asm
- `$80E439` routines/video/objects/setsortcords.asm
- `$80E495` routines/video/rink/find3d.asm
- `$80E501` routines/video/objects/setffo.asm
- `$80E605` routines/video/text/ButtonLabelCharTable.asm
- `$80E60B` routines/video/objects/uppads.asm
- `$80E6C7` routines/penalty/penalties/PenaltyManager.asm
- `$80E6D6` routines/stats/chkatop.asm
- `$80E715` routines/penalty/penalties/checkfornewpen.asm
- `$80E7F7` routines/penalty/penalties/Stop4Pen.asm
- `$80E8F4` routines/penalty/penalties/limitfo.asm
- `$80E99F` routines/penalty/penalties/chkprogress.asm
- `$80EA40` routines/penalty/penalties/InProgress.asm
- `$80EC89` routines/penalty/penalties/coinsearch.asm
- `$80ECC7` routines/penalty/penalties/UpdatePA.asm
- `$80ED0C` routines/penalty/penalties/SetPA.asm
- `$80ED38` RonBarrMap (data)
- `$80F36E` routines/hockey/replay/adda43.asm
- `$80F391` routines/logic/lines/setlccords.asm
- `$80F3E1` routines/hockey/screens/startpause.asm
- `$80F3E8` routines/middle/input/ReadPads.asm
- `$80F45B` routines/logic/assignments/asspuckc.asm
- `$80F5EA` routines/hockey/password/DecodePW.asm
- `$80F5F2` routines/hockey/screens/Opening3.asm
- `$80F5FA` routines/hockey/password/SuperDiv.asm
- `$80F6A1` routines/middle/math/randomd0sA.asm
- `$80F6AD` routines/logic/assignments/assgoalie.asm
- `$80FCC9` routines/logic/skating/ClampYPosition.asm
- `$80FD05` routines/logic/skating/AdjustFacingDirection.asm
- `$80FD70` routines/logic/assignments/GoalieSaveList.asm
- `$80FD7C` routines/logic/puck/shotdiradj.asm
- `$80FE89` routines/logic/skating/CalcAngleOffset.asm
- `$80FED1` routines/penalty/energy/reenergizeteam.asm (also unusedFF)
- `$80FFC0` header/snes_header.asm

## src/banks/b81_samples.asm

org `$818000` when `pc()` is below it.

- `$818000` data/sound/gamesound.asm (also GameSampleDir, GameSampleDirEnd, GameSamples, GameSamplesEnd)

## src/banks/b82_samples_rink.asm

org `$82B86C` when `pc()` is below it.

- `$82B86C` data/frames93s.asm (also SPAgready_table, SPAgready2_table, SPAgglover_table, SPAgglovel_table, SPAgstickr_table, SPAgstickl_table, SPAgstackr_table, SPAgstackl_table, SPAgswing_table, SPAgskate_table, SPApflip_table, SPAglide_table, SPAskatewp_table, SPAskate_table, SPAturnl_table, SPAturnr_table, SPAstop_table, SPApassf_table, SPApassb_table, SPAshotf_table, SPAshotb_table, SPAglideback_table, SPAskateback_table, SPAsweepchk_table, SPAshoulderchkl_table, SPAshoulderchkr_table, SPAhipchkl_table, SPAhipchkr_table, SPAburst_table, SPAHold_table, SPAHold2_table, SPAflail_table, SPAfallfwd_table, SPAfallback_table, SPAcelebrate_table, SPApump_table, SPAfight_table, SPAfgrab_table, SPAfheld_table, SPAfhigh_table, SPAflow_table, SPAfhith_table, SPAfhitl_table, SPAffall_table, SPAwallright_table, SPAwallleft_table, SPAfaceoff_table, SPAfaceoffr_table, SPAsiren_table, SPAstanley_table, SPAfinjury_table, SPAflip_table, SPAstumble_table, SPAhook_table, SPAhook2_table, SPAcatch_table, SPAbglass_table, SPAgdive_table, SPAinjury1_table, SPAListEnd)
- `$82CDA0` IceRinkTiles (data)
- `$82F93C` routines/penalty/penalties/SetPA2.asm
- `$82F9D1` routines/penalty/ticker/UpdateScores.asm
- `$82FA01` routines/hockey/password/BitstoPW.asm
- `$82FA1A` routines/sound/sndqreset.asm
- `$82FA31` routines/sound/SPCBootUpload.asm
- `$82FA7A` routines/sound/SPCGameUpload.asm
- `$82FAB9` routines/sound/SPCUpload.asm
- `$82FB79` routines/sound/QueueSound.asm
- `$82FBA6` data/text/PasstoText.asm
- `$82FBC5` routines/hockey/password/PWtoBits.asm
- `$82FBEA` routines/hockey/password/ClrPassBits.asm
- `$82FC03` routines/hockey/password/PushBits.asm
- `$82FC39` routines/hockey/util/BitMaskTable.asm
- `$82FC59` routines/hockey/game/GameOver.asm
- `$82FC97` routines/hockey/playoffs/SaveRegsStartHL2.asm
- `$82FCBD` data/gfx/PixelRemap8D.asm
- `$82FCCD` routines/video/text/marktextlo.asm
- `$82FCD4` data/gfx/PixelRemap83.asm
- `$82FCDB` routines/middle/math/muls32.asm
- `$82FD17` routines/video/sprites/addframe_hi.asm
- `$82FD54` routines/logic/skating/noturn.asm
- `$82FD64` routines/video/text/marktexthi.asm
- `$82FD6B` routines/stats/clearTeamStats.asm
- `$82FD95` routines/penalty/penalties/ClearPenaltyMessage.asm
- `$82FDB5` routines/hockey/screens/startpause2.asm
- `$82FDBF` routines/print/printbigz.asm
- `$82FDD3` routines/print/appendz.asm
- `$82FDE7` routines/logic/assignments/asscentero.asm (also unusedFF82)

## src/banks/b83_teams.asm

org `$838000` when `pc()` is below it.

- `$838000` data/teamdata93s.asm (also TeamListEnd, AllStarsEast, AllStarsWest, Boston, Buffalo, Calgary, Chicago, Detroit, Edmonton, Hartford, LosAngeles, LongIsland, Minnesota, Montreal, NewJersey, NewYork, Ottawa, Philadelphia, Pittsburgh, Quebec, SanJose, StLouis, TampaBay, Toronto, Vancouver, Winnipeg, Washington, playoffseats, playoffseatsEnd)
- `$83C6D8` SmallFontTiles (data)
- `$83CC0C` routines/hockey/teams/getname.asm
- `$83CCCB` IceRinkMap (data)
- `$83ECAB` HorRinkMap (data)
- `$83F72B` RinkPalette (data)
- `$83F82B` routines/hockey/screens/Pausemode.asm
- `$83F891` routines/hockey/screens/Pausemode_menu.asm
- `$83FA32` routines/hockey/screens/waitjoy.asm
- `$83FA79` routines/hockey/screens/PauseResume.asm
- `$83FA83` routines/hockey/screens/PauseLeave.asm
- `$83FA87` routines/hockey/screens/Opening2.asm
- `$83FAEC` RefsMap (data)
- `$83FDFC` routines/logic/assignments/assgoalietopuck.asm (also unusedFF83)

## src/banks/b84_sprites_scouting.asm

org `$848000` when `pc()` is below it.

- `$848000` SpriteSet9 (data)
- `$84D630` ScoutingReportText (data)
- `$84E949` FaceOffMap (data)
- `$84EA39` routines/print/ConvertByteToDigits.asm
- `$84EA66` routines/hockey/teams/UpdateRosterPlayers.asm
- `$84EABF` routines/hockey/teams/UpdateRosterPlayer.asm
- `$84EC4C` routines/hockey/teams/SlideOutRosterPlayer.asm
- `$84EC5C` routines/hockey/teams/SetupNextPlayer.asm
- `$84ED51` routines/hockey/teams/PickRosterAnim.asm
- `$84ED96` routines/hockey/teams/GetRosterEntry.asm
- `$84EDBB` routines/hockey/teams/SkaterRosterAnims.asm
- `$84EDD7` routines/hockey/teams/GoalieRosterAnims.asm
- `$84EDF3` routines/hockey/teams/RosterAnimScripts.asm
- `$84EEE3` routines/hockey/teams/RosterOrderTable.asm
- `$84EEF4` routines/hockey/display/UpdateTeamSprites.asm (also DrawScoutPlayer)
- `$84EF3C` HotList (data)
- `$84F386` RinkLogoTiles (data)
- `$84F532` routines/hockey/screens/UpdateScoutingDisplay.asm
- `$84F734` routines/hockey/screens/ScrollDisplayUp.asm
- `$84F79D` PlayoffTiles (data)
- `$84F816` routines/video/objects/defaultsprites2.asm
- `$84F960` routines/video/objects/SsoInitTable.asm
- `$84F980` routines/video/objects/FfoInitTable.asm
- `$84F9B2` routines/video/objects/SortObjInitTable.asm
- `$84FAD2` routines/middle/input/orjoy.asm
- `$84FAE3` routines/stats/DisplayStats.asm
- `$84FC30` routines/stats/TeamStatTextTbl.asm
- `$84FC44` routines/stats/GetNameandAttrib.asm
- `$84FD49` routines/stats/attribjmp.asm
- `$84FD55` routines/stats/AttribStatus.asm
- `$84FDC6` data/text/StatusTextTbl.asm
- `$84FDEE` routines/stats/AttribEnergy.asm
- `$84FE14` routines/stats/AttribFighting.asm (also AttribRating, AttribPrintPct)
- `$84FE4A` routines/stats/AttribHanded.asm
- `$84FE5F` data/text/HandedTextTbl.asm
- `$84FE6F` routines/stats/AttribWeight.asm (also unusedFF84)

## src/banks/b85_sprites_title.asm

org `$858000` when `pc()` is below it.

- `$858000` SpriteSet4 (data)
- `$85D5A4` routines/hockey/playoffs/GetShifter.asm
- `$85D5C0` Title1Map (data)
- `$85FBB9` routines/video/sprites/SetSframeHi.asm
- `$85FF0E` routines/hockey/input/getpzjoy.asm
- `$85FF1E` routines/hockey/screens/setoptions_teamnames.asm
- `$85FF96` routines/hockey/util/nullrtl85.asm
- `$85FF97` routines/hockey/game/ResetClock.asm (also unusedFF85)

## src/banks/b86_sound.asm

org `$868000` when `pc()` is below it.

- `$868000` data/sound/bootsound.asm (also SPCDriver, SPCCode, fmtune_playoff_order, fmtune_title_order, fmtune_unused2_order, fmtune_goal_order, fmtune_periodstart_order, fmtune_lategame_order, fmtune_unused7_order, fmtune_midperiod_order, fmtune_unused9_order, fmtune_playoff_set, fmtune_title_set, fmtune_unused2_set, fmtune_goal_set, fmtune_periodstart_set, fmtune_lategame_set, fmtune_unused7_set, fmtune_midperiod_set, fmtune_unused9_set, fmtune_playoff_stream, fmtune_unused2_stream, fmtune_unused9_stream, fmtune_title_stream, fmtune_goal_stream, fmtune_lategame_stream, fmtune_periodstart_stream, fmtune_unused7_stream, fmtune_midperiod_stream, fmtune_title_stream2, fmtune_unused2_stream2, fmtune_unused9_stream2, fmtune_goal_stream2, fmtune_midperiod_stream2, fmtune_unused7_stream2, fmtune_periodstart_stream2, fmtune_lategame_stream2, fmtune_goal_stream3, fmtune_title_stream3, fmtune_playoff_stream2, fmtune_unused2_stream3, sfx_table, sfx_a1, sfx_siren, sfx_crowd0, sfx_crowd1, sfx_crowd2, sfx_crowd3, sfx_crowd4, sfx_crowd5, sfx_crowd6, sfx_crowd7, sfx_crowdoff, sfx_check1, sfx_check2, sfx_playerwall, sfx_playerwall2, sfx_shothard, sfx_puckwall1, sfx_puckwall2, sfx_puckwall3, sfx_hithigh, sfx_hitlow, sfx_shotfh, sfx_shotbh, sfx_puckpost, sfx_stop1, sfx_stop2, sfx_shotwiff2, sfx_shotwiff1, sfx_shotwiff4, sfx_shotwiff3, sfx_crowdboo, sfx_oooh2, sfx_crowdcheer, sfx_whistle, SPCDriverEnd, BootInstruments, BootInstrumentsEnd, BootSampleDir, BootSampleDirEnd, BootSamples, BootSamplesEnd)
- `$86FA3E` routines/decompress/DecompressBytecode.asm
- `$86FB96` routines/hockey/teams/RestoreBenchEnergy.asm
- `$86FBE1` routines/sound/StartSngTitle.asm
- `$86FC05` routines/sound/StartSngEOP.asm
- `$86FC29` routines/hockey/game/setteams.asm
- `$86FC53` routines/middle/input/ProcessInputWithRepeat.asm
- `$86FC76` routines/hockey/screens/setoptions_printpos2.asm
- `$86FC8A` routines/hockey/game/GetPeriodTimeRemaining.asm
- `$86FCA1` routines/hockey/game/GetPeriodTime.asm
- `$86FCAF` routines/hockey/game/GetPeriodTime_timetab.asm
- `$86FCB7` routines/logic/lines/lcfound2.asm
- `$86FCE3` routines/hockey/teams/PickStartingGoalie.asm
- `$86FD86` routines/logic/assignments/assscore.asm (also unusedFF86)

## src/banks/b87_sprites_refs.asm

org `$878000` when `pc()` is below it.

- `$878000` SpriteSet2 (data)
- `$87C3A0` EASNBGMap (data)
- `$87C6B4` FaceOffTiles (data)
- `$87CABA` Teamblocksmap (data)
- `$87CE62` routines/video/sprites/SetSframe.asm
- `$87D1FE` routines/video/sprites/addframe_end.asm
- `$87D205` SpriteSet6 (data)
- `$87F3E9` routines/hockey/replay/RestoreReplayFrame.asm
- `$87F55A` data/gfx/PixelRemap87.asm
- `$87F55E` RefTiles (data)
- `$87FF78` routines/logic/assignments/assepen.asm (also unusedFF87)

## src/banks/b88_sprites_teamblocks.asm

org `$888000` when `pc()` is below it.

- `$888000` GameSetUpMap (data)
- `$88822F` SmallFontMap (data)
- `$88832F` routines/middle/math/mulu32.asm
- `$888405` routines/penalty/energy/getlinee.asm
- `$8884A9` routines/hockey/password/WritePassBits.asm
- `$888548` routines/logic/skating/noturn0.asm
- `$8885F7` routines/hockey/password/PWprint.asm
- `$88868D` routines/hockey/password/EncodePW.asm
- `$88871C` FramerMap (data)
- `$88872E` FramerTiles (data)
- `$8887AE` routines/video/crowd/showcrowd.asm
- `$888853` routines/hockey/password/SuperMult.asm
- `$8888C3` routines/hockey/screens/setoptions_drawback.asm
- `$888942` routines/middle/math/mulu.asm
- `$888A0F` SpriteSet8 (data)
- `$889B73` TeamBlocksTiles (data)
- `$88BC56` SpriteSet7 (data)
- `$88EF9C` routines/hockey/password/GetPassWord.asm
- `$88F28F` data/text/PasswordText.asm
- `$88F2B0` routines/hockey/screens/TitleScreen.asm
- `$88F4F0` data/text/CreditsBlank.asm
- `$88F512` routines/hockey/playoffs/PlayoffScreen.asm
- `$88F9FB` routines/tables/PlayoffTreeSetup.asm
- `$88FBA6` routines/logic/assignments/assdefd.asm
- `$88FDB2` routines/hockey/password/SuperAdd.asm
- `$88FDD0` routines/logic/skating/skateto.asm (also unusedFF88)

## src/banks/b89_sprites_replay.asm

org `$898000` when `pc()` is below it.

- `$898000` SpriteSet11 (data)
- `$8990F0` routines/hockey/replay/ReplayMode.asm
- `$899383` SpriteSet13 (data)
- `$89E95D` routines/penalty/scoreboard/printscores1.asm
- `$89EAB1` routines/penalty/scoreboard/printscores1_per.asm
- `$89EAD7` routines/penalty/scoreboard/PrintTeamNameAndScore.asm
- `$89EB14` routines/penalty/util/nullrtl89.asm
- `$89EB15` routines/sound/p_music_vblank.asm
- `$89EB45` RefTilesHor (data)
- `$89F3FB` RefsMapHor (data)
- `$89FB6B` routines/sound/StartSngEOG.asm
- `$89FB8F` routines/sound/StartSngPO.asm
- `$89FBB3` routines/sound/StartSngGoal.asm
- `$89FBDF` routines/sound/StartSngPeriodStart.asm
- `$89FC0B` routines/sound/StartSngLateGame.asm
- `$89FC37` routines/sound/StartSngPP.asm
- `$89FC63` routines/sound/StartSngFaceoff.asm
- `$89FC8F` routines/middle/util/CopyWords.asm
- `$89FCC1` routines/hockey/teams/ClearRosterName.asm
- `$89FCD8` routines/hockey/teams/GetRosterEntry89.asm
- `$89FCFD` routines/print/FinalizeTextBuffer.asm
- `$89FD0C` routines/hockey/game/StartGame.asm
- `$89FD3A` routines/hockey/game/restoreteams.asm
- `$89FD6A` routines/logic/skating/EvadePC.asm
- `$89FDD6` routines/logic/assignments/asswingd.asm (also unusedFF89)

## src/banks/b8A_sprites.asm

org `$8A8000` when `pc()` is below it.

- `$8A8000` SpriteSet12 (data)
- `$8AF880` PlayoffBracketMap (data)
- `$8AFAA8` data/text/Credits.asm
- `$8AFD0C` routines/logic/lines/lineinput.asm
- `$8AFD6D` routines/logic/lines/getlchoice.asm
- `$8AFE21` routines/penalty/highlights/SetScore.asm (also unusedFF8A)

## src/banks/b8B_sprites.asm

org `$8B8000` when `pc()` is below it.

- `$8B8000` routines/hockey/playoffs/NewPO.asm
- `$8B807D` routines/hockey/input/FigureJoy.asm
- `$8B816A` routines/hockey/screens/Opening.asm
- `$8B8172` routines/hockey/screens/Opening4.asm
- `$8B817A` routines/hockey/password/ReadPassBits.asm
- `$8B8253` routines/hockey/playoffs/ResolveGames.asm
- `$8B83EE` SpriteSet5 (data)
- `$8BFCCE` routines/print/printbig.asm
- `$8BFE47` routines/logic/assignments/asswingo.asm
- `$8BFFCC` routines/video/hud/showref.asm
- `$8BFFD3` routines/logic/skating/skatetopuckinit.asm

## src/banks/b8C_sprites.asm

org `$8C8000` when `pc()` is below it.

- `$8C8000` NHLPALogo (data)
- `$8C845A` SpriteSet0 (data)
- `$8CFC1A` routines/video/objects/checksso.asm
- `$8CFD83` routines/logic/puck/chk4pass.asm (also unusedFF8C)

## src/banks/b8D_sprites.asm

org `$8D8000` when `pc()` is below it.

- `$8D8000` routines/hockey/playoffs/MakeTree.asm
- `$8D8120` routines/video/interrupts/InitPPU.asm
- `$8D8217` routines/hockey/game/StartPer.asm
- `$8D82F0` routines/penalty/penalties/GetLowestPen.asm
- `$8D8389` routines/hockey/collisions/Bcheck.asm
- `$8D8416` routines/hockey/playoffs/ContinuePlayoffs.asm
- `$8D847C` routines/print/eraser.asm
- `$8D84E2` routines/hockey/teams/DrawTeamBlocks.asm
- `$8D8549` routines/penalty/scoreboard/EASNLogo.asm
- `$8D85A9` routines/hockey/game/PeriodOver.asm
- `$8D8605` routines/hockey/teams/GetPlayerName.asm
- `$8D865A` routines/sound/updatesound.asm
- `$8D86A8` routines/tables/asstab.asm
- `$8D871C` routines/middle/math/mulu16.asm
- `$8D87B0` routines/logic/puck/puckshadow.asm
- `$8D87FB` routines/hockey/input/setd0player.asm
- `$8D883C` SpriteSet10 (data)
- `$8DEEC8` BigFontTiles (data)
- `$8DF888` routines/penalty/highlights/StartHL2.asm
- `$8DFCC7` routines/logic/assignments/asspenalty.asm
- `$8DFE1B` routines/logic/controls/clrplayer.asm
- `$8DFE36` routines/logic/skating/avdgoal.asm (also unused008D)

## src/banks/b8E_sprites.asm

org `$8E8000` when `pc()` is below it.

- `$8E8000` routines/hockey/game/Gameloop.asm
- `$8E8182` routines/hockey/teams/FormatPlayerNumInitial.asm
- `$8E826B` routines/logic/assignments/assbench.asm
- `$8E83EB` SpriteSet3 (data)
- `$8ED9A7` SpriteSet14 (data)
- `$8EFE73` routines/logic/assignments/assdefo.asm (also unused008E)

## src/banks/b8F_frontend.asm

org `$8F8000` when `pc()` is below it.

- `$8F8000` BigFontMap (data)
- `$8F8130` routines/video/hud/dobar.asm
- `$8F8213` routines/tables/linelist.asm
- `$8F8236` data/text/PerLabels.asm
- `$8F824D` EASNLogoMap (data)
- `$8F8269` data/gfx/BigFontIndex.asm
- `$8F82A4` routines/video/hud/showclock.asm
- `$8F833F` routines/logic/assignments/asseben.asm
- `$8F83A7` routines/penalty/penalties/PushRef.asm
- `$8F84B5` routines/penalty/scoreboard/SetHor.asm
- `$8F852E` routines/penalty/scoreboard/USBoard.asm
- `$8F85FA` routines/penalty/scoreboard/pplpen.asm
- `$8F8682` routines/print/PushNumber.asm
- `$8F86B6` routines/penalty/ticker/Intermission.asm
- `$8F873F` routines/penalty/ticker/Intermission_ticker.asm
- `$8F8757` routines/stats/StatsReport.asm
- `$8F877D` routines/penalty/ticker/Intermission_tick.asm
- `$8F87A8` routines/penalty/ticker/NewTicker2_next.asm
- `$8F87C0` routines/video/crowd/KillCrowd.asm
- `$8F87C9` routines/print/appstring.asm
- `$8F87EA` routines/print/PushTime.asm
- `$8F8858` routines/penalty/ticker/NewTicker.asm
- `$8F8861` routines/penalty/ticker/NewTicker2.asm
- `$8F887A` routines/penalty/ticker/NewTicker3.asm
- `$8F8960` routines/penalty/ticker/PrintGameInfo.asm
- `$8F89A3` data/text/GameLabels.asm
- `$8F8ABC` routines/video/hud/showzam.asm
- `$8F8AE9` routines/middle/util/waitxsr.asm
- `$8F8B11` routines/hockey/game/clockcont.asm
- `$8F8B21` routines/hockey/game/clockcont_0.asm
- `$8F8C1B` routines/penalty/highlights/DoHiLights.asm
- `$8F8C4B` routines/logic/assignments/assdopen.asm
- `$8F8C72` routines/penalty/penalties/updatepentime.asm
- `$8F8D68` routines/penalty/scoreboard/linebar.asm
- `$8F8DC7` routines/logic/lines/lcfound.asm
- `$8F8E03` routines/hockey/screens/startpause1.asm
- `$8F8E0D` routines/hockey/screens/PauseExit.asm
- `$8F8E54` routines/hockey/replay/suba4.asm
- `$8F8EAF` routines/hockey/replay/adda4.asm
- `$8F8EF7` routines/video/text/QueueTextDMA.asm
- `$8F8F28` routines/video/dma/QueueBackmapDMA.asm
- `$8F8F4A` routines/video/rink/updatescroll_rows.asm
- `$8F901A` routines/middle/input/jdtab8F.asm
- `$8F902A` routines/penalty/ticker/InitScores.asm
- `$8F9073` routines/hockey/password/ResetPassWord.asm
- `$8F9085` SpriteSet1 (data)
- `$8FD4F9` routines/logic/controls/fightinput.asm
- `$8FD5BF` routines/hockey/collisions/holdcheck.asm
- `$8FD68C` routines/print/Fprint.asm
- `$8FD69F` routines/print/Framer.asm
- `$8FD75A` routines/logic/assignments/donothing.asm
- `$8FD76B` routines/stats/GetGoalieCount.asm
- `$8FD793` routines/print/AdvanceStringPtr.asm
- `$8FD7A1` data/text/PAttribColumns.asm
- `$8FD8E6` data/text/GAttribColumns.asm
- `$8FD9CC` data/text/PlayerPositionText.asm
- `$8FD9DF` routines/penalty/penalties/releasepl.asm
- `$8FDA75` routines/hockey/screens/InitScoutingDisplay.asm
- `$8FDA8F` routines/logic/assignments/assstanley.asm
- `$8FDAF3` routines/video/sprites/addframe_full.asm
- `$8FDAFC` routines/penalty/penalties/RemovePlayerFromList.asm
- `$8FDB1B` routines/logic/assignments/asscenterd.asm
- `$8FDBDB` routines/hockey/screens/box.asm
- `$8FDBF7` routines/hockey/display/UpdateCwdExcite.asm
- `$8FDBF8` routines/sound/CheckLateGameSong.asm
- `$8FDBF9` routines/penalty/energy/loadTeamStruct.asm
- `$8FDC0D` routines/hockey/screens/ScoutingReport.asm
- `$8FDED2` routines/hockey/screens/PrintScoutRatings.asm
- `$8FDF66` data/text/ScoutLabels.asm
- `$8FDFE2` routines/hockey/players/asspuckc_postab.asm
- `$8FE00A` routines/penalty/energy/SetupTeamForIntermission.asm
- `$8FE04C` routines/video/sprites/ClearSprites.asm
- `$8FE0E4` routines/video/dma/remap.asm
- `$8FE154` data/gfx/PixelRemap8F.asm
- `$8FE164` routines/logic/skating/playeracc.asm
- `$8FE2D9` routines/logic/skating/dirtab8F.asm
- `$8FE2F9` routines/penalty/penalties/ClearPenaltyBuffer.asm
- `$8FE316` routines/middle/math/randomd0s.asm
- `$8FE32B` routines/hockey/screens/DefaultMenus.asm
- `$8FE369` routines/penalty/penalties/checkagr.asm
- `$8FE3B0` routines/middle/util/WeightedRandomSelect.asm
- `$8FE404` routines/video/interrupts/forceblack.asm
- `$8FE43C` routines/logic/controls/passmode.asm
- `$8FE458` routines/logic/puck/dopass.asm
- `$8FE67D` data/gfx/FrameSetTable.asm
- `$8FE6BD` routines/logic/lines/CompLine.asm
- `$8FE825` routines/stats/TeamRosterScreen.asm
- `$8FEBE0` routines/stats/RosterGoalies.asm
- `$8FEBE4` routines/stats/RosterG.asm
- `$8FEBF0` data/text/RosterLineNames.asm
- `$8FEC68` routines/video/sprites/addframe.asm
- `$8FECAB` routines/hockey/screens/SetupPauseScreen.asm
- `$8FEE4A` routines/hockey/input/seta2.asm
- `$8FEE6B` routines/hockey/teams/setpde.asm
- `$8FEE83` routines/hockey/screens/setoptions.asm
- `$8FF4B8` data/gfx/PixelRemapFramer.asm
- `$8FF4C8` data/gfx/PixelRemapFont.asm
- `$8FF4D8` routines/middle/util/UnpackNibbles.asm
- `$8FF54E` routines/print/PushNumberWidth.asm
- `$8FF58D` routines/penalty/scoreboard/SetHor_rink.asm
- `$8FF603` routines/logic/skating/Findhittype.asm
- `$8FF63D` routines/penalty/penalties/prefmes.asm
- `$8FF741` routines/hockey/game/CheckInjury.asm
- `$8FF74A` routines/hockey/game/setInjuryType.asm
- `$8FF7B6` routines/tables/sublist.asm
- `$8FF820` routines/tables/priolist.asm
- `$8FF827` routines/hockey/screens/ShowInjuryBox.asm
- `$8FF8C4` routines/logic/puck/passtoa0.asm
- `$8FFAF3` routines/stats/GetPlayerCount.asm
- `$8FFB2B` routines/hockey/teams/GetPlayerNumInitial.asm
- `$8FFB5B` routines/logic/contact/Acheck.asm
- `$8FFB8B` routines/middle/math/divs16.asm
- `$8FFBDC` routines/logic/skating/doplayeracc.asm
- `$8FFDD8` routines/logic/controls/ResetAndSelectPlayers.asm
- `$8FFDFB` routines/tables/cd0.asm
- `$8FFE7B` routines/sound/MusicCue.asm
- `$8FFE8E` routines/sound/sfx8F.asm
- `$8FFEB4` routines/hockey/screens/ShowGoalBox.asm
- `$8FFFDC` data/text/GoalBoxText.asm (also unusedFF8F)
