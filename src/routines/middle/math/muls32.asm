muls32:								;Signed multiply with a 32-bit result in mulres
	stz.b mulneg					; mulneg = number of negative operands
	lda.b mula						; first operand
	bpl .signb						; positive
	eor.w #$FFFF					; negate it
	inc a
	sta.b mula
	inc.b mulneg
.signb:								; second operand
	lda.b mulb						; second operand
	bpl .mul						; positive
	eor.w #$FFFF					; negate it
	inc a
	sta.b mulb
	inc.b mulneg
.mul:								; mulres = mula*mulb
	jsl.l mulu						; mulres = mula*mulb
	lsr.b mulneg					; odd: negate the 32-bit result
	bcc .rtl
	lda.w #$0000					; 0 minus the result
	sbc.b mulres
	sta.b mula
	sta.b mulb
	sta.b mulres
	lda.w #$0000					; high word
	sbc.b mulres+2
	sta.b mula+2
	sta.b mulb+2
	sta.b mulres+2
	lda.b mulres					; low word back in A
	clc								; clear carry
.rtl:								; return
	rtl
