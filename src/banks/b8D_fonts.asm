; Bank $8D: fonts. Files in ROM order (docs/file_map.md).

if pc() < $8D8000
	org $8D8000
endif
incsrc "../routines/hockey/maketree.asm"
incsrc "../routines/video/InitPPU.asm"
incsrc "../routines/hockey/StartPer.asm"
incsrc "../routines/penalty/GetLowestPen.asm"
incsrc "../routines/hockey/Bcheck.asm"
incsrc "../routines/hockey/ContinuePlayoffs.asm"
incsrc "../routines/print/eraser.asm"
incsrc "../routines/hockey/DrawTeamBlocks.asm"
incsrc "../routines/penalty/EASNLogo.asm"
incsrc "../routines/hockey/PeriodOver.asm"
incsrc "../routines/hockey/GetPlayerName.asm"
incsrc "../routines/video/updatesound.asm"
incsrc "../routines/tables/asstab.asm"
incsrc "../routines/middle/mulu16.asm"
incsrc "../routines/logic/puckshadow.asm"
incsrc "../routines/hockey/setd0player.asm"
incsrc "../data/gfx/SpriteSet10.asm"
incsrc "../data/gfx/BigFontTiles.asm"
incsrc "../routines/penalty/StartHL2.asm"
incsrc "../routines/logic/asspenalty.asm"
incsrc "../routines/logic/clrplayer.asm"
incsrc "../routines/logic/avdgoal.asm"
