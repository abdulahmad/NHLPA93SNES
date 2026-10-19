divs16:								;Signed 16-bit divide: A = mulb / mula
	stz.b mulsign					; sign count
	lda.b mula						; divisor
	bpl .mulapos					; positive
	eor.w #$FFFF					; negate it
	inc a
	inc.b mulsign					; one negative
.mulapos:							; divisor to the high word
	sta.b mula+2					; divisor to the high word
	stz.b mula						; low word 0
	lda.w #$0010					; 16 bits
	sta.b mulcnt
	lda.b mulb						; dividend
	bpl .loop						; positive
	eor.w #$FFFF					; negate it
	inc a
	sta.b mulb						; dividend
	inc.b mulsign					; one negative
.loop:								; shift the divisor right
	lsr.b mula+2					; shift the divisor right
	ror.b mula
	asl.b mulres					; shift the quotient
	lda.b mulb						; dividend
	cmp.b mula
	lda.w #$0000
	sbc.b mula+2
	bcc .next						; too small: quotient bit 0
	lda.b mulb						; subtract
	sbc.b mula
	sta.b mulb
	inc.b mulres					; set the quotient bit
.next:								; next quotient bit
	dec.b mulcnt					; next bit
	bne .loop
	lsr.b mulsign					; odd count?
	bcc .pos						; no: keep
	lda.w #$0000					; negate
	sbc.b mulres
	sta.b mulres
.pos:								; quotient
	lda.b mulres					; quotient
	sta.b mula
	sta.b mulb
	clc								; clear carry
	rtl
