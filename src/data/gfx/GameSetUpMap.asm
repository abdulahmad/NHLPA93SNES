GameSetUpMap:						;the game setup screen backdrop (two team boxes, options box),
									;packed: 32 x 32 map, 128 colours at $800, 18 tiles at $900
	incbin "../../../Extracted/Graphics/GameSetUp.map.snesjim"
GameSetupMapEnd:					; end of GameSetupMap
	assert GameSetupMapEnd-GameSetUpMap == $22F
