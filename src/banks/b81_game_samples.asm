; Bank $81: the in-game SPC upload (sample directory and game samples); the samples run on into bank $82.
; Files in ROM order (docs/file-map.md).

if pc() < $818000
	org $818000
endif
incsrc "../data/sound/gamesound.asm"
