find3d:								;Project a rink position (x, y, z) to screen coordinates; off screen when
									;too far away
	lda.w sfhormode
	beq .nhor
	lda.b d0						; x
	pha								; keep x
	lda.b d1						; y
	eor.w #$FFFF					; negate
	inc a
	sta.b d0						; y negated
	pla
	sec
	sbc.w #$00C5					; minus $C5
	sta.b d1
	bra .cx
.nhor:								; position relative to the scroll
	lda.b d0						; normal mode: x minus Hpos
	sec
	sbc.w Hpos						; minus the scroll x
	sta.b d0
	lda.b d1
	sec								; y
	sbc.w Vpos						; minus the scroll y
	sta.b d1
.cx:								; absolute X
	lda.b d0
	bit.w #$8000					; absolute x
	beq .ax
	eor.w #$FFFF					; negate
	inc a
.ax:								; |x| > 144: off screen
	cmp.w #$0091					; |x| > 144: off
	bcs .off
	lda.b d0
	adc.w #$0080					; center on screen x 128
	sta.b d0
	lda.b d2						; d1 += 1.5 * z
	asl a
	clc
	adc.b d2
	pha
	asl a
	pla
	ror a
	clc
	adc.b d1						; plus y
	sta.b d1
	bit.w #$8000					; absolute y
	beq .ay
	eor.w #$FFFF					; negate
	inc a
.ay:								; offscreen check
	cmp.w #$0091
	bcs .off
	lda.w #$0070					; center y $70
	sec
	sbc.b d1						; screen y
	sta.b d1
	rtl
.off:								; off screen marker
	lda.w #OFFSCREEN				; off screen marker
	sta.b d1
	rtl
