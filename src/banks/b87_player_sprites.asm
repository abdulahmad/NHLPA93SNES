; Bank $87: player sprites. Files in ROM order (docs/file-map.md).

if pc() < $878000
	org $878000
endif
SpriteSet2:							;frame set 2 (stop and skate backwards): frames 145-184
	incbin "../../Extracted/Graphics/Sprites/Sprites145_184.sanim"

EASNmap:							;EASN.map.jim: the EASN logo backdrop, packed (decompressor
									;DecompressBytecode): a 32 x 16 map, then the tiles; unpacked by the
									;scouting report and team roster screens
	incbin "../../Extracted/Graphics/EASN.map.sjim"

FaceOffTiles:						;packed faceoff box tiles (55, FaceOff.map.jim tiles): setupice sends them
									;to faceoffvrcset
	incbin "../../Extracted/Graphics/FaceOff.chr.pak"

Teamblocksmap:						;TeamBlocks.map: one 9 x 2 tile block per team (palette 1, tiles from
									;TeamBlocksTiles), 36 bytes each (read by PlayoffScreen and
									;DrawTeamBlocks)
									;team 0
	incbin "../../Extracted/Graphics/TeamBlocks.smap"
TeamblocksmapEnd:					; end of Teamblocksmap
	assert (TeamblocksmapEnd-Teamblocksmap)/36 == NumofTeams

incsrc "../routines/video/DrawFrame.asm"
incsrc "../routines/video/addframe_end.asm"
SpriteSet6:							;frame set 6 (duck and hold): frames 337-352
	incbin "../../Extracted/Graphics/Sprites/Sprites337_352.sanim"
incsrc "../routines/hockey/RestoreReplayFrame.asm"
incsrc "../data/gfx/PixelRemap87.asm"

RefTiles:							;packed ref window tiles for the vertical rink (117):
									;setupice sends them to refchars
	incbin "../../Extracted/Graphics/Ref.chr.pak"

incsrc "../routines/logic/assepen.asm"
