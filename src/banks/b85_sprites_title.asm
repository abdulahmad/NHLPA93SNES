; Bank $85: the hip and shoulder check sprites (set 4) and the title screen backdrop. Files in ROM order
; (docs/file-map.md).

if pc() < $858000
	org $858000
endif
SpriteSet4:							;frame set 4 (hip, shoulder and sweep checks): frames 225-272
	incbin "../../Extracted/Graphics/Sprites/Sprites225_272.sanim"
incsrc "../routines/hockey/playoffs/GetShifter.asm"

Title1Map:							;the title screen backdrop, packed (map, palette, tiles)
	incbin "../../Extracted/Graphics/Title1.map.sjim"

incsrc "../routines/video/sprites/DrawFrameHi.asm"
incsrc "../routines/hockey/input/getpzjoy.asm"
incsrc "../routines/hockey/screens/PrintTeamNames.asm"
incsrc "../routines/hockey/util/nullrtl85.asm"
incsrc "../routines/hockey/game/ResetClock.asm"
