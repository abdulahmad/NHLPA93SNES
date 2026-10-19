asswingd:							;Assignment: a wing on defense covers his side
									;between the puck and the goal
	lda.w pfalock,x					; assignment locked?
	beq .clk
	jmp.w .rtl
.clk:
	lda.w gmclock					; clock stopped: do nothing
	beq .bench
	jml.l assnothing
.bench:
	jsl.l check4bench				; check for a bench change
	lda.w pflags,x
	bit.w #pfjoycon					; human controlled player?
	beq .na
	jmp.w .rtl
.na:
	bit.w #pfna						; assignment just started?
	beq .nna
	and.w #~pfna&$FFFF
	sta.w pflags,x
	stz.w temp1,x					; reset the timers
	stz.w temp2,x
	lda.w #8						; temp2b = 8
	sta.w temp2b,x
.nna:
	lda.w temp1,x					; countdown timer
	sec
	sbc.b d7						; minus the frame count
	sta.w temp1,x
	bpl .nodec						; still counting
	clc
	adc.w aidef,x					; reload from aidef
	bpl .store
	lda.w #$0000					; not below zero
.store:
	sta.w temp1,x
	lda.w puckc						; our team has the puck: awingo
	bmi .nodec
	sec
	sbc.w #6
	sta.b d1
	lda.w #4
	sta.b d0
	txa
	lsr a
	sec
	sbc.w #6
	eor.b d1
	sta.b d1
	bmi .nodec
	jml.l assreplace				; replace the assignment with d0
.nodec:
	lda.w #100						; x 100 (left wing -100)
	sta.b d0
	lda.w position,x				; position 5 is the left wing
	cmp.w #5
	bne .0
	lda.w #-100						; mirror x for the left wing
	sta.b d0
.0:
	lda.w #158
	sta.b d1						; target y 158
	lda.w pfgoal,x					; pfgoal: defending the top goal
	beq .up
	lda.b d0						; bottom goal: mirror x
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	lda.w #-158						; and y
	sta.b d1
	lda.w #-78						; d2 = blue line y
	sta.b d2
	ldy.b a2						; team of this player
	lda.w tmflags,y					; offsides: stay at the blue line
	bit.w #tmfoside
	bne .set
	lda.b d2
	sec
	sbc.w pucky
	beq .hi0
	bmi .neg
	bvs .hi0
	bra .lo
.neg:
	bvs .lo
.hi0:
	lda.w pucky
	sta.b d1
	bra .go
.rtl:
	rtl
.lo:
	lda.w #-264						; far limit y -264
	sta.b d2
	sec
	sbc.w pucky
	bmi .neg1
	bvc .set1
	bra .go
.neg1:
	bvc .go
.set1:
	bra .set
.up:
	lda.w #78						; top goal: blue line y 78
	sta.b d2
	ldy.b a2
	lda.w tmflags,y
	bit.w #tmfoside
	bne .set
	lda.b d2
	sec
	sbc.w pucky
	bmi .neg2
	bvc .up0
	bra .hi
.neg2:
	bvc .hi
.up0:
	lda.w pucky
	sta.b d1
	bra .go
.hi:
	lda.w #264						; far limit y 264
	sta.b d2
	sec
	sbc.w pucky
	beq .set
	bmi .neg3
	bvs .set
	bra .go
.neg3:
	bvs .go
.set:
	lda.b d2						; use the limit
	sta.b d1
.go:
	lda.w #rtss						; a0 = rtss: no avoidance
	sta.b a0
	lda.w #rtss>>16
	sta.b a0+2
	lda.w puckx						; puck x
	eor.b d0						; compare with the target x
	sta.b d2
	bmi .skate
	lda.w puckx
	sta.b d0						; follow the puck x
.skate:
	jml.l skateto					; skate to d0, d1
unusedFF89:							;unused, $FF fill to the end of the bank
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF
