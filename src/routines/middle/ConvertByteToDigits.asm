ConvertByteToDigits:				;Write the two digit number d0 as two characters at [a1], blank leading
									;zero
	lda.w #$2020					; blank, then the tens digit when d0 >= 10
	sta.b tmp0
	lda.b d0						; number
	and.w #$00FF
	cmp.w #$000A					; below 10
	bcc .ones
	lsr a							; tens digit: /16
	lsr a
	lsr a
	lsr a
	clc
	adc.w #$0030					; ASCII
	sta.b tmp0						; tens character
.ones:
	lda.b d0
	and.w #$000F					; ones
	clc
	adc.w #$0030					; ASCII
	sta.b tmp0+1					; ones character
	lda.b tmp0
	sta.b [a1]						; write both
	inc.b a1						; a1 + 2
	inc.b a1
	rtl
