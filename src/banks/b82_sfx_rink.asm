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

PasstoText:							;characters used in the password text (PWrange = 30, the 31st is the
									;blank)
	db "BCDFGHJKLMNPRSTVWXYZ0123456789-"

incsrc "../routines/hockey/PWtoBits.asm"
incsrc "../routines/hockey/ClrPassBits.asm"
incsrc "../routines/hockey/PushBits.asm"
incsrc "../routines/hockey/BitMaskTable.asm"
incsrc "../routines/hockey/GameOver.asm"
incsrc "../routines/hockey/SaveRegsStartHL2.asm"

PixelRemap8D:						;4bpp pixel value remap for BigFontTiles (setupice via remap):
									;color 0 -> 7, the rest unchanged
	db $07,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F

incsrc "../routines/video/marktextlo.asm"

PixelRemap83:						;4bpp pixel value remap for SmallFontTiles (setupice, the pause
									;menu, PlayoffScreen via remap). Only colors 0-6 occur: entries 7-15
									;would read the next bytes (muls32)
	db $04,$03,$04,$03,$02,$01,$04

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
