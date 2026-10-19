mulu16:								;Unsigned 16-bit multiply: A = mula * mulb
	lda.b mula						; mula
	bmi .full						; high bit: full multiply
	cmp.w #$0080					; below 128
	bcc .byteb						; yes
	lda.b mulb						; mulb
	bmi .full						; high bit: full multiply
	cmp.w #$0080					; below 128
	bcs .full
	sep #$20						; 8-bit A
	sta.w M7B						; multiplier to the PPU multiplier
	lda.b mula						; mula low byte
	sta.w M7A
	lda.b mula+1					; mula high byte
	sta.w M7A
	rep #$30						; 16-bit
	lda.w MPYL						; result
	sta.b mula
	sta.b mulb
	sta.b mulres
	rtl
.byteb:								; mula is under 256
	lda.b mulb						; mulb
	bmi .full						; too big
	sep #$20						; 8-bit A
	sta.w M7A						; mulb low byte
	xba
	sta.w M7A						; mulb high byte
	lda.b mula						; mula low
	sta.w M7B
	rep #$30						; 16-bit
	lda.w MPYL						; result
	sta.b mula
	sta.b mulb
	sta.b mulres
	rtl
.full:								; 8-bit
	sep #$20						; mula low
	lda.b mula
	sta.w WRMPYA					; times mulb low
	lda.b mulb
	sta.w WRMPYB
	clc
	clc
	clc
	clc
	lda.w RDMPYL					; low result
	sta.b mulres
	lda.w RDMPYH					; high result
	sta.b mulres+1
	lda.b mulb+1					; mulb high
	sta.w WRMPYB
	clc
	clc
	clc
	clc
	lda.w RDMPYL					; low result
	adc.b mulres+1					; add
	sta.b mulres+1
	lda.b mula+1					; mula high
	sta.w WRMPYA
	lda.b mulb						; mulb low
	sta.w WRMPYB
	clc
	clc
	clc
	clc
	lda.w RDMPYL					; low result
	adc.b mulres+1					; add
	sta.b mulres+1
	rep #$30						; 16-bit
	lda.b mulres					; result
	sta.b mula
	sta.b mulb
	clc								; clear carry
	rtl
