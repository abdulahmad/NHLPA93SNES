; Bank $83: teams. Files in ROM order (docs/file_map.md).

if pc() < $838000
	org $838000
endif
incsrc "../data/teamdata93s.asm"
incsrc "../data/gfx/SmallFontTiles.asm"
incsrc "../routines/hockey/getname.asm"
incsrc "../data/gfx/IceRinkMap.asm"
incsrc "../data/gfx/HorRinkMap.asm"
incsrc "../data/gfx/RinkPalette.asm"
incsrc "../routines/hockey/Pausemode.asm"
incsrc "../routines/hockey/PauseMenu.asm"
incsrc "../routines/hockey/PauseReadJoy.asm"
incsrc "../routines/hockey/PauseResume.asm"
incsrc "../routines/hockey/PauseLeave.asm"
incsrc "../routines/hockey/Opening2.asm"
incsrc "../data/gfx/RefsMap.asm"
incsrc "../routines/logic/assgoalietopuck.asm"
