PushNumber:							;a1 = d0 as a decimal string, no leading zeros
	lda.w #mesarea+30				; write backwards from the end of the text buffer
	sta.b a1
	lda.w #mesarea>>16
	sta.b a1+2
	lda.b d0						; the number
.0:
	sta.b mulb						; divide by 10
	lda.w #$000A
	sta.b mula
	jsl.l divu16
	dec.b a1						; one character back
	sep #$20
	lda.b mulres+2
	adc.b #$30						; remainder as ASCII
	sta.b [a1]						; store it
	rep #$30
	lda.b mulres					; quotient
	bne .0							; more digits
	dec.b a1						; room for the length word
	dec.b a1
	lda.w #$01AF					; end of the buffer
	sec
	sbc.b a1
	sta.b [a1]						; length word
	rtl
