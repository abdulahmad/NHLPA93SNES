; Bank $82: sfx rink. Files in ROM order (docs/file-map.md).

if pc() < $82B86C
	org $82B86C
endif
incsrc "../data/frames93s.asm"

IceRinkTiles:						;packed rink tiles
	incbin "../../Extracted/Graphics/IceRink.chr.pak"
IceRinkTilesEnd:					; end of IceRinkTiles
	assert IceRinkTilesEnd-IceRinkTiles == $2B9C

incsrc "../routines/penalty/SetPA2.asm"
incsrc "../routines/penalty/UpdateScores.asm"
incsrc "../routines/sram/BitstoPW.asm"
incsrc "../routines/sound/sndqreset.asm"
incsrc "../routines/sound/SPCBootUpload.asm"
incsrc "../routines/sound/SPCGameUpload.asm"
incsrc "../routines/sound/SPCUpload.asm"
incsrc "../routines/sound/QueueSound.asm"
incsrc "../data/text/PasstoText.asm"
incsrc "../routines/hockey/PWtoBits.asm"
incsrc "../routines/hockey/ClrPassBits.asm"
incsrc "../routines/hockey/PushBits.asm"
incsrc "../routines/hockey/BitMaskTable.asm"
incsrc "../routines/hockey/GameOver.asm"
incsrc "../routines/hockey/SaveRegsStartHL2.asm"
incsrc "../data/gfx/PixelRemap8D.asm"
incsrc "../routines/video/marktextlo.asm"
incsrc "../data/gfx/PixelRemap83.asm"
incsrc "../routines/middle/muls32.asm"
incsrc "../routines/video/addframe_hi.asm"
incsrc "../routines/logic/noturn.asm"
incsrc "../routines/video/marktexthi.asm"
incsrc "../routines/hockey/ClearTeamStats.asm"
incsrc "../routines/penalty/ClearPenaltyMessage.asm"
incsrc "../routines/hockey/startpause2.asm"
incsrc "../routines/print/printbigz.asm"
incsrc "../routines/print/appendz.asm"
incsrc "../routines/logic/asscentero.asm"
