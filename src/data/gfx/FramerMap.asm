FramerMap:							;Framer.map.jim: the 3 x 3 box pieces (corner, edge, side, centre) from
									;the 4 FramerTiles with flips (Framer_piece)
	incbin "../../../Extracted/Graphics/Framer.snesmap"
FramerMapEnd:						; end of FramerMap
	assert FramerMapEnd-FramerMap == 18
