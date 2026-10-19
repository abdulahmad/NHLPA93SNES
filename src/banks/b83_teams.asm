; Bank $83: teams. Files in ROM order (docs/file-map.md).

if pc() < $838000
	org $838000
endif
incsrc "../data/teamdata93s.asm"

SmallFontTiles:						;packed small font tiles (100 4bpp tiles, the print font of SmallFontMap;
									;setupice and banks $83/$88/$8F unpack them, PixelRemap83)
	incbin "../../Extracted/Graphics/SmallFont.chr.pak"
SmallFontTilesEnd:					; end of SmallFontTiles

incsrc "../routines/hockey/getname.asm"

IceRinkMap:							;the vertical rink tile map: 48 x 85 words (8160 bytes,
									;IceRink.snesmap). Rows go to vram as Vpos scrolls (ShowRinkRows)
	incbin "../../Extracted/Graphics/IceRink.snesmap"

HorRinkMap:							;horizontal rink tile map, 48 x 28 words
	incbin "../../Extracted/Graphics/IceRinkHor.snesmap"

RinkPalette:						;the game palette: 128 colors (Rink.snespal), copied to both
									;halves of palbuffer by setupice
	incbin "../../Extracted/Graphics/Pals/Rink.snespal"

incsrc "../routines/hockey/Pausemode.asm"
incsrc "../routines/hockey/PauseMenu.asm"
incsrc "../routines/hockey/PauseReadJoy.asm"
incsrc "../routines/hockey/PauseResume.asm"
incsrc "../routines/hockey/PauseLeave.asm"
incsrc "../routines/hockey/Opening2.asm"

RefsMap:							;the ref window frames, 7 frames of 8 x 7 words (Refs.snesmap);
									;PushRef copies frame d0 (+$70 each)
	incbin "../../Extracted/Graphics/Refs.snesmap"

incsrc "../routines/logic/assgoalietopuck.asm"
