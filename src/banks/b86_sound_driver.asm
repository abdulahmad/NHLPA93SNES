; Bank $86: the boot SPC upload (the sound driver and its samples) and a few routines. Files in ROM order
; (docs/file-map.md).

if pc() < $868000
	org $868000
endif
incsrc "../data/sound/bootsound.asm"
incsrc "../routines/decompress/DecompressBytecode.asm"
incsrc "../routines/hockey/teams/RestoreBenchEnergy.asm"
incsrc "../routines/sound/StartSong6.asm"
incsrc "../routines/sound/StartSong7.asm"
incsrc "../routines/hockey/game/setteams.asm"
incsrc "../routines/middle/input/ProcessInputWithRepeat.asm"
incsrc "../routines/hockey/screens/setoptions_printpos2.asm"
incsrc "../routines/hockey/game/GetPeriodTimeRemaining.asm"
incsrc "../routines/hockey/game/GetPeriodTime.asm"
incsrc "../routines/hockey/game/GetPeriodTime_timetab.asm"
incsrc "../routines/logic/lines/lcfound2.asm"
incsrc "../routines/hockey/teams/PickStartingGoalie.asm"
incsrc "../routines/logic/assignments/assscore.asm"
