; Bank $8A: face-off, zamboni, flip, stumble and hook sprites (set 12), the playoff bracket map and the
; credits. Files in ROM order (docs/file-map.md).

if pc() < $8A8000
	org $8A8000
endif
SpriteSet12:						;frame set 12 (includes SPFflip, SPFstumble, SPFhook): frames 532-605
	incbin "../../Extracted/Graphics/Sprites/Sprites532_605.sanim"

PlayoffBracketMap:					;PlayoffScreen_doarrow graphics: 23 rows of 12 map words; PlayoffScreen copies
									;column n (arrow graphics n) to the tree
	incbin "../../Extracted/Graphics/Arrows.smap"

incsrc "../data/text/Credits.asm"
incsrc "../routines/logic/lines/lineinput.asm"
incsrc "../routines/logic/lines/getlchoice.asm"
incsrc "../routines/penalty/highlights/SetScore.asm"
