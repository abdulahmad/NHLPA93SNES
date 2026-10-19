; Bank $8A: playoffbracket credits. Files in ROM order (docs/file-map.md).

if pc() < $8A8000
	org $8A8000
endif
incsrc "../data/gfx/SpriteSet12.asm"
incsrc "../data/gfx/PlayoffBracketMap.asm"
incsrc "../data/text/Credits.asm"
incsrc "../routines/logic/lineinput.asm"
incsrc "../routines/logic/getlchoice.asm"
incsrc "../routines/penalty/SetScore.asm"
