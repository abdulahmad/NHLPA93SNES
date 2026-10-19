BigFontMap:							;bigfont.map: big font tiles of each character: 76 top-row words, then the
									;76 bottom-row words (+$98); printbig uses BigFontIndex
	incbin "../../../Extracted/Graphics/BigFont.snesmap"
BigFontMapEnd:						; end of BigFontMap
	assert BigFontMapEnd-BigFontMap == 304
