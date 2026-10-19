divs:								;Signed divide: A = mulb (32-bit) / mula
	stz.b mulsign					; mulsign = number of negative operands
	lda.b mula						; divisor
	bpl .apos						; positive
	eor.w #$FFFF					; negate it
	inc a
	inc.b mulsign					; one negative
.apos:								; divisor to the high word
	sta.b mula+2					; divisor to the high word
	stz.b mula						; low word 0
	lda.w #$0010					; 16 quotient bits
	sta.b mulcnt
	lda.b mulb+2					; dividend high
	bpl .loop						; positive
	lda.w #$0000					; negate the dividend
	sec
	sbc.b mulb
	sta.b mulb
	lda.w #$0000
	sbc.b mulb+2
	sta.b mulb+2
	inc.b mulsign					; one negative
.loop:								; shift the divisor right
	lsr.b mula+2					; shift the divisor right
	ror.b mula
	asl.b mulres					; shift the quotient
	lda.b mulb						; dividend low
	cmp.b mula
	lda.b mulb+2
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
	dec.b mulcnt					; next bit
	bne .loop
	lsr.b mulsign					; odd count?
	bcc .rtl						; no: keep
	lda.w #$0000					; negate
	sbc.b mulres
	sta.b mulres
.rtl:								; quotient
	lda.b mulres					; quotient
	clc								; clear carry
	rtl
