GetShifter:							;d1 = the number of games of the playoff round less one, d2 = its first
									;win bit
	lda.w #-16						; d2 = -16
	sta.b d2
	lda.w #16						; d1 = 16
	sta.b d1
	ldy.w gamelevel					; round
.3:									; add the shift
	lda.b d2
	clc
	adc.b d1						; d2 += d1
	sta.b d2
	lsr.b d1						; d1 halves
	dey								; each round
	bpl .3
	dec.b d1						; games - 1
	rtl
