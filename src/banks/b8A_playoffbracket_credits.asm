; Bank $8A: playoffbracket credits. Files in ROM order (docs/file-map.md).

if pc() < $8A8000
	org $8A8000
endif

SpriteSet12:						;frame set 12 (includes SPFflip, SPFstumble, SPFhook): frames 532-605
	dw 74							; frames
	dw 504							; pieces
	dw 896							; tiles
	dw .pieces-SpriteSet12
	dw .tiles-SpriteSet12
.frames:							;first piece of each frame (+1 entry for the end)
	dw 0,11,28,48,67,80,93,100
	dw 108,114,119,120,121,122,123,124
	dw 125,126,127,128,129,130,131,132
	dw 133,134,161,172,179,191,200,207
	dw 215,225,235,242,249,258,264,270
	dw 278,287,293,302,313,325,337,342
	dw 350,355,365,376,386,397,404,413
	dw 420,428,435,438,442,445,450,456
	dw 466,469,473,476,479,482,488,491
	dw 495,500,504
.pieces:							;x, y, tile, attributes per piece
	incbin "../../Extracted/Graphics/Sprites/set12.pieces"
	assert .tiles-.pieces == 4*504
.tiles:								;896 4bpp tiles (32 bytes each)
	incbin "../../Extracted/Graphics/Sprites/set12.chr"
SpriteSet12End:						; end of SpriteSet12
	assert SpriteSet12End-SpriteSet12 == $880+896*32

PlayoffBracketMap:					;DrawTreeArrow graphics: 23 rows of 12 map words; PlayoffScreen copies
									;column n (arrow graphics n) to the tree
	incbin "../../Extracted/Graphics/Arrows.snesmap"
PlayoffBracketMapEnd:				; end of PlayoffBracketMap
	assert PlayoffBracketMapEnd-PlayoffBracketMap == 552

Credits:							;the title screen credit lines (length word, text); $FE ends the copyright
									;page, $FF a page, an empty string the list
	%String("$ 1992 Electronic Arts")
	%String("Licensed by Nintendo")
	%StringCC($FE)

	%String("Design adapted by")
	%String("Michael Brook")
	%String("Scott Orr")
	%String("Richard Hilleman")
	%StringCC($FF)

	%String("Technical Design by")
	%String("Jim Simmons")
	%StringCC($FF)

	%String("Programmed by")
	%String("Park Place Productions")
	%String("William Robinson")
	%StringCC($FF)

	%String("Graphics by")
	%String("George Simmons")
	%String("Brian O'Hara")
	%String("Curt Toumanian")
	%StringCC($FF)

	%String("Music and Sound by")
	%String("Rob Hubbard")
	%StringCC($FF)

	%String("Produced by")
	%String("Michael Brook")
	%StringCC($FF)

	%String("Assistant Producer")
	%String("Robert Zalot")
	%StringCC($FF)

	%String("Technical Directors")
	%String("Scott Cronce")
	%String("Tom DeBry")
	%StringCC($FF)

	%String("Testing by")
	%String("Yun Shin")
	%String("Steve Matulac")
	%String("Mike Rubinelli")
	%StringCC($FF)

	%String("Player Ratings by")
	%String("Igor Kuperman")
	%StringCC($FF)

	%String("Special Thanks to")
	%String("Bob Borgen")
	%String("Ted Saskin")
	%String("Ian Pulver")
	%String("Rob Blake")
	%String("John McIntyre")
	%StringCC($FF)
	dw 2							; empty: end of the credits
	%StringCC($FF)
	%StringCC($FF)

incsrc "../routines/logic/lineinput.asm"
incsrc "../routines/logic/getlchoice.asm"
incsrc "../routines/penalty/SetScore.asm"
