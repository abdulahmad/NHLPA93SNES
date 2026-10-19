; Bank $8E: celebration and cup sprites (set 3), the crowd sprites (set 14), and the main game loop. Files
; in ROM order (docs/file-map.md).

if pc() < $8E8000
	org $8E8000
endif
incsrc "../routines/hockey/game/Gameloop.asm"
incsrc "../routines/hockey/teams/FormatPlayerNumInitial.asm"
incsrc "../routines/logic/assignments/assbench.asm"
SpriteSet3:							;frame set 3 (SPFcelebrate, SPFpump, SPFcup): frames 185-224
	incbin "../../Extracted/Graphics/Sprites/Sprites185_224.sanim"
SpriteSet14:						;frame set 14: frames 659-720, 6-byte pieces (DrawFrameHi)
	incbin "../../Extracted/Graphics/Sprites/Sprites659_720.sanim"
incsrc "../routines/logic/assignments/assdefo.asm"
