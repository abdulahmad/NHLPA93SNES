SmallFontMap:						;print character (0-127) -> small font tile (+ flip bits), added to
									;smallfontchars by print
	incbin "../../../Extracted/Graphics/SmallFont.snesmap"
SmallFontMapEnd:
	assert SmallFontMapEnd-SmallFontMap == 256
