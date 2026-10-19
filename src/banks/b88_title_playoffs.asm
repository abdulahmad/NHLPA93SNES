; Bank $88: title playoffs. Files in ROM order (docs/file-map.md).

if pc() < $888000
	org $888000
endif

GameSetUpMap:						;the game setup screen backdrop (two team boxes, options box),
									;packed: 32 x 32 map, 128 colors at $800, 18 tiles at $900
	incbin "../../Extracted/Graphics/GameSetUp.map.snesjim"
GameSetupMapEnd:					; end of GameSetupMap
	assert GameSetupMapEnd-GameSetUpMap == $22F

SmallFontMap:						;print character (0-127) -> small font tile (+ flip bits), added to
									;smallfontchars by print
	incbin "../../Extracted/Graphics/SmallFont.snesmap"
SmallFontMapEnd:					; end of SmallFontMap
	assert SmallFontMapEnd-SmallFontMap == 256

incsrc "../routines/middle/mulu32.asm"
incsrc "../routines/penalty/getlinee.asm"
incsrc "../routines/hockey/WritePassBits.asm"
incsrc "../routines/logic/noturn0.asm"
incsrc "../routines/hockey/PWprint.asm"
incsrc "../routines/hockey/EncodePW.asm"

FramerMap:							;Framer.map.jim: the 3 x 3 box pieces (corner, edge, side, centre) from
									;the 4 FramerTiles with flips (Framer_piece)
	incbin "../../Extracted/Graphics/Framer.snesmap"
FramerMapEnd:						; end of FramerMap
	assert FramerMapEnd-FramerMap == 18

FramerTiles:						;the 4 Framer box tiles (4bpp, Framer.chr): sent to vram by
									;ScoutingReport; setupice remaps them with PixelRemap87
	incbin "../../Extracted/Graphics/Framer.chr"

incsrc "../routines/video/showcrowd.asm"
incsrc "../routines/hockey/SuperMult.asm"
incsrc "../routines/hockey/DrawGameSetupBack.asm"
incsrc "../routines/middle/mulu.asm"

SpriteSet8:							;frame set 8 (arrows, pads, puck and goal): frames 384-405
	dw 22							; frames
	dw 75							; pieces
	dw 128							; tiles
	dw .pieces-SpriteSet8
	dw .tiles-SpriteSet8
.frames:							;first piece of each frame (+1 entry for the end)
	dw 0,6,12,18,24,30,36,38
	dw 40,42,43,44,45,46,47,48
	dw 49,50,51,52,53,63,75
.pieces:							;x, y, tile, attributes per piece
	incbin "../../Extracted/Graphics/Sprites/set08.pieces"
	assert .tiles-.pieces == 4*75
.tiles:								;128 4bpp tiles (32 bytes each)
	incbin "../../Extracted/Graphics/Sprites/set08.chr"
SpriteSet8End:						; end of SpriteSet8
	assert SpriteSet8End-SpriteSet8 == $164+128*32

TeamBlocksTiles:					;TeamBlocks.map.jim tiles: 405 team name banner tiles, packed ($32A0 bytes
									;unpacked); sent to vram by PlayoffScreen, the scouting report and
									;setoptions
	incbin "../../Extracted/Graphics/TeamBlocks.chr.pak"
TeamBlocksTilesEnd:					; end of TeamBlocksTiles
	assert TeamBlocksTilesEnd-TeamBlocksTiles == $20E3

SpriteSet7:							;frame set 7 (gloves, fight, injury and penalty box): frames 353-383
	dw 31							; frames
	dw 191							; pieces
	dw 384							; tiles
	dw .pieces-SpriteSet7
	dw .tiles-SpriteSet7
.frames:							;first piece of each frame (+1 entry for the end)
	dw 0,12,17,23,27,32,37,46
	dw 54,59,64,72,79,85,89,94
	dw 98,106,111,115,120,126,130,135
	dw 141,150,159,167,174,181,186,191
.pieces:							;x, y, tile, attributes per piece
	incbin "../../Extracted/Graphics/Sprites/set07.pieces"
	assert .tiles-.pieces == 4*191
.tiles:								;384 4bpp tiles (32 bytes each)
	incbin "../../Extracted/Graphics/Sprites/set07.chr"
SpriteSet7End:						; end of SpriteSet7
	assert SpriteSet7End-SpriteSet7 == $346+384*32

incsrc "../routines/hockey/GetPassWord.asm"

PasswordText:						;"Password" at 2, 14, "Press Start" at 10, 24, then print at 21, 14; then
									;an empty string ends it
	%StringCtctc(CC_Font1,2,14,"Password",CC_Font1,10,24,"Press Start",CC_Font1,21,14)
	%StringCC(0)

incsrc "../routines/hockey/TitleScreen.asm"

CreditsBlank:						;print string of 32 blanks: TitleScreen erases the rows below the credits
									;with it
	%String("                                ")

incsrc "../routines/hockey/PlayoffScreen.asm"
incsrc "../routines/tables/PlayoffTreeSetup.asm"
incsrc "../routines/logic/assdefd.asm"
incsrc "../routines/hockey/SuperAdd.asm"
incsrc "../routines/logic/skateto.asm"
