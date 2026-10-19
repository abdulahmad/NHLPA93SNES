IceRinkTiles:						;packed rink tiles
	incbin "../../../Extracted/Graphics/IceRink.chr.pak"
IceRinkTilesEnd:					; end of IceRinkTiles
	assert IceRinkTilesEnd-IceRinkTiles == $2B9C
