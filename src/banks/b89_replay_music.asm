; Bank $89: replay music. Files in ROM order (docs/file-map.md).

if pc() < $898000
	org $898000
endif
SpriteSet11:						;frame set 11 (goal siren): frames 518-531
	incbin "../../Extracted/Graphics/Sprites/Sprites11.sanim"
incsrc "../routines/hockey/ReplayMode.asm"
SpriteSet13:						;frame set 13 (goalie catch, glass and save): frames 606-658
	incbin "../../Extracted/Graphics/Sprites/Sprites13.sanim"
incsrc "../routines/penalty/printscores1.asm"
incsrc "../routines/penalty/PrintPerLabel.asm"
incsrc "../routines/penalty/PrintTeamNameAndScore.asm"
incsrc "../routines/penalty/nullrtl89.asm"
incsrc "../routines/sound/p_music_vblank.asm"

RefTilesHor:						;packed ref window tiles for the horizontal rink (104 tiles,
									;RefHor.chr.pak): setupice sends them to refcharshor
	incbin "../../Extracted/Graphics/RefHor.chr.pak"

RefsMapHor:							;ref window frames for the horizontal rink, 17 frames of 8 x 7 words
									;(RefsHor.smap); PushRef uses it when sfhormode
	incbin "../../Extracted/Graphics/RefsHor.smap"

incsrc "../routines/sound/StartSong8.asm"
incsrc "../routines/sound/StartSong9.asm"
incsrc "../routines/sound/StartSong1.asm"
incsrc "../routines/sound/StartSong2.asm"
incsrc "../routines/sound/StartSong3.asm"
incsrc "../routines/sound/StartSong4.asm"
incsrc "../routines/sound/StartSong5.asm"
incsrc "../routines/middle/CopyWords.asm"
incsrc "../routines/hockey/ClearRosterName.asm"
incsrc "../routines/hockey/GetRosterEntry89.asm"
incsrc "../routines/hockey/FinalizeTextBuffer.asm"
incsrc "../routines/hockey/StartGame.asm"
incsrc "../routines/hockey/restoreteams.asm"
incsrc "../routines/logic/EvadePC.asm"
incsrc "../routines/logic/asswingd.asm"
