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
	dw 64							; frames
	dw 533							; pieces
	dw 896							; tiles
	dw .pieces-SpriteSet5
	dw .tiles-SpriteSet5
.frames:							;first piece of each frame (+1 entry for the end)
	dw 0,5,13,24,31,36,42,50
	dw 57,65,74,83,91,98,108,117
	dw 124,132,142,152,161,167,177,187
	dw 196,205,212,221,229,234,244,253
	dw 260,263,271,278,283,292,303,314
	dw 321,331,341,349,356,365,375,384
	dw 391,398,408,416,423,432,443,455
	dw 463,471,482,490,498,505,515,526
	dw 533
.pieces:							;x, y, tile, attributes per piece
	incbin "../../Extracted/Graphics/Sprites/set05.pieces"
	assert .tiles-.pieces == 4*533
.tiles:								;896 4bpp tiles (32 bytes each)
	incbin "../../Extracted/Graphics/Sprites/set05.chr"
SpriteSet5End:						; end of SpriteSet5
	assert SpriteSet5End-SpriteSet5 == $8E0+896*32

incsrc "../routines/print/printbig.asm"
incsrc "../routines/logic/asswingo.asm"
incsrc "../routines/video/showref.asm"
incsrc "../routines/logic/skatetopuckinit.asm"
