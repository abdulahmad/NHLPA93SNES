Title1Map:							;the title screen backdrop, packed (map, palette, tiles)
	incbin "../../../Extracted/Graphics/Title1.map.snesjim"
Title1MapEnd:						; end of Title1Map
	assert Title1MapEnd-Title1Map == $25F9
