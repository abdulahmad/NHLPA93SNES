; Bank $8E: gameloop. Files in ROM order (docs/file_map.md).

if pc() < $8E8000
	org $8E8000
endif
incsrc "../routines/hockey/Gameloop.asm"
incsrc "../routines/hockey/PlayerShortName.asm"
incsrc "../routines/logic/assbench.asm"
incsrc "../data/gfx/SpriteSet3.asm"
incsrc "../data/gfx/SpriteSet14.asm"
incsrc "../routines/logic/assdefo.asm"
