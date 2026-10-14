; Bank $81: sfx. Files in ROM order (docs/file_map.md).

if pc() < $818000
	org $818000
endif
incsrc "../data/sound/gamesound.asm"
