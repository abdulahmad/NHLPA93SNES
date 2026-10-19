; Bank $85: title gfx. Files in ROM order (docs/file-map.md).

if pc() < $858000
	org $858000
endif
SpriteSet4:							;frame set 4 (hip, shoulder and sweep checks): frames 225-272
	incbin "../../Extracted/Graphics/Sprites/Sprites225_272.sanim"
incsrc "../routines/hockey/GetShifter.asm"

Title1Map:							;the title screen backdrop, packed (map, palette, tiles)
	incbin "../../Extracted/Graphics/Title1.map.sjim"

incsrc "../routines/video/DrawFrameHi.asm"
incsrc "../routines/hockey/getpzjoy.asm"
incsrc "../routines/hockey/PrintTeamNames.asm"
incsrc "../routines/hockey/nullrtl85.asm"
incsrc "../routines/hockey/ResetClock.asm"
