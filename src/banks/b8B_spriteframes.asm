; Bank $8B: sweep check and fall sprites (set 5) and the opening routines. Files in ROM order
; (docs/file-map.md).

if pc() < $8B8000
	org $8B8000
endif
incsrc "../routines/hockey/playoffs/NewPO.asm"
incsrc "../routines/hockey/input/FigureJoy.asm"
incsrc "../routines/hockey/screens/Opening.asm"
incsrc "../routines/hockey/screens/Opening4.asm"
incsrc "../routines/hockey/password/ReadPassBits.asm"
incsrc "../routines/hockey/playoffs/ResolveGames.asm"
SpriteSet5:							;frame set 5 (falls: SPFfallback, SPFfallfwd): frames 273-336
	incbin "../../Extracted/Graphics/Sprites/Sprites273_336.sanim"
incsrc "../routines/print/printbig.asm"
incsrc "../routines/logic/assignments/asswingo.asm"
incsrc "../routines/video/hud/showref.asm"
incsrc "../routines/logic/skating/skatetopuckinit.asm"
