; Bank $8A: playoffbracket credits. Files in ROM order (docs/file-map.md).

if pc() < $8A8000
	org $8A8000
endif
SpriteSet12:						;frame set 12 (includes SPFflip, SPFstumble, SPFhook): frames 532-605
	incbin "../../Extracted/Graphics/Sprites/Sprites12.sanim"

PlayoffBracketMap:					;DrawTreeArrow graphics: 23 rows of 12 map words; PlayoffScreen copies
									;column n (arrow graphics n) to the tree
	incbin "../../Extracted/Graphics/Arrows.smap"

incsrc "../data/text/Credits.asm"
incsrc "../routines/logic/lineinput.asm"
incsrc "../routines/logic/getlchoice.asm"
incsrc "../routines/penalty/SetScore.asm"
