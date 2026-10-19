checkagr:							;Penalty roll for player X: small results call a penalty. Joystick players
									;are judged less often, players
		;   near the puck more often
	lda.w #$0014					; $14 minus the energy left
	sec
	sbc.w GGSleft,x
	asl a
	asl a
	asl a
	asl a							; times 16
	sta.b d0
	lda.w pflags,x					; flags
	bit.w #pfjoycon
	beq .nojoy						; human controlled
	asl.b d0						; doubles
.nojoy:
	lda.w Xpos,x					; x distance
	sec
	sbc.w puckx
	bit.w #$8000					; absolute value
	beq .xpos
	eor.w #$FFFF					; negate
	inc a
.xpos:
	cmp.w #$0029					; within 40
	bcs .far
	lda.w Ypos,x					; y distance
	sec
	sbc.w pucky
	bit.w #$8000					; absolute value
	beq .ypos
	eor.w #$FFFF					; negate
	inc a
.ypos:
	cmp.w #$0029					; within 40
	bcs .far
	lsr.b d0						; near the puck: halve
.far:
	jml.l randomd0					; random roll
