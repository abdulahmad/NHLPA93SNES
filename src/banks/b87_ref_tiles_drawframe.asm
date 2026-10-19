; Bank $87: player sprites (sets 2 and 6), ref and face-off tiles, the team name map. Files in ROM order
; (docs/file-map.md).

if pc() < $878000
	org $878000
endif
SpriteSet2:							;frame set 2 (stop and skate backwards): frames 145-184
	incbin "../../Extracted/Graphics/Sprites/Sprites145_184.sanim"

EASNmap:							;EASNBG.map.sjim: the EASN backdrop, packed (decompressor
									;DecompressBytecode): a 32 x 16 map, then the tiles; unpacked by the
									;scouting report and team roster screens
	incbin "../../Extracted/Graphics/EASNBG.map.sjim"

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

incsrc "../routines/video/sprites/DrawFrame.asm"
incsrc "../routines/video/sprites/addframe_end.asm"
SpriteSet6:							;frame set 6 (duck and hold): frames 337-352
	incbin "../../Extracted/Graphics/Sprites/Sprites337_352.sanim"
incsrc "../routines/hockey/replay/RestoreReplayFrame.asm"
incsrc "../data/gfx/PixelRemap87.asm"

RefTiles:							;packed ref window tiles for the vertical rink (117):
									;setupice sends them to refchars
	incbin "../../Extracted/Graphics/Ref.chr.pak"

incsrc "../routines/logic/assignments/assepen.asm"
