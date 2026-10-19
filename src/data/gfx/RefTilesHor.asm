RefTilesHor:						;packed ref window tiles for the horizontal rink (104 tiles,
									;RefHor.chr.pak): setupice sends them to refcharshor
	incbin "../../../Extracted/Graphics/RefHor.chr.pak"
RefTilesHorEnd:						; end of RefTilesHor
	assert RefTilesHorEnd-RefTilesHor == $8B6
