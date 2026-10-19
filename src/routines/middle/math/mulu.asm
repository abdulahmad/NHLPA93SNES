mulu:								;Unsigned multiply: mulres (32-bit) = mula * mulb
	lda.b mula						; mula >= $80 needs mulb < $80
	bmi .full
	cmp.w #$0080
	bcc .byteb
	lda.b mulb
	bmi .full
	cmp.w #$0080
	bcs .full
	sep #$20						; 8-bit A
	sta.w M7B
	lda.b mula
	sta.w M7A
	lda.b mula+1
	sta.w M7A
	lda.w MPYH
	rep #$30						; 16-bit registers
	and.w #$00FF
	sta.b mula+2
	sta.b mulb+2
	sta.b mulres+2
	lda.w MPYL
	sta.b mula
	sta.b mulb
	sta.b mulres
	rtl
.byteb:								; byte factor
	lda.b mulb						; mula < $80: byte factor
	bmi .full
	sep #$20						; 8-bit A
	sta.w M7A
	xba
	sta.w M7A
	lda.b mula
	sta.w M7B
	lda.w MPYH
	rep #$30						; 16-bit registers
	and.w #$00FF
	sta.b mula+2
	sta.b mulb+2
	sta.b mulres+2
	lda.w MPYL
	sta.b mula
	sta.b mulb
	sta.b mulres
	rtl
.full:								; multiply in hardware
	sep #$20						; 8-bit A
	lda.b mula
	sta.w WRMPYA
	lda.b mulb
	sta.w WRMPYB
	rep #$30						; 16-bit registers
	rep #$30						; 16-bit registers
	clc
	lda.w RDMPYL
	sta.b mulres
	stz.b mulres+2
	sep #$20						; 8-bit A
	lda.b mulb+1
	sta.w WRMPYB
	rep #$30						; 16-bit registers
	rep #$30						; 16-bit registers
	clc
	lda.w RDMPYL
	adc.b mulres+1
	sta.b mulres+1
	sep #$20						; 8-bit A
	bcc .c1
	inc.b mulres+3
.c1:								; multiply by the high byte of mulb
	lda.b mula+1
	sta.w WRMPYA
	lda.b mulb
	sta.w WRMPYB
	rep #$30						; 16-bit registers
	rep #$30						; 16-bit registers
	clc
	lda.w RDMPYL
	adc.b mulres+1
	sta.b mulres+1
	sep #$20						; 8-bit A
	bcc .c2
	inc.b mulres+3
.c2:								; use the high byte of mulb
	lda.b mulb+1
	sta.w WRMPYB
	rep #$30						; 16-bit registers
	rep #$30						; 16-bit registers
	clc
	lda.w RDMPYL
	adc.b mulres+2
	sta.b mula+2
	sta.b mulb+2
	sta.b mulres+2
	lda.b mulres
	sta.b mula
	sta.b mulb
	clc
	rtl
