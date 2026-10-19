Teamblocksmap:						;TeamBlocks.map: one 9 x 2 tile block per team (palette 1, tiles from
									;TeamBlocksTiles), 36 bytes each (read by PlayoffScreen and
									;DrawTeamBlocks)
									;team 0
	incbin "../../../Extracted/Graphics/TeamBlocks.snesmap"
TeamblocksmapEnd:
	assert (TeamblocksmapEnd-Teamblocksmap)/36 == NumofTeams
