TeamBlocksMap:						;TeamBlocks.map: one 9 x 2 tile block per team (palette 1, tiles from
									;TeamBlocksTiles), 36 bytes each (read by PlayoffScreen and
									;DrawTeamBlocks)
									;team 0
	incbin "../../../Extracted/Graphics/TeamBlocks.snesmap"
TeamBlocksMapEnd:
	assert (TeamBlocksMapEnd-TeamBlocksMap)/36 == NumofTeams
