; Bank $85: title gfx. Files in ROM order (docs/file-map.md).

if pc() < $858000
	org $858000
endif

SpriteSet4:							;frame set 4 (hip, shoulder and sweep checks): frames 225-272
	dw 48							; frames
	dw 334							; pieces
	dw 640							; tiles
	dw .pieces-SpriteSet4
	dw .tiles-SpriteSet4
.frames:							;first piece of each frame (+1 entry for the end)
	dw 0,6,12,18,24,30,37,44
	dw 50,55,58,67,74,77,79,85
	dw 90,97,104,117,130,135,143,155
	dw 165,171,177,184,194,202,209,214
	dw 220,223,229,234,242,249,258,264
	dw 273,281,288,296,303,312,321,329
	dw 334
.pieces:							;x, y, tile, attributes per piece
	incbin "../../Extracted/Graphics/Sprites/set04.pieces"
	assert .tiles-.pieces == 4*334
.tiles:								;640 4bpp tiles (32 bytes each)
	incbin "../../Extracted/Graphics/Sprites/set04.chr"
SpriteSet4End:						; end of SpriteSet4
	assert SpriteSet4End-SpriteSet4 == $5A4+640*32

incsrc "../routines/hockey/GetShifter.asm"

Title1Map:							;the title screen backdrop, packed (map, palette, tiles)
	incbin "../../Extracted/Graphics/Title1.map.snesjim"
Title1MapEnd:						; end of Title1Map
	assert Title1MapEnd-Title1Map == $25F9

incsrc "../routines/video/DrawFrameHi.asm"
incsrc "../routines/hockey/getpzjoy.asm"
incsrc "../routines/hockey/PrintTeamNames.asm"
incsrc "../routines/hockey/nullrtl85.asm"
incsrc "../routines/hockey/ResetClock.asm"
