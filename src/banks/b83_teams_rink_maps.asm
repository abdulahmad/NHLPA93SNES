; Bank $83: the team data, the rink and ref maps, the small font tiles. Files in ROM order
; (docs/file-map.md).

if pc() < $838000
	org $838000
endif
incsrc "../data/teamdata93s.asm"

SmallFontTiles:						;packed small font tiles (100 4bpp tiles, the print font of SmallFontMap;
									;setupice and banks $83/$88/$8F unpack them, PixelRemap83)
	incbin "../../Extracted/Graphics/SmallFont.chr.pak"
SmallFontTilesEnd:					; end of SmallFontTiles

incsrc "../routines/hockey/teams/getname.asm"

IceRinkMap:							;the vertical rink tile map: 48 x 85 words (8160 bytes,
									;IceRink.smap). Rows go to vram as Vpos scrolls (ShowRinkRows)
	incbin "../../Extracted/Graphics/IceRink.smap"

HorRinkMap:							;horizontal rink tile map, 48 x 28 words
	incbin "../../Extracted/Graphics/IceRinkHor.smap"

RinkPalette:						;the game palette: 128 colors (Rink.spal), copied to both
									;halves of palbuffer by setupice
	incbin "../../Extracted/Graphics/Pals/Rink.spal"

incsrc "../routines/hockey/screens/Pausemode.asm"
incsrc "../routines/hockey/screens/PauseMenu.asm"
incsrc "../routines/hockey/screens/PauseReadJoy.asm"
incsrc "../routines/hockey/screens/PauseResume.asm"
incsrc "../routines/hockey/screens/PauseLeave.asm"
incsrc "../routines/hockey/screens/Opening2.asm"

RefsMap:							;the ref window frames, 7 frames of 8 x 7 words (Refs.smap);
									;PushRef copies frame d0 (+$70 each)
	incbin "../../Extracted/Graphics/Refs.smap"

incsrc "../routines/logic/assignments/assgoalietopuck.asm"
