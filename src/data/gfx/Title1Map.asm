Title1Map:							;the title screen backdrop, packed (map, palette, tiles)
	incbin "../../../Extracted/Graphics/Title1.map.snesjim"
Title1MapEnd:
	assert Title1MapEnd-Title1Map == $25F9
