skateto:							;Skate toward d0 / d1, with a routine in a0 for avoiding others; slow down
									;near the target
	lda.w position,x				; goalie?
	beq .tick
	lda.w pflags,x					; player flags
	and.w #$8000					; flags bit 15
	ora.w sfhormode					; plus the horizontal mode
	bne .tick						; goalies and special modes skip the slowdown
	lda.b d0						; target x
	bit.w #$8000
	beq .ax
	eor.w #$FFFF					; negate
	inc a
.ax:								; within $88 of the center?
	cmp.w #$0088					; within $88 of the center?
	bcs .tick
	lda.w Xpos,x					; X's x
	sec
	sbc.b d0						; minus the target x
	bit.w #$8000
	beq .dx
	eor.w #$FFFF					; negate
	inc a
.dx:								; dx
	sta.b tmp0						; dx
	lda.w Ypos,x					; X's y
	sec
	sbc.b d1						; minus the target y
	bit.w #$8000
	beq .dy
	eor.w #$FFFF					; negate
	inc a
.dy:								; less than 55 away?
	clc								; dx + dy
	adc.b tmp0
	cmp.w #55						; less than 55 away?
	bcs .tick
	lda.w Xvel,x					; slow down: velocity * 7 / 8
	sta.b mula
	lda.w #7						; times 7
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lsr.b mulres+2					; divide by 8
	ror a
	lsr.b mulres+2
	ror a
	lsr.b mulres+2
	ror a
	sta.w Xvel,x					; new x velocity
	lda.w Yvel,x					; y velocity
	sta.b mula
	lda.w #7						; times 7
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lsr.b mulres+2					; divide by 8
	ror a
	lsr.b mulres+2
	ror a
	lsr.b mulres+2
	ror a
	sta.w Yvel,x					; new y velocity
.tick:								;every 12/60 second
	lda.w temp2,x					; skateto timer
	sec
	sbc.b d7						; minus the frame count
	sta.w temp2,x
	bmi .go							; not due: reuse the last direction
	jmp.w .ex
.go:								; only execute every 12/60 sec
	adc.w #11						; only execute every 12/60 sec
	sta.w temp2,x
	jsl.l avdgoal					; may change the target to go around the goal
	lda.w #13						; closeness limit 13
	sta.b d0+2
	lda.b d0						; target x
	bit.w #$8000
	beq .near
	eor.w #$FFFF					; negate
	inc a
.near:								; near the center: limit 18
	cmp.w #$0088					; within $88 of the center?
	bcs .av
	lda.w #18						; near the center: limit 18
	sta.b d0+2
.av:								; goal correction applied? then skip the lead
	lda.b deltax					; goal correction applied?
	ora.b deltay					; if so skip the lead
	beq .lead
	lda.b d0						; target x
	sec
	sbc.w Xpos,x					; minus my x
	sta.b d0
	lda.b d1						; target y
	sec
	sbc.w Ypos,x					; minus my y
	sta.b d1
	bra .vt							; go to the direction
.lead:								;aim ahead of the velocity
	lda.w Xvel,x					; x velocity high byte
	xba
	and.w #$00FF
	bit.w #$0080
	beq .lx
	ora.w #$FF00
.lx:								; negate x
	eor.w #$FFFF					; negate
	inc a
	clc
	adc.b d0						; plus the target x
	sec
	sbc.w Xpos,x					; minus my x
	sta.b d0
	lda.w Yvel,x					; y velocity high byte
	xba
	and.w #$00FF
	bit.w #$0080
	beq .ly
	ora.w #$FF00
.ly:								; negate y
	eor.w #$FFFF					; negate
	inc a
	clc
	adc.b d1						; plus the target y
	sec
	sbc.w Ypos,x					; minus my y
	sta.b d1
	lda.b d0						; remaining dx
	bit.w #$8000
	beq .cx
	eor.w #$FFFF					; negate
	inc a
.cx:								; within the distance in x?
	cmp.b d0+2						; within the distance in x?
	bcs .vt
	lda.b d1						; remaining dy
	bit.w #$8000
	beq .cy
	eor.w #$FFFF					; negate
	inc a
.cy:								; within the distance in y?
	cmp.b d0+2						; within the distance in y?
	bcs .vt
	lda.w #9						; close enough: no direction
	sta.b d0
	bra .nvt						; skip the vector
.vt:								; d0 = direction 0-7 to the target
	jsl.l vtoa						; vector to direction
.nvt:								;jsr (a0) through jmlvector
	lda.b a0						; caller's avoidance routine
	sta.w jmlvector+1
	lda.b a0+1
	sta.w jmlvector+2
	jsl.l jmlvector					; may adjust the direction in d0
	lda.b d0						; remember the direction
	sta.w temp2b,x
	cmp.w #8						; a real direction: go accelerate
	bcc .ex
	lda.w Xvel,x					; no direction: if standing still, turn toward the puck
	ora.w Yvel,x
	bne .ex							; still moving
	lda.w puckx						; puck x
	sta.b d0
	lda.w pucky						; puck y
	sta.b d1
	lda.w pf2fight+puckobj			; puck flagged for a fight?
	beq .nf
	lda.w xc1						; then face xc1, yc1 instead
	sta.b d0
	lda.w yc1
	sta.b d1
.nf:								; d0/d1 = point to face
	lda.b d0						; point to face
	sec
	sbc.w Xpos,x					; minus my x
	sta.b d0
	lda.b d1
	sec
	sbc.w Ypos,x					; minus my y
	sta.b d1
	jsl.l vtoa						; vector to direction
	sec
	sbc.w facedir,x					; minus the facing
	beq .ex							; already facing it
	eor.w #$FFFF					; negate
	inc a
	and.w #$0004					; keep the turn sense
	lsr a
	dec a							; one step in the shorter direction
	clc
	adc.w facedir,x					; new facing
	and.w #$0007
	sta.w facedir,x
.ex:								; d0 = stored direction
	lda.w temp2b,x					; stored direction
	sta.b d0
	jml.l doplayeracc				; accelerate that way
unusedFF88:							;unused, $FF fill to the end of the bank
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
