; Bank $89: goalie save sprites (sets 11 and 13), the horizontal ref tiles, and the replay and music
; routines. Files in ROM order (docs/file-map.md).

if pc() < $898000
	org $898000
endif
SpriteSet11:						;frame set 11 (goal siren): frames 518-531
	incbin "../../Extracted/Graphics/Sprites/Sprites518_531.sanim"
incsrc "../routines/hockey/replay/ReplayMode.asm"
SpriteSet13:						;frame set 13 (goalie catch, glass and save): frames 606-658
	incbin "../../Extracted/Graphics/Sprites/Sprites606_658.sanim"
incsrc "../routines/penalty/scoreboard/printscores1.asm"
incsrc "../routines/penalty/scoreboard/PrintPerLabel.asm"
incsrc "../routines/penalty/scoreboard/PrintTeamNameAndScore.asm"
incsrc "../routines/penalty/util/nullrtl89.asm"
incsrc "../routines/sound/p_music_vblank.asm"

RefTilesHor:						;packed ref window tiles for the horizontal rink (104 tiles,
									;Ref2.chr.pak): setupice sends them to refcharshor
	incbin "../../Extracted/Graphics/Ref2.chr.pak"

RefsMapHor:							;ref window frames for the horizontal rink, 17 frames of 8 x 7 words
									;(Refs2.smap); PushRef uses it when sfhormode
	incbin "../../Extracted/Graphics/Refs2.smap"

incsrc "../routines/sound/StartSngEOG.asm"
incsrc "../routines/sound/StartSngPO.asm"
incsrc "../routines/sound/StartSngGoal.asm"
incsrc "../routines/sound/StartSngPeriodStart.asm"
incsrc "../routines/sound/StartSngLateGame.asm"
incsrc "../routines/sound/StartSngPP.asm"
incsrc "../routines/sound/StartSngFaceoff.asm"
incsrc "../routines/middle/util/CopyWords.asm"
incsrc "../routines/hockey/teams/ClearRosterName.asm"
incsrc "../routines/hockey/teams/GetRosterEntry89.asm"
incsrc "../routines/print/FinalizeTextBuffer.asm"
incsrc "../routines/hockey/game/StartGame.asm"
incsrc "../routines/hockey/game/restoreteams.asm"
incsrc "../routines/logic/skating/EvadePC.asm"
incsrc "../routines/logic/assignments/asswingd.asm"
