HorRinkMap:							;horizontal rink tile map, 48 x 28 words
	incbin "../../../Extracted/Graphics/IceRinkHor.snesmap"
HorRinkMapEnd:						; end of HorRinkMap
	assert HorRinkMapEnd-HorRinkMap == 48*28*2
