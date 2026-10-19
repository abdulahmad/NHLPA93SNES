; Bank $8C: skate sprites (frame set 0) and the NHLPA logo. Files in ROM order (docs/file-map.md).

if pc() < $8C8000
	org $8C8000
endif
incsrc "../data/gfx/NHLPALogo.asm"
incsrc "../data/gfx/SpriteSet0.asm"
incsrc "../routines/video/checksso.asm"
incsrc "../routines/logic/chk4pass.asm"
