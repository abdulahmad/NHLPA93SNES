; Bank $87: player sprites. Files in ROM order (docs/file_map.md).

if pc() < $878000
	org $878000
endif
incsrc "../data/gfx/SpriteSet2.asm"
incsrc "../data/gfx/EASNMap.asm"
incsrc "../data/gfx/FaceOffTiles.asm"
incsrc "../data/gfx/TeamBlocksMap.asm"
incsrc "../routines/video/DrawFrame.asm"
incsrc "../routines/video/addframe_end.asm"
incsrc "../data/gfx/SpriteSet6.asm"
incsrc "../routines/hockey/RestoreReplayFrame.asm"
incsrc "../data/gfx/PixelRemap87.asm"
incsrc "../data/gfx/RefTiles.asm"
incsrc "../routines/logic/assepen.asm"
