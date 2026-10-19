asswingo:							;Assignment: a wing on offense skates to a spot in the zone of the puck
	lda.w pfalock,x					; assignment locked?
	beq .run
	jmp.w .rtl
.run:
	lda.w gmclock					; clock stopped: do nothing
	beq .notclock
	jml.l assnothing
.notclock:
	jsl.l check4bench				; check for a bench change
	lda.w pflags,x
	bit.w #pfjoycon					; human controlled player?
	beq .notjoy
	jmp.w .rtl
.notjoy:
	bit.w #pfna						; assignment just started?
	beq .nna
	and.w #~pfna&$FFFF
	sta.w pflags,x
	lda.w #$FFFF					; temp5 = -1: no zone yet
	sta.w temp5,x
	stz.w temp1,x					; reset the timers
	stz.w temp2,x
	lda.w #$0008
	sta.w temp2b,x
.nna:
	lda.w temp1,x					; timer
	sec
	sbc.b d7						; minus the frame count
	sta.w temp1,x
	bmi .reload						; expired: reevaluate
	jmp.w .nodec
.reload:
	clc
	adc.w aidef,x					; reload from aidef
	bpl .t1
	lda.w #$0000					; not below zero
.t1:
	sta.w temp1,x
	lda.w #awingd					; awingd
	sta.b d0
	lda.w puckc						; the other team has the puck
	bmi .de0						; loose puck: skip
	sec
	sbc.w #6						; puck side
	sta.b d1
	txa
	sec
	sbc.w #12						; compare with this player's side
	eor.b d1
	bpl .de0
	jml.l assreplace				; replace the assignment with d0
.de0:
	lda.w pucky						; d3 = pucky + puckvy / 64
	sta.b d0
	lda.w puckvy					; puck y velocity
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	bit.w #$0200					; sign extend
	beq .vy
	ora.w #$FC00
.vy:
	clc
	adc.b d0						; d3 = puck y plus velocity / 64
	sta.b d3
	lda.w pfgoal,x					; which end
	bne .de1
	lda.b d0
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	lda.b d3
	eor.w #$FFFF					; negate
	inc a
	sta.b d3
.de1:								;zone number
	stz.b d2						; zone 0: own zone
	lda.b d3
	sec
	sbc.w #-88						; first zone limit
	bmi .neg
	bvc .z1
	bra .de2
.neg:
	bvc .de2
.z1:
	lda.w #8						; zone 8: centre
	sta.b d2
	lda.b d0
	sec
	sbc.w #blueline					; blue line
	bmi .neg1
	bvc .z2
	bra .de2
.neg1:
	bvc .de2
.z2:
	ldy.b a2
	lda.w tmflags,y
	bit.w #tmfoside					; offsides: stay back
	bne .de2
	asl.b d2						; zone 16: their zone
	lda.b d3
	sec
	sbc.w #264						; far zone limit
	bmi .neg2
	bvc .z3
	bra .de2
.neg2:
	bvc .de2
.z3:
	lda.w #24						; zone 24: past the goal line
	sta.b d2
.de2:
	lda.b d2
	cmp.w temp5,x					; same zone as last time?
	bne .de3
	lda.w seed						; same zone: new spot only now and then
	cmp.w #$0200					; random
	bcs .nodec
.de3:
	lda.b d2
	sta.w temp5,x					; remember the zone
	tay
	lda.w #.dedata					; temp3 = x + random, temp4 = y + random
	sta.b a0
	lda.w #.dedata>>16
	sta.b a0+2
	iny
	iny
	lda.b [a0],y					; x random range
	dey
	dey
	jsl.l randomas					; random number -A to A-1
	adc.b [a0],y					; plus the zone x
	sta.w temp3,x					; temp3 = spot x
	iny
	iny
	iny
	iny
	iny
	iny
	lda.b [a0],y					; y random range
	dey
	dey
	jsl.l randomas					; random number -A to A-1
	adc.b [a0],y					; plus the zone y
	sta.w temp4,x					; temp4 = spot y
.nodec:
	lda.w temp3,x					; spot x
	sta.b d0
	lda.w position,x				; position 5: left wing
	cmp.w #5						; mirror x for the other wing
	beq .1
	lda.b d0
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
.1:
	lda.w temp4,x					; spot y
	sta.b d1
	lda.w pfgoal,x					; which end
	bne .0
	lda.b d0
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	lda.b d1
	eor.w #$FFFF					; negate
	inc a
	sta.b d1
.0:
	lda.w #EvadePC					; avoid the puck carrier (EvadePC)
	sta.b a0
	lda.w #EvadePC>>16
	sta.b a0+2
	jml.l skateto					; skate to the spot
.rtl:
	rtl
.dedata:							;x, x random, y, y random per zone
	dw 80,20,-70,10					; own zone
	dw 100,20,60,10					; centre
	dw 60,50,230,20					; their zone
	dw 80,30,250,20					; past the goal line
