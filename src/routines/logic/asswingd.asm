asswingd:		;Assignment: a wing on defense covers his side between the puck and the goal
	lda.w pfalock,x
	beq .clk
	jmp.w .rtl
.clk:
	lda.w gmclock
	beq .bench
	jml.l assnothing
.bench:
	jsl.l check4bench
	lda.w pflags,x
	bit.w #pfjoycon
	beq .na
	jmp.w .rtl
.na:
	bit.w #$0002
	beq .nna
	and.w #$FFFD
	sta.w pflags,x
	stz.w temp1,x
	stz.w temp2,x
	lda.w #8
	sta.w temp2b,x
.nna:
	lda.w temp1,x
	sec
	sbc.b d7
	sta.w temp1,x
	bpl .nodec
	clc
	adc.w aidef,x
	bpl .store
	lda.w #$0000
.store:
	sta.w temp1,x
	lda.w puckc		; our team has the puck: awingo
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
	jml.l assreplace
.nodec:
	lda.w #100		; x 100 (left wing -100)
	sta.b d0
	lda.w position,x
	cmp.w #5
	bne .0
	lda.w #-100
	sta.b d0
.0:
	lda.w #158
	sta.b d1
	lda.w pfgoal,x		; pfgoal: defending the top goal
	beq .up
	lda.b d0
	eor.w #$FFFF
	inc a
	sta.b d0
	lda.w #-158
	sta.b d1
	lda.w #-78
	sta.b d2
	ldy.b a2
	lda.w tmflags,y		; offsides: stay at the blue line
	bit.w #tmfoffside
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
	lda.w #-264
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
	lda.w #78
	sta.b d2
	ldy.b a2
	lda.w tmflags,y
	bit.w #tmfoffside
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
	lda.w #264
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
	lda.b d2
	sta.b d1
.go:
	lda.w #rtss		; a0 = rtss: no avoidance
	sta.b a0
	lda.w #rtss>>16
	sta.b a0+2
	lda.w puckx
	eor.b d0
	sta.b d2
	bmi .skate
	lda.w puckx
	sta.b d0
.skate:
	jml.l skateto
unusedFF89:		;unused, $FF fill to the end of the bank
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
