EASNLogoMap:						;easn.map (small): the 7 x 2 EASN logo tile words for EASNLogo
									;(unusedchars + n)
	incbin "../../../Extracted/Graphics/EASN.snesmap"
EASNLogoMapEnd:						; end of EASNLogoMap
	assert EASNLogoMapEnd-EASNLogoMap == 28
