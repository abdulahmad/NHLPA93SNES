assfwatch:							;Assignment: a player watching a fight skates to a spot near it
	lda.w pfalock,x					; assignment locked?
	beq .joy
	jmp.w .rts
.joy:
	lda.w pflags,x					; player flags
	bit.w #pfjoycon					; joystick controlled
	beq .na
	jmp.w .rts
.na:
	bit.w #pfna						; clear the timer
	beq .nna
	and.w #~pfna&$FFFF
	sta.w pflags,x
	stz.w temp1,x
.nna:
	lda.w temp1,x					; timer
	sec
	sbc.b d7						; minus the frame count
	sta.w temp1,x
	bmi .spot						; expired: new spot
	jmp.w .go
.spot:								;new spot every second
	adc.w #$003C					; +60
	sta.w temp1,x					; reload the timer
	lda.w Ypos,x					; player y
	sec
	sbc.w yc1						; minus the fight y
	pha								; keep dy
	lda.w Xpos,x					; player x
	sec
	sbc.w xc1						; minus the fight x
	pha								; keep dx
	sta.b mula						; dx squared
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b d0
	lda.b mulres+2					; d0 = dx squared
	sta.b d0+2
	lda.b $03,s						; dy
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	adc.b d0						; plus dy squared
	sta.b d0
	lda.b mulres+2
	adc.b d0+2
	sta.b d0+2
	jsl.l sroot						; distance to the fight
	lda.b d0
	bne .d							; avoid dividing by zero
	lda.w #$0001
.d:
	sta.b d2						; d2 = distance
	pla
	sta.b d0						; dx
	sta.b mulb
	pla								; dy
	sta.b d1
	lda.w #$0050					; 80 pixels from the fight
	sta.b mula
	jsl.l muls32					; signed 32-bit multiply
	lda.b d2						; distance
	sta.b mula
	jsl.l divs						; signed divide
	adc.w xc1						; plus the fight x
	sta.b d0						; d0 = spot x
	lda.w #$007E					; x within +-$7E
	sta.b d3						; limit x to +-126
	lda.b d0
	sec
	sbc.b d3
	bmi .neg
	bvc .cl1
	bra .x0
.neg:
	bvc .x0
.cl1:
	lda.b d3						; upper limit
	sta.b d0
.x0:
	lda.b d3
	eor.w #$FFFF					; negate
	inc a
	sta.b d3						; negate the limit
	lda.b d0						; lower limit
	sec
	sbc.b d3
	beq .cl2
	bmi .neg1
	bvs .cl2
	bra .x1
.neg1:
	bvs .x1
.cl2:
	lda.b d3						; lower limit
	sta.b d0
.x1:
	lda.b d0
	sta.w temp3,x					; store the spot x
	lda.w #$0050					; 80 pixels
	sta.b mula
	lda.b d1
	sta.b mulb						; dy
	jsl.l muls32					; signed 32-bit multiply
	lda.b d2
	sta.b mula
	jsl.l divs						; signed divide
	adc.w yc1						; plus the fight y
	sta.w temp4,x					; spot y
.go:
	lda.w temp3,x					; spot x
	sta.b d0
	lda.w temp4,x					; spot y
	sta.b d1
	lda.w #rtss						; a0 = rtss
	sta.b a0						; no avoidance
	lda.w #rtss>>16
	sta.b a0+2
	lda.w Xvel,x					; halve the velocity while watching
	pha
	asl a
	pla
	ror a
	sta.w Xvel,x					; new x velocity
	lda.w Yvel,x
	pha
	asl a
	pla
	ror a
	sta.w Yvel,x					; new y velocity
	jsl.l skateto					; d0/d1 = spot, [a0] = arrival routine
	jmp.w check4check				; then check for a check
.rts:
	rtl
