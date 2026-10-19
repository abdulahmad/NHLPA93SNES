; Bank $88: title playoffs. Files in ROM order (docs/file-map.md).

if pc() < $888000
	org $888000
endif

GameSetUpMap:						;the game setup screen backdrop (two team boxes, options box),
									;packed: 32 x 32 map, 128 colors at $800, 18 tiles at $900
	incbin "../../Extracted/Graphics/GameSetUp.map.snesjim"

SmallFontMap:						;print character (0-127) -> small font tile (+ flip bits), added to
									;smallfontchars by print
	incbin "../../Extracted/Graphics/SmallFont.snesmap"

incsrc "../routines/middle/mulu32.asm"
incsrc "../routines/penalty/getlinee.asm"
incsrc "../routines/hockey/WritePassBits.asm"
incsrc "../routines/logic/noturn0.asm"
incsrc "../routines/hockey/PWprint.asm"
incsrc "../routines/hockey/EncodePW.asm"

FramerMap:							;Framer.map.jim: the 3 x 3 box pieces (corner, edge, side, centre) from
									;the 4 FramerTiles with flips (Framer_piece)
	incbin "../../Extracted/Graphics/Framer.snesmap"

FramerTiles:						;the 4 Framer box tiles (4bpp, Framer.chr): sent to vram by
									;ScoutingReport; setupice remaps them with PixelRemap87
	incbin "../../Extracted/Graphics/Framer.chr"

incsrc "../routines/video/showcrowd.asm"
incsrc "../routines/hockey/SuperMult.asm"
incsrc "../routines/hockey/DrawGameSetupBack.asm"
incsrc "../routines/middle/mulu.asm"
incsrc "../data/gfx/SpriteSet8.asm"

TeamBlocksTiles:					;TeamBlocks.map.jim tiles: 405 team name banner tiles, packed ($32A0 bytes
									;unpacked); sent to vram by PlayoffScreen, the scouting report and
									;setoptions
	incbin "../../Extracted/Graphics/TeamBlocks.chr.pak"

incsrc "../data/gfx/SpriteSet7.asm"
incsrc "../routines/hockey/GetPassWord.asm"
incsrc "../data/text/PasswordText.asm"
incsrc "../routines/hockey/TitleScreen.asm"
incsrc "../data/text/CreditsBlank.asm"
incsrc "../routines/hockey/PlayoffScreen.asm"
incsrc "../routines/tables/PlayoffTreeSetup.asm"
incsrc "../routines/logic/assdefd.asm"
incsrc "../routines/hockey/SuperAdd.asm"
incsrc "../routines/logic/skateto.asm"
