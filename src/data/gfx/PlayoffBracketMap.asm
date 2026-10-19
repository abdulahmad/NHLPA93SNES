PlayoffBracketMap:					;DrawTreeArrow graphics: 23 rows of 12 map words; PlayoffScreen copies
									;column n (arrow graphics n) to the tree
	incbin "../../../Extracted/Graphics/Arrows.snesmap"
PlayoffBracketMapEnd:				; end of PlayoffBracketMap
	assert PlayoffBracketMapEnd-PlayoffBracketMap == 552
