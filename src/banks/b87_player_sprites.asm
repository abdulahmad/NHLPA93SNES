; Bank $87: player sprites. Files in ROM order (docs/file-map.md).

if pc() < $878000
	org $878000
endif

SpriteSet2:							;frame set 2 (stop and skate backwards): frames 145-184
	dw 40							; frames
	dw 209							; pieces
	dw 512							; tiles
	dw .pieces-SpriteSet2
	dw .tiles-SpriteSet2
.frames:							;first piece of each frame (+1 entry for the end)
	dw 0,3,6,14,22,33,44,50
	dw 56,60,64,69,74,80,86,92
	dw 98,100,104,107,112,118,122,127
	dw 132,137,141,145,151,155,161,166
	dw 171,176,179,184,189,194,199,204
	dw 209
.pieces:							;x, y, tile, attributes per piece
	incbin "../../Extracted/Graphics/Sprites/set02.pieces"
	assert .tiles-.pieces == 4*209
.tiles:								;512 4bpp tiles (32 bytes each)
	incbin "../../Extracted/Graphics/Sprites/set02.chr"
SpriteSet2End:						; end of SpriteSet2
	assert SpriteSet2End-SpriteSet2 == $3A0+512*32

EASNmap:							;EASN.map.jim: the EASN logo backdrop, packed (decompressor
									;DecompressBytecode): a 32 x 16 map, then the tiles; unpacked by the
									;scouting report and team roster screens
	incbin "../../Extracted/Graphics/EASN.map.snesjim"

FaceOffTiles:						;packed faceoff box tiles (55, FaceOff.map.jim tiles): setupice sends them
									;to faceoffvrcset
	incbin "../../Extracted/Graphics/FaceOff.chr.pak"

Teamblocksmap:						;TeamBlocks.map: one 9 x 2 tile block per team (palette 1, tiles from
									;TeamBlocksTiles), 36 bytes each (read by PlayoffScreen and
									;DrawTeamBlocks)
									;team 0
	incbin "../../Extracted/Graphics/TeamBlocks.snesmap"
TeamblocksmapEnd:					; end of Teamblocksmap
	assert (TeamblocksmapEnd-Teamblocksmap)/36 == NumofTeams

incsrc "../routines/video/DrawFrame.asm"
incsrc "../routines/video/addframe_end.asm"

SpriteSet6:							;frame set 6 (duck and hold): frames 337-352
	dw 16							; frames
	dw 110							; pieces
	dw 256							; tiles
	dw .pieces-SpriteSet6
	dw .tiles-SpriteSet6
.frames:							;first piece of each frame (+1 entry for the end)
	dw 0,8,16,23,31,40,48,54
	dw 61,65,71,80,85,91,96,103
	dw 110
.pieces:							;x, y, tile, attributes per piece
	incbin "../../Extracted/Graphics/Sprites/set06.pieces"
	assert .tiles-.pieces == 4*110
.tiles:								;256 4bpp tiles (32 bytes each)
	incbin "../../Extracted/Graphics/Sprites/set06.chr"
SpriteSet6End:						; end of SpriteSet6
	assert SpriteSet6End-SpriteSet6 == $1E4+256*32

incsrc "../routines/hockey/RestoreReplayFrame.asm"

PixelRemap87:						;4bpp pixel value remap for the 4 FramerTiles (bank $88; setupice
									;via remap): colors 0-3 only
	db $00,$03,$04,$03

RefTiles:							;packed ref window tiles for the vertical rink (117):
									;setupice sends them to refchars
	incbin "../../Extracted/Graphics/Ref.chr.pak"

incsrc "../routines/logic/assepen.asm"
