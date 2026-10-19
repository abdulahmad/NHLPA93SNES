randomd0s:							;randomas with the range in d0
	lda.b d0						; range
	pha								; keep it
	asl.b d0						; twice the range
	jsl.l randomd0					; random 0 to 2d0-1
	pla
	eor.w #$FFFF					; negate the range
	inc a
	clc
	adc.b d0						; minus the range: -d0 to d0-1
	sta.b d0
	clc
	rtl
