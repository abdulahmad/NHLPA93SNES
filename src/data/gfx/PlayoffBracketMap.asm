PlayoffBracketMap:					;DrawTreeArrow graphics: 23 rows of 12 map words; PlayoffScreen copies
									;column n (arrow graphics n) to the tree
	incbin "../../../Extracted/Graphics/Arrows.snesmap"
PlayoffBracketMapEnd:
	assert PlayoffBracketMapEnd-PlayoffBracketMap == 552
