divu16:								;Unsigned 16-bit divide: mulres = mulb / mula, with the remainder after
									;the quotient
	lda.b mula						; divisor to the high word
	sta.b mula+2
	stz.b mula						; low word 0
	lda.w #$0010					; 16 quotient bits
	sta.b mulb+2
.loop:
	asl.b mulres					; shift the quotient
	lsr.b mula+2					; shift the divisor right
	ror.b mula
	lda.b mulb
	cmp.b mula						; dividend
	lda.w #$0000
	sbc.b mula+2
	bcc .next						; too small: quotient bit 0
	lda.b mulb						; subtract
	sbc.b mula
	sta.b mulb
	inc.b mulres					; set the quotient bit
.next:
	dec.b mulb+2					; next bit
	bne .loop
	lda.b mulb						; remainder
	sta.b mulres+2					; in mulres+2
	lda.b mulres					; quotient
	sta.b mula
	sta.b mulb
	clc								; clear carry
	rtl
