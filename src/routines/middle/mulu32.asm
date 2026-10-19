mulu32:								;Unsigned 32-bit multiply: mulres = mula * mulb
	sep #$20						; 8-bit A
	lda.b mula						; mula low byte
	sta.w WRMPYA
	lda.b mulb						; mulb low byte
	sta.w WRMPYB
	rep #$30						; 16-bit
	rep #$30
	clc
	lda.w RDMPYL					; product
	sta.b mulres					; mulres low
	stz.b mulres+2					; high word 0
	sep #$20
	lda.b mulb+1					; mulb byte 1
	sta.w WRMPYB
	rep #$30
	rep #$30
	clc
	lda.w RDMPYL					; product
	adc.b mulres+1					; add
	sta.b mulres+1
	sep #$20
	bcc .c1							; no carry
	inc.b mulres+3					; carry
.c1:
	lda.b mulb+2					; mulb byte 2
	sta.w WRMPYB
	rep #$30
	rep #$30
	clc
	lda.w RDMPYL					; product
	adc.b mulres+2					; add
	sta.b mulres+2
	sep #$20
	lda.b mulb+3					; mulb byte 3
	sta.w WRMPYB
	clc
	clc
	clc
	clc
	lda.w RDMPYL					; product
	adc.b mulres+3					; add
	sta.b mulres+3
	lda.b mula+1					; mula byte 1
	sta.w WRMPYA
	lda.b mulb						; times mulb byte 0
	sta.w WRMPYB
	rep #$30
	rep #$30
	clc
	lda.w RDMPYL					; product
	adc.b mulres+1					; add
	sta.b mulres+1
	sep #$20
	bcc .c2
	inc.b mulres+3
.c2:
	lda.b mulb+1					; mulb byte 1
	sta.w WRMPYB
	rep #$30
	rep #$30
	clc
	lda.w RDMPYL					; product
	adc.b mulres+2					; add
	sta.b mulres+2
	sep #$20
	lda.b mulb+2					; mulb byte 2
	sta.w WRMPYB
	clc
	clc
	clc
	clc
	lda.w RDMPYL					; product
	adc.b mulres+3					; add
	sta.b mulres+3
	lda.b mula+2					; mula byte 2
	sta.w WRMPYA
	lda.b mulb						; times mulb byte 0
	sta.w WRMPYB
	rep #$30
	rep #$30
	clc
	lda.w RDMPYL					; product
	adc.b mulres+2					; add
	sta.b mulres+2
	sep #$20
	lda.b mulb+1					; mulb byte 1
	sta.w WRMPYB
	clc
	clc
	clc
	clc
	lda.w RDMPYL					; product
	adc.b mulres+3					; add
	sta.b mulres+3
	lda.b mula+3					; mula byte 3
	sta.w WRMPYA
	lda.b mulb						; times mulb byte 0
	sta.w WRMPYB
	clc
	clc
	clc
	clc
	lda.w RDMPYL					; product
	adc.b mulres+3					; add
	sta.b mulres+3
	rep #$30						; 16-bit
	lda.b mulres					; low word
	clc								; clear carry
	rtl
