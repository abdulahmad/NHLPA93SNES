; Bank $85: title gfx. Files in ROM order (docs/file-map.md).

if pc() < $858000
	org $858000
endif
incsrc "../data/gfx/SpriteSet4.asm"
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
