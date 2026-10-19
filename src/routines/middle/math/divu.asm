divu:								;Unsigned divide: A = mulb (32-bit) / mula, with the remainder after the
									;quotient
	lda.b mula						; divisor to the high word
	sta.b mula+2
	stz.b mula						; low word 0
	lda.w #$0010					; 32 quotient bits
	sta.b mulres+2
.loop:								; shift the quotient
	asl.b mulres					; shift the quotient
	lsr.b mula+2					; shift the divisor right
	ror.b mula
	lda.b mulb						; dividend low
	cmp.b mula
	lda.b mulb+2					; dividend high
	sbc.b mula+2
	bcc .next						; too small: quotient bit 0
	lda.b mulb						; subtract
	sbc.b mula
	sta.b mulb
	lda.b mulb+2
	sbc.b mula+2
	sta.b mulb+2
	inc.b mulres					; set the quotient bit
.next:								; next quotient bit
	dec.b mulres+2					; next bit
	bne .loop
	lda.b mulb						; remainder
	sta.b mulres+2					; in mulres+2
	lda.b mulres					; quotient
	sta.b mula
	sta.b mulb
	clc								; clear carry
	rtl
