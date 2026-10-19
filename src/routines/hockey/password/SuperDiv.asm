SuperDiv:							;password bits /= d0, with the remainder in d0
	phx								; remainder = passbits, divisor = d0 << 128
	ldx.w #$000E					; 8 words
.init:								; dividend into mulres, divisor words 0
	lda.w passbits,x				; dividend
	sta.b mulres,x
	stz.b mula,x					; divisor words 0
	dex
	dex
	bpl .init
	lda.b d0						; divisor
	sta.b mula+16					; in the top word
	ldx.w #$0080					; 128 steps
.loop:								; shift the divisor right
	lsr.b mula+16					; shift the divisor right
	ror.b mula+14
	ror.b mula+12
	ror.b mula+10
	ror.b mula+8
	ror.b mula+6
	ror.b mula+4
	ror.b mula+2
	ror.b mula
	asl.w passbits					; shift the dividend left
	rol.w passbits+2				; shift the dividend left
	rol.w passbits+4
	rol.w passbits+6
	rol.w passbits+8
	rol.w passbits+10
	rol.w passbits+12
	rol.w passbits+14
	lda.b mulres					; remainder >= divisor: subtract, quotient bit 1
	cmp.b mula						; compare remainder with divisor
	lda.b mulres+2
	sbc.b mula+2
	lda.b mulres+4
	sbc.b mula+4
	lda.b mulres+6
	sbc.b mula+6
	lda.b mulres+8
	sbc.b mula+8
	lda.b mulres+10
	sbc.b mula+10
	lda.b mulres+12
	sbc.b mula+12
	lda.b mulres+14
	sbc.b mula+14
	lda.w #$0000
	sbc.b mula+16
	bcc .next						; smaller: skip
	lda.b mulres					; subtract
	sbc.b mula
	sta.b mulres
	lda.b mulres+2
	sbc.b mula+2
	sta.b mulres+2
	lda.b mulres+4
	sbc.b mula+4
	sta.b mulres+4
	lda.b mulres+6
	sbc.b mula+6
	sta.b mulres+6
	lda.b mulres+8
	sbc.b mula+8
	sta.b mulres+8
	lda.b mulres+10
	sbc.b mula+10
	sta.b mulres+10
	lda.b mulres+12
	sbc.b mula+12
	sta.b mulres+12
	lda.b mulres+14
	sbc.b mula+14
	sta.b mulres+14
	inc.w passbits					; quotient bit
.next:								; next step
	dex								; next step
	beq .done						; done
	jmp.w .loop						; loop
.done:								; restore X; the remainder in d0
	plx								; restore X
	lda.b mulres					; remainder
	sta.b d0						; in d0
	clc								; clear carry
	rtl
