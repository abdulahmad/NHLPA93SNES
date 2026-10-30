; Bank $88: fight, goal and puck sprites (sets 7 and 8), the team block tiles, and the title, playoff and
; password routines. Files in ROM order (docs/file-map.md).

if pc() < $888000
	org $888000
endif

GameSetUpMap:						;the game setup screen backdrop (two team boxes, options box),
									;packed: 32 x 32 map, 128 colors at $800, 18 tiles at $900
	incbin "../../Extracted/Graphics/GameSetUp.map.sjim"

SmallFontMap:						;print character (0-127) -> small font tile (+ flip bits), added to
									;smallfontchars by print
	incbin "../../Extracted/Graphics/SmallFont.smap"

incsrc "../routines/middle/math/mulu32.asm"
incsrc "../routines/penalty/energy/getlinee.asm"
incsrc "../routines/hockey/password/WritePassBits.asm"
incsrc "../routines/logic/skating/noturn0.asm"
incsrc "../routines/hockey/password/PWprint.asm"
incsrc "../routines/hockey/password/EncodePW.asm"

FramerMap:							;Framer.map.jim: the 3 x 3 box pieces (corner, edge, side, centre) from
									;the 4 FramerTiles with flips (Framer_piece)
	incbin "../../Extracted/Graphics/Framer.smap"

FramerTiles:						;the 4 Framer box tiles (4bpp, Framer.chr): sent to vram by
									;ScoutingReport; setupice remaps them with PixelRemap87
	incbin "../../Extracted/Graphics/Framer.chr"

incsrc "../routines/video/crowd/showcrowd.asm"
incsrc "../routines/hockey/password/SuperMult.asm"
incsrc "../routines/hockey/screens/setoptions_drawback.asm"
incsrc "../routines/middle/math/mulu.asm"
SpriteSet8:							;frame set 8 (arrows, pads, puck and goal): frames 384-405
	incbin "../../Extracted/Graphics/Sprites/Sprites384_405.sanim"

TeamBlocksTiles:					;TeamBlocks.map.jim tiles: 405 team name banner tiles, packed ($32A0 bytes
									;unpacked); sent to vram by PlayoffScreen, the scouting report and
									;setoptions
	incbin "../../Extracted/Graphics/TeamBlocks.chr.pak"

SpriteSet7:							;frame set 7 (gloves, fight, injury and penalty box): frames 353-383
	incbin "../../Extracted/Graphics/Sprites/Sprites353_383.sanim"
incsrc "../routines/hockey/password/GetPassWord.asm"
incsrc "../data/text/PasswordText.asm"
incsrc "../routines/hockey/screens/TitleScreen.asm"
incsrc "../data/text/CreditsBlank.asm"
incsrc "../routines/hockey/playoffs/PlayoffScreen.asm"
incsrc "../routines/tables/PlayoffTreeSetup.asm"
incsrc "../routines/logic/assignments/assdefd.asm"
incsrc "../routines/hockey/password/SuperAdd.asm"
incsrc "../routines/logic/skating/skateto.asm"
