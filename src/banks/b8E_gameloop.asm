; Bank $8E: gameloop. Files in ROM order (docs/file-map.md).

if pc() < $8E8000
	org $8E8000
endif
incsrc "../routines/hockey/Gameloop.asm"
incsrc "../routines/hockey/FormatPlayerNumInitial.asm"
incsrc "../routines/logic/assbench.asm"
SpriteSet3:							;frame set 3 (SPFcelebrate, SPFpump, SPFcup): frames 185-224
	incbin "../../Extracted/Graphics/Sprites/Sprites03.sanim"
SpriteSet14:						;frame set 14: frames 659-720, 6-byte pieces (DrawFrameHi)
	incbin "../../Extracted/Graphics/Sprites/Sprites14.sanim"
incsrc "../routines/logic/assdefo.asm"
