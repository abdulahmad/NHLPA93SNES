; Bank $82: the end of the game samples, the rink tiles, the animation tables, and the SPC upload and
; password routines. Files in ROM order (docs/file-map.md).

if pc() < $82B86C
	org $82B86C
endif
incsrc "../data/frames93s.asm"

IceRinkTiles:						;packed rink tiles
	incbin "../../Extracted/Graphics/IceRink.chr.pak"

incsrc "../routines/penalty/penalties/SetPA2.asm"
incsrc "../routines/penalty/ticker/UpdateScores.asm"
incsrc "../routines/sram/BitstoPW.asm"
incsrc "../routines/sound/sndqreset.asm"
incsrc "../routines/sound/SPCBootUpload.asm"
incsrc "../routines/sound/SPCGameUpload.asm"
incsrc "../routines/sound/SPCUpload.asm"
incsrc "../routines/sound/QueueSound.asm"
incsrc "../data/text/PasstoText.asm"
incsrc "../routines/hockey/password/PWtoBits.asm"
incsrc "../routines/hockey/password/ClrPassBits.asm"
incsrc "../routines/hockey/password/PushBits.asm"
incsrc "../routines/hockey/util/BitMaskTable.asm"
incsrc "../routines/hockey/game/GameOver.asm"
incsrc "../routines/hockey/playoffs/SaveRegsStartHL2.asm"
incsrc "../data/gfx/PixelRemap8D.asm"
incsrc "../routines/video/text/marktextlo.asm"
incsrc "../data/gfx/PixelRemap83.asm"
incsrc "../routines/middle/math/muls32.asm"
incsrc "../routines/video/sprites/addframe_hi.asm"
incsrc "../routines/logic/skating/noturn.asm"
incsrc "../routines/video/text/marktexthi.asm"
incsrc "../routines/stats/ClearTeamStats.asm"
incsrc "../routines/penalty/penalties/ClearPenaltyMessage.asm"
incsrc "../routines/hockey/screens/startpause2.asm"
incsrc "../routines/print/printbigz.asm"
incsrc "../routines/print/appendz.asm"
incsrc "../routines/logic/assignments/asscentero.asm"
