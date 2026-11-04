; Bank $86: the boot SPC upload (the sound driver and its samples) and a few routines. Files in ROM order
; (docs/file-map.md).

if pc() < $868000
	org $868000
endif
incsrc "../data/sound/bootsound.asm"
incsrc "../routines/decompress/DecompressBytecode.asm"
incsrc "../routines/hockey/game/RestoreBenchEnergy.asm"
incsrc "../routines/sound/StartSngTitle.asm"
incsrc "../routines/sound/StartSngEOP.asm"
incsrc "../routines/hockey/setup/setteams.asm"
incsrc "../routines/middle/input/ProcessInputWithRepeat.asm"
incsrc "../routines/hockey/setup/setoptions_printpos2.asm"
incsrc "../routines/hockey/collide/GetPeriodTimeRemaining.asm"
incsrc "../routines/hockey/game/GetPeriodTime.asm"
incsrc "../routines/hockey/game/GetPeriodTime_timetab.asm"
incsrc "../routines/logic/lines/lcfound_close.asm"
incsrc "../routines/hockey/setup/PickStartingGoalie.asm"
incsrc "../routines/logic/assignments/assscore.asm"
