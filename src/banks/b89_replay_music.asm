; Bank $89: replay music. Files in ROM order (docs/file-map.md).

if pc() < $898000
	org $898000
endif

SpriteSet11:						;frame set 11 (goal siren): frames 518-531
	dw 14							; frames
	dw 50							; pieces
	dw 128							; tiles
	dw .pieces-SpriteSet11
	dw .tiles-SpriteSet11
.frames:							;first piece of each frame (+1 entry for the end)
	dw 0,2,5,8,16,19,22,24
	dw 28,32,35,39,42,46,50
.pieces:							;x, y, tile, attributes per piece
	incbin "../../Extracted/Graphics/Sprites/set11.pieces"
	assert .tiles-.pieces == 4*50
.tiles:								;128 4bpp tiles (32 bytes each)
	incbin "../../Extracted/Graphics/Sprites/set11.chr"
SpriteSet11End:						; end of SpriteSet11
	assert SpriteSet11End-SpriteSet11 == $F0+128*32

incsrc "../routines/hockey/ReplayMode.asm"

SpriteSet13:						;frame set 13 (goalie catch, glass and save): frames 606-658
	dw 53							; frames
	dw 345							; pieces
	dw 640							; tiles
	dw .pieces-SpriteSet13
	dw .tiles-SpriteSet13
.frames:							;first piece of each frame (+1 entry for the end)
	dw 0,6,9,12,15,18,21,25
	dw 30,34,37,40,43,49,55,60
	dw 64,66,74,83,91,97,101,104
	dw 107,113,121,126,134,141,151,161
	dw 167,176,184,191,199,207,214,222
	dw 228,239,248,257,267,276,284,293
	dw 304,313,325,332,339,345
.pieces:							;x, y, tile, attributes per piece
	incbin "../../Extracted/Graphics/Sprites/set13.pieces"
	assert .tiles-.pieces == 4*345
.tiles:								;640 4bpp tiles (32 bytes each)
	incbin "../../Extracted/Graphics/Sprites/set13.chr"
SpriteSet13End:						; end of SpriteSet13
	assert SpriteSet13End-SpriteSet13 == $5DA+640*32

incsrc "../routines/penalty/printscores1.asm"
incsrc "../routines/penalty/PrintPerLabel.asm"
incsrc "../routines/penalty/PrintTeamNameAndScore.asm"
incsrc "../routines/penalty/nullrtl89.asm"
incsrc "../routines/sound/p_music_vblank.asm"

RefTilesHor:						;packed ref window tiles for the horizontal rink (104 tiles,
									;RefHor.chr.pak): setupice sends them to refcharshor
	incbin "../../Extracted/Graphics/RefHor.chr.pak"
RefTilesHorEnd:						; end of RefTilesHor
	assert RefTilesHorEnd-RefTilesHor == $8B6

RefsMapHor:							;ref window frames for the horizontal rink, 17 frames of 8 x 7 words
									;(RefsHor.snesmap); PushRef uses it when sfhormode
	incbin "../../Extracted/Graphics/RefsHor.snesmap"
RefsMapHorEnd:						; end of RefsMapHor
	assert RefsMapHorEnd-RefsMapHor == 17*$70

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
