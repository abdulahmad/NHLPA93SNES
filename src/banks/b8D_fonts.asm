; Bank $8D: fonts. Files in ROM order (docs/file-map.md).

if pc() < $8D8000
	org $8D8000
endif
incsrc "../routines/hockey/maketree.asm"
incsrc "../routines/video/InitPPU.asm"
incsrc "../routines/hockey/StartPer.asm"
incsrc "../routines/penalty/GetLowestPen.asm"
incsrc "../routines/hockey/Bcheck.asm"
incsrc "../routines/hockey/ContinuePlayoffs.asm"
incsrc "../routines/print/eraser.asm"
incsrc "../routines/hockey/DrawTeamBlocks.asm"
incsrc "../routines/penalty/EASNLogo.asm"
incsrc "../routines/hockey/PeriodOver.asm"
incsrc "../routines/hockey/GetPlayerName.asm"
incsrc "../routines/video/updatesound.asm"
incsrc "../routines/tables/asstab.asm"
incsrc "../routines/middle/mulu16.asm"
incsrc "../routines/logic/puckshadow.asm"
incsrc "../routines/hockey/setd0player.asm"

SpriteSet10:						;frame set 10: frames 462-517
	dw 56							; frames
	dw 388							; pieces
	dw 768							; tiles
	dw .pieces-SpriteSet10
	dw .tiles-SpriteSet10
.frames:							;first piece of each frame (+1 entry for the end)
	dw 0,9,18,26,33,42,49,57
	dw 64,72,80,83,91,99,104,112
	dw 120,130,135,143,152,158,164,171
	dw 176,180,184,192,196,202,208,216
	dw 224,230,236,244,251,258,264,270
	dw 275,283,292,298,305,311,316,327
	dw 339,345,349,355,360,367,373,380
	dw 388
.pieces:							;x, y, tile, attributes per piece
	incbin "../../Extracted/Graphics/Sprites/set10.pieces"
	assert .tiles-.pieces == 4*388
.tiles:								;768 4bpp tiles (32 bytes each)
	incbin "../../Extracted/Graphics/Sprites/set10.chr"
SpriteSet10End:						; end of SpriteSet10
	assert SpriteSet10End-SpriteSet10 == $68C+768*32

BigFontTiles:						;the big font tiles (144 tiles, BigFont.chr.pak),
									;packed; setupice sends them to BigFontChars (PixelRemap8D), printbig
									;draws them
	incbin "../../Extracted/Graphics/BigFont.chr.pak"
BigFontTilesEnd:					; end of BigFontTiles
	assert BigFontTilesEnd-BigFontTiles == $9C0

incsrc "../routines/penalty/StartHL2.asm"
incsrc "../routines/logic/asspenalty.asm"
incsrc "../routines/logic/clrplayer.asm"
incsrc "../routines/logic/avdgoal.asm"
