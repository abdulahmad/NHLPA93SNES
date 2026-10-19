PushNumberWidth:					;a1 = d0 as a d1 digit decimal string, right aligned with leading spaces
	lda.w #PushWidthBuf				; buffer
	sta.b a1
	lda.w #$0000					; bank 0
	sta.b a1+2
	lda.b d1						; width
	inc a
	inc a							; plus the length word
	sta.w PushWidthBuf				; length
	tay								; Y = end
	lda.w #$2020					; spaces
	sta.w PushWidthBuf+2
	sta.w PushWidthBuf+4
	sta.w PushWidthBuf+6
	sta.w PushWidthBuf+8
	lda.b d0						; the number
.dig:								; next digit: d0 / d2, high digit first
	sta.b mulb						; dividend
	lda.w #$000A					; 10
	sta.b mula
	dey								; one character back
	jsl.l divu16					; divide
	lda.b mulres+2					; remainder
	sep #$20						; 8-bit A
	adc.b #$30						; ASCII
	sta.w PushWidthBuf,y			; store it
	rep #$20						; 16-bit A
	lda.b mulres					; quotient
	bne .dig						; more digits
	rtl
