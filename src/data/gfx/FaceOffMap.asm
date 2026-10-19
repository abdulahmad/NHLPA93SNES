FaceOffMap:							;the 12 x 10 faceoff box map (tiles from FaceOffTiles, attribute $20),
									;copied into textmap by puckfaceoff2
	incbin "../../../Extracted/Graphics/FaceOff.snesmap"
FaceOffMapEnd:						; end of FaceOffMap
	assert FaceOffMapEnd-FaceOffMap == 240
