; Bank $8F: frontend. Files in ROM order (docs/file-map.md).

if pc() < $8F8000
	org $8F8000
endif

BigFontMap:							;bigfont.map: big font tiles of each character: 76 top-row words, then the
									;76 bottom-row words (+$98); printbig uses BigFontIndex
	incbin "../../Extracted/Graphics/BigFont.snesmap"
BigFontMapEnd:						; end of BigFontMap
	assert BigFontMapEnd-BigFontMap == 304

incsrc "../routines/video/unusedEnergyBar.asm"
incsrc "../routines/tables/linelist.asm"

PerLabels:							;period names (gsp 0-4); $12-$14 are the "st", "nd", "rd" small font tiles
	%StringTb("1",$12)
	%StringTb("2",$13)
	%StringTb("3",$14)
	%String("OT")
	%String("Final")

EASNLogoMap:						;easn.map (small): the 7 x 2 EASN logo tile words for EASNLogo
									;(unusedchars + n)
	incbin "../../Extracted/Graphics/EASN.snesmap"
EASNLogoMapEnd:						; end of EASNLogoMap
	assert EASNLogoMapEnd-EASNLogoMap == 28

BigFontIndex:						;big font index of each character $20-$5A (*2 into BigFontMap);
									;negative = one column wide
	;      -!  "   #   $   %   &   -'  (   )   *   +   ,   -   -.  /
	db $00,$B7,$00,$00,$00,$00,$00,$BA,$00,$00,$00,$00,$00,$00,$C2,$00
	;  0   -1  2   3   4   5   6   7   8   9   -:  ;   <   =   >   ?
	db $33,$CB,$36,$38,$3A,$3C,$3E,$40,$42,$44,$BB,$00,$00,$00,$00,$48
	;  @   A   B   C   D   E   F   G   H   -I  J   K   L   M   N   O
	db $4A,$00,$02,$04,$06,$08,$0A,$0C,$0E,$F0,$11,$13,$15,$17,$19,$1B
	;  P   Q   R   S   T   U   V   W   X   Y   Z
	db $1D,$1F,$21,$23,$25,$27,$29,$2B,$2D,$2F,$31

incsrc "../routines/video/showclock.asm"
incsrc "../routines/logic/asseben.asm"
incsrc "../routines/penalty/PushRef.asm"
incsrc "../routines/penalty/SetHor.asm"
incsrc "../routines/penalty/USBoard.asm"
incsrc "../routines/penalty/pplpen.asm"
incsrc "../routines/print/PushNumber.asm"
incsrc "../routines/penalty/Intermission.asm"
incsrc "../routines/penalty/InitTicker.asm"
incsrc "../routines/stats/StatsReport.asm"
incsrc "../routines/penalty/IntermissionTick.asm"
incsrc "../routines/penalty/TickerNext.asm"
incsrc "../routines/video/KillCrowd.asm"
incsrc "../routines/print/appstring.asm"
incsrc "../routines/print/PushTime.asm"
incsrc "../routines/penalty/NewTicker.asm"
incsrc "../routines/penalty/NewTicker2.asm"
incsrc "../routines/penalty/NewTicker3.asm"
incsrc "../routines/penalty/PrintGameInfo.asm"

GameLabels:							;ticker titles, by OptPlayMode and gamelevel
	%String("EASN Hockey Night")
	%String("EA Cup Qualifier")
	%String("EA Cup Qualifier")
	%String("EA Cup Qualifier")
	%String("EA Cup Qualifier")
	%String("EA Cup Qualifier")
	%String("EA Cup Qualifier")
	%String("EA Cup Qualifier")
	%String("EA Cup Qualifier")
	%String("EA Quarterfinal")
	%String("EA Quarterfinal")
	%String("EA Quarterfinal")
	%String("EA Quarterfinal")
	%String("EA Cup Semifinal")
	%String("EA Cup Semifinal")
	%String("EA Cup final")

incsrc "../routines/video/showzam.asm"
incsrc "../routines/middle/waitxsr.asm"
incsrc "../routines/hockey/clockcont.asm"
incsrc "../routines/hockey/clockcont_0.asm"
incsrc "../routines/penalty/DoHiLights.asm"
incsrc "../routines/logic/assdopen.asm"
incsrc "../routines/penalty/updatepentime.asm"
incsrc "../routines/penalty/linebar.asm"
incsrc "../routines/logic/lcfound.asm"
incsrc "../routines/hockey/startpause1.asm"
incsrc "../routines/hockey/PauseExit.asm"
incsrc "../routines/hockey/suba4.asm"
incsrc "../routines/hockey/adda4.asm"
incsrc "../routines/video/QueueTextDMA.asm"
incsrc "../routines/video/QueueBackmapDMA.asm"
incsrc "../routines/video/ShowRinkRows.asm"
incsrc "../routines/middle/jdtab8F.asm"
incsrc "../routines/penalty/InitScores.asm"
incsrc "../routines/hockey/ResetPassWord.asm"

SpriteSet1:							;frame set 1 (SPFswing): frames 97-144
	dw 48							; frames
	dw 258							; pieces
	dw 512							; tiles
	dw .pieces-SpriteSet1
	dw .tiles-SpriteSet1
.frames:							;first piece of each frame (+1 entry for the end)
	dw 0,6,12,20,24,29,35,39
	dw 43,45,48,56,60,64,69,72
	dw 76,84,89,94,97,100,106,112
	dw 120,125,131,136,140,145,157,162
	dw 166,172,176,186,197,201,206,209
	dw 215,224,232,238,243,248,252,255
	dw 258
.pieces:							;x, y, tile, attributes per piece
	incbin "../../Extracted/Graphics/Sprites/set01.pieces"
	assert .tiles-.pieces == 4*258
.tiles:								;512 4bpp tiles (32 bytes each)
	incbin "../../Extracted/Graphics/Sprites/set01.chr"
SpriteSet1End:						; end of SpriteSet1
	assert SpriteSet1End-SpriteSet1 == $474+512*32

incsrc "../routines/logic/fightinput.asm"
incsrc "../routines/hockey/holdcheck.asm"
incsrc "../routines/penalty/Fprint_list.asm"
incsrc "../routines/print/Framer.asm"
incsrc "../routines/logic/assnothing.asm"
incsrc "../routines/logic/GetGoalieCount.asm"
incsrc "../routines/penalty/AdvanceStringPtr.asm"

PAttribColumns:						;skater attribute columns for the Team Roster screen (TeamRosterScreen).
									;A String header, then two words for GetNameandAttrib: the mask of
									;rating nibbles to average and the attribjmp offset (0 status, 2 energy,
									;4 handed, 6 weight, 8 fighting, $A rating). A negative word ends the list
	%String("   Status   ]")
	dw $0000,$0000					;status
	%String("[  Overall  ]")
	dw $1F3A,$000A					;rating
	%String("[  Energy   ]")
	dw $0000,$0002					;energy
	%String("[  Agility  ]")
	dw $1000,$000A
	%String("[   Speed   ]")
	dw $0800,$000A
	%String("[  Handed   ]")
	dw $0040,$0004					;handed
	%String("[Off. Aware.]")
	dw $0400,$000A
	%String("[Def. Aware.]")
	dw $0200,$000A
	%String("[Shot Power ]")
	dw $0100,$000A
	%String("[Shot  Accur]")
	dw $0010,$000A
	%String("[Pass  Accur]")
	dw $0002,$000A
	%String("[Stick Handl]")
	dw $0020,$000A
	%String("[  Weight   ]")
	dw $2000,$0006					;weight
	%String("[ Endurance ]")
	dw $0008,$000A
	%String("[Aggression ]")
	dw $0001,$000A
	%String("[ Checking  ]")
	dw $0080,$000A
	%String("[  Fighting  ")
	dw $0040,$0008					;fighting
	dw $FFFF						; end

GAttribColumns:						;goalie attribute columns for the Team Roster screen, same format as
									;PAttribColumns
	%String("   Status   ]")
	dw $0000,$0000					;status
	%String("[  Overall  ]")
	dw $1B0F,$000A					;rating
	%String("[  Agility  ]")
	dw $1000,$000A
	%String("[   Speed   ]")
	dw $0800,$000A
	%String("[Glove Hand ]")
	dw $0040,$0004					;handed
	%String("[Def. Aware.]")
	dw $0200,$000A
	%String("[Puck Cont. ]")
	dw $0100,$000A
	%String("[Stick Right]")
	dw $0008,$000A
	%String("[Stick Left ]")
	dw $0004,$000A
	%String("[Glove Right]")
	dw $0002,$000A
	%String("[Glove Left ]")
	dw $0001,$000A
	%String("[   Weight   ")
	dw $2000,$0006					;weight
	dw $FFFF						; end

PlayerPositionText:					;position names LD, RD, LW, C, RW
	%String("LD")
	%String("RD")
	%String("LW")
	%String("C")
	%String("RW")

incsrc "../routines/penalty/releasepl.asm"
incsrc "../routines/hockey/InitScoutingDisplay.asm"
incsrc "../routines/logic/assstanley.asm"
incsrc "../routines/video/addframe_full.asm"
incsrc "../routines/penalty/RemovePlayerFromList.asm"
incsrc "../routines/logic/asscenterd.asm"
incsrc "../routines/hockey/box.asm"
incsrc "../routines/hockey/UpdateCwdExcite.asm"
incsrc "../routines/hockey/CheckLateGameSong.asm"
incsrc "../routines/penalty/loadTeamStruct.asm"
incsrc "../routines/hockey/ScoutingReport.asm"
incsrc "../routines/hockey/PrintScoutRatings.asm"

ScoutLabels:						;scouting labels: the rating names of the scouting report; a $FF string
									;ends the list
	%String("Shooting")
	%String("Skating")
	%String("Passing")
	%String("Defense")
	%String("Checking")
	%String("Fighting")
	%String("Goalkeeping")
	%String("Power Play Adv.")
	%String("-    Home Team Adv.    ")
	%String("Overall")
	%StringCC($FF)

incsrc "../routines/hockey/PuckcSpots.asm"
incsrc "../routines/penalty/SetupTeamForIntermission.asm"
incsrc "../routines/video/ClearSprites.asm"
incsrc "../routines/video/remap.asm"

PixelRemap8F:						;4bpp pixel value remap for remap: color 1 stays, the rest 0
	db $00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

incsrc "../routines/logic/playeracc.asm"
incsrc "../routines/logic/dirtab8F.asm"
incsrc "../routines/penalty/ClearPenaltyBuffer.asm"
incsrc "../routines/middle/randomd0s.asm"
incsrc "../routines/hockey/DefaultMenus.asm"
incsrc "../routines/hockey/checkagr.asm"
incsrc "../routines/middle/WeightedRandomSelect.asm"
incsrc "../routines/middle/forceblack.asm"
incsrc "../routines/logic/passmode.asm"
incsrc "../routines/logic/dopass.asm"

FrameSetTable:						;long pointers to the 15 sprite frame sets (addframe), then a 0
									;entry
	dd SpriteSet0
	dd SpriteSet1
	dd SpriteSet2
	dd SpriteSet3
	dd SpriteSet4
	dd SpriteSet5
	dd SpriteSet6
	dd SpriteSet7
	dd SpriteSet8
	dd SpriteSet9
	dd SpriteSet10
	dd SpriteSet11
	dd SpriteSet12
	dd SpriteSet13
	dd SpriteSet14
	dd 0							; end

incsrc "../routines/logic/CompLine.asm"
incsrc "../routines/stats/TeamRosterScreen.asm"
incsrc "../routines/stats/RosterGoalies.asm"
incsrc "../routines/stats/RosterG.asm"

RosterLineNames:					;the Team Roster line names (15-byte strings)
	%String("  Goalies   }")
	%String("{Scoring  1 }")
	%String("{Scoring  2 }")
	%String("{ Checking  }")
	%String("{Pwr. Play 1}")
	%String("{Pwr. Play 2}")
	%String("{Pen. Kill 1}")
	%String("{Pen. Kill 2 ")

incsrc "../routines/video/addframe.asm"
incsrc "../routines/hockey/Pmenu.asm"
incsrc "../routines/hockey/seta2.asm"
incsrc "../routines/hockey/setpde.asm"
incsrc "../routines/hockey/setoptions.asm"

PixelRemapFramer:					;remap table for the Framer tiles (setoptions)
	db $00,$01,$0A,$03,$04,$05,$06,$02,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F

PixelRemapFont:						;remap table for the small font (setoptions)
	db $00,$0F,$00,$00,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F

incsrc "../routines/middle/UnpackNibbles.asm"
incsrc "../routines/print/PushNumberWidth.asm"
incsrc "../routines/penalty/SetHor_rink.asm"
incsrc "../routines/logic/Findhittype.asm"
incsrc "../routines/penalty/prefmes.asm"
incsrc "../routines/hockey/CheckInjury.asm"
incsrc "../routines/hockey/setInjuryType.asm"
incsrc "../routines/tables/sublist.asm"
incsrc "../routines/tables/priolist.asm"
incsrc "../routines/hockey/ShowInjuryBox.asm"
incsrc "../routines/logic/passtoa0.asm"
incsrc "../routines/stats/GetPlayerCount.asm"
incsrc "../routines/hockey/GetPlayerNumInitial.asm"
incsrc "../routines/logic/Acheck.asm"
incsrc "../routines/middle/divs16.asm"
incsrc "../routines/logic/doplayeracc.asm"
incsrc "../routines/logic/ResetAndSelectPlayers.asm"
incsrc "../routines/tables/cd0.asm"
incsrc "../routines/sound/MusicCue.asm"
incsrc "../routines/sound/sfx8F.asm"
incsrc "../routines/hockey/ShowGoalBox.asm"

GoalBoxText:						;printbig strings of ShowGoalBox: GOAL!, then HAT TRICK!
	%StringCtc(CC_Font1Pri,$0F,$03,"GOAL!",CC_Font1Pri,$0C,$05)
	%StringCtc(CC_Font1Pri,$0C,$03,"HAT TRICK!",CC_Font1Pri,$0C,$05)
unusedFF8F:							;the end of the ROM: zero fill
	db 0,0,0,0,0
