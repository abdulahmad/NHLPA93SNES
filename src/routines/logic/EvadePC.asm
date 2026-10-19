EvadePC:							;Near the puck carrier: d0 = the direction away from him
	lda.w puckc
	bmi .rtl						; no carrier: nothing to evade
	lda.w Xvel+1,x					; x after one frame, relative to the puck carrier
	sec
	sbc.w puckvx+1					; minus the carrier's x speed
	and.w #$00FF
	bit.w #$0080
	beq .xs
	ora.w #$FF00					; sign extend
.xs:
	clc
	adc.w Xpos,x					; plus x
	sec
	sbc.w puckx						; minus the carrier's x: dx next frame
	bit.w #$8000
	beq .xa
	eor.w #$FFFF					; absolute value
	inc a
.xa:
	cmp.w #41						; 40 or more away: leave
	bcs .rtl
	lda.w Yvel+1,x
	sec
	sbc.w puckvy+1					; minus the carrier's y speed
	and.w #$00FF
	bit.w #$0080
	beq .ys
	ora.w #$FF00					; sign extend
.ys:
	clc
	adc.w Ypos,x					; plus y
	sec
	sbc.w pucky						; minus the carrier's y: dy next frame
	bit.w #$8000
	beq .ya
	eor.w #$FFFF					; absolute value
	inc a
.ya:
	cmp.w #41						; 40 or more away: leave
	bcs .rtl
	lda.w Xpos,x
	sec
	sbc.w puckx
	sta.b d0						; d0 = dx from the carrier
	lda.w Ypos,x
	sec
	sbc.w pucky
	sta.b d1						; d1 = dy from the carrier
	jml.l vtoa						; vector to direction: away from him
.rtl:
	rtl
