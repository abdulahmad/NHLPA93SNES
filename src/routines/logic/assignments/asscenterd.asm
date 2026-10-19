asscenterd:							;Assignment: the center on defense, halfway between the puck and his goal;
									;switches to offense when his team
		;   gets the puck
	lda.w gmclock					; clock stopped
	beq .go
	jml.l assnothing				; stand still
.go:
	jsl.l check4bench				; bench check
	lda.w pflags,x					; flags
	bit.w #pfjoycon					; human
	beq .nopflags
	jmp.w .rtl						; leave
.nopflags:
	bit.w #pfna						; new assignment?
	beq .nna
	and.w #~pfna&$FFFF				; clear the flag
	sta.w pflags,x
	stz.w temp1,x					; temp1 = 0
	stz.w temp2,x
	lda.w #$0008					; temp2b = 8
	sta.w temp2b,x
.nna:
	lda.w temp1,x					; timer
	sec
	sbc.b d7						; minus d7
	sta.w temp1,x
	bpl .nodec						; not up
	lda.w aidef,x					; reload from aidef
	sta.w temp1,x
	lda.w puckc						; puck carrier
	bmi .nodec						; none
	sec
	sbc.w #$0006					; his side
	sta.b d1						; d1
	lda.w #$0006					; new assignment: offense
	sta.b d0
	txa								; player
	lsr a
	sec
	sbc.w #$0006					; his side
	eor.b d1						; same side?
	bmi .nodec						; no
	jml.l assreplace				; switch
.nodec:
	lda.w puckx						; puck x
	pha
	asl a							; /2
	pla
	ror a
	sta.b d0						; target x
	lda.w #$0080					; target y
	sta.b d1
	lda.w pfgoal,x					; goal end
	beq .nopfgoal					; top
	lda.w #$FF80					; bottom end
	sta.b d1
	lda.w #$FFA8
	sec								; puck y
	sbc.w pucky
	beq .half						; on the line
	bmi .neg
	bvs .half
	bra .z1
.neg:								; signed compare: overflow flag corrects the sign
	bvs .z1
.half:
	lda.w #$FF80					; halfway
	clc
	adc.w pucky						; plus puck y
	pha
	asl a
	pla								; /2
	ror a
	sta.b d1
	bra .z1							; skate there
.rtl:								; return
	rtl
.nopfgoal:
	lda.w #blueline					; blue line
	sec
	sbc.w pucky						; minus puck y
	bmi .neg1
	bvc .half2
	bra .z1
.neg1:								; signed compare: overflow flag corrects the sign
	bvc .z1
.half2:								; puck y for the second half
	lda.b d1
	clc
	adc.w pucky						; plus puck y
	pha
	asl a
	pla								; /2
	ror a
	sta.b d1
.z1:
	lda.w #rtss						; no callback
	sta.b a0
	lda.w #rtss>>16
	sta.b a0+2
	jml.l skateto					; skate to d0 / d1
