BigFontTiles:						;BigFont.map.jim tiles: the big font (144 tiles, data/BigFont.chr.pak),
									;packed; setupice sends them to BigFontChars (PixelRemap8D), printbig
									;draws them
	incbin "../../../Extracted/Graphics/BigFont.chr.pak"
BigFontTilesEnd:					; end of BigFontTiles
	assert BigFontTilesEnd-BigFontTiles == $9C0
