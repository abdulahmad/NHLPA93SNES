checkagr:							;Penalty roll for player X: random below (20 - aggress) * 16, doubled
									;for a joystick player, halved near the puck; small results call a penalty
	lda.w #$0014					; 20 minus aggress
	sec
	sbc.w aggress,x
	asl a
	asl a
	asl a
	asl a							; times 16
	sta.b d0
	lda.w pflags,x					; flags
	bit.w #pfjoycon
	beq .nojoy						; human controlled
	asl.b d0						; doubles
.nojoy:								; x distance to the puck
	lda.w Xpos,x					; x distance
	sec
	sbc.w puckx
	bit.w #$8000					; absolute value
	beq .xpos
	eor.w #$FFFF					; negate
	inc a
.xpos:								; within 40 in x?
	cmp.w #$0029					; within 40
	bcs .far
	lda.w Ypos,x					; y distance
	sec
	sbc.w pucky
	bit.w #$8000					; absolute value
	beq .ypos
	eor.w #$FFFF					; negate
	inc a
.ypos:								; within 40 in y: near the puck, halve
	cmp.w #$0029					; within 40
	bcs .far
	lsr.b d0						; near the puck: halve
.far:								; random roll of d0
	jml.l randomd0					; random roll
