; Bank $8D: goalie sprites (set 10), the big font tiles, and routines for the playoff tree, periods and
; rosters. Files in ROM order (docs/file-map.md).

if pc() < $8D8000
	org $8D8000
endif
incsrc "../routines/hockey/playoffs/maketree.asm"
incsrc "../routines/video/interrupts/InitPPU.asm"
incsrc "../routines/hockey/game/StartPer.asm"
incsrc "../routines/penalty/penalties/GetLowestPen.asm"
incsrc "../routines/hockey/collisions/Bcheck.asm"
incsrc "../routines/hockey/playoffs/ContinuePlayoffs.asm"
incsrc "../routines/print/eraser.asm"
incsrc "../routines/hockey/teams/DrawTeamBlocks.asm"
incsrc "../routines/penalty/scoreboard/EASNLogo.asm"
incsrc "../routines/hockey/game/PeriodOver.asm"
incsrc "../routines/hockey/teams/GetPlayerName.asm"
incsrc "../routines/video/crowd/updatesound.asm"
incsrc "../routines/tables/asstab.asm"
incsrc "../routines/middle/math/mulu16.asm"
incsrc "../routines/logic/puck/puckshadow.asm"
incsrc "../routines/hockey/input/setd0player.asm"
SpriteSet10:						;frame set 10: frames 462-517
	incbin "../../Extracted/Graphics/Sprites/Sprites462_517.sanim"

BigFontTiles:						;the big font tiles (144 tiles, BigFont.chr.pak),
									;packed; setupice sends them to BigFontChars (PixelRemap8D), printbig
									;draws them
	incbin "../../Extracted/Graphics/BigFont.chr.pak"

incsrc "../routines/penalty/highlights/StartHL2.asm"
incsrc "../routines/logic/assignments/asspenalty.asm"
incsrc "../routines/logic/controls/clrplayer.asm"
incsrc "../routines/logic/skating/avdgoal.asm"
