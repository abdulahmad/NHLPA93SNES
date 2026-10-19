; Bank $8B: opening. Files in ROM order (docs/file-map.md).

if pc() < $8B8000
	org $8B8000
endif
incsrc "../routines/hockey/NewPO.asm"
incsrc "../routines/hockey/FigureJoy.asm"
incsrc "../routines/hockey/Opening.asm"
incsrc "../routines/hockey/Opening4.asm"
incsrc "../routines/hockey/ReadPassBits.asm"
incsrc "../routines/hockey/ResolveGames.asm"
SpriteSet5:							;frame set 5 (falls: SPFfallback, SPFfallfwd): frames 273-336
	incbin "../../Extracted/Graphics/Sprites/Sprites273_336.sanim"
incsrc "../routines/print/printbig.asm"
incsrc "../routines/logic/asswingo.asm"
incsrc "../routines/video/showref.asm"
incsrc "../routines/logic/skatetopuckinit.asm"
