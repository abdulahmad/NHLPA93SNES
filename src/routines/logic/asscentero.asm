asscentero:							;Assignment: the center on offense skates to a spot in the zone of the
									;puck, avoiding the puck carrier
	lda.w pfalock,x					; anim locked: nothing
	beq .clk
	jmp.w .rtl
.clk:
	lda.w gmclock					; clock stopped: assnothing
	beq .go
	jml.l assnothing
.go:
	jsl.l check4bench				; check for a bench change
	lda.w pflags,x					; joystick controlled: nothing
	bit.w #pfjoycon
	beq .na
	jmp.w .rtl
.na:
	bit.w #pfna						; new assignment: temp5 = -1 (old zone), temp1 = 0, temp2 = 8
	beq .nna
	and.w #~pfna&$FFFF
	sta.w pflags,x
	lda.w #$FFFF					; no zone yet
	sta.w temp5,x					; clear the timers
	stz.w temp1,x
	stz.w temp2,x
	lda.w #$0008
	sta.w temp2b,x
.nna:
	lda.w temp1,x					; every aidef frames
	sec
	sbc.b d7
	sta.w temp1,x					; expired: reevaluate
	bmi .dec
	jmp.w .nodec
.dec:
	clc
	adc.w aidef,x					; reload from aidef
	bpl .st							; not below zero
	lda.w #$0000
.st:
	sta.w temp1,x
	lda.w puckc						; other team has the puck: acenterd
	bmi .de0
	sec
	sbc.w #$0006					; puck side
	sta.b d1
	lda.w #acenterd
	sta.b d0
	txa
	sec
	sbc.w #$000C					; compare with this player's side
	eor.b d1
	bpl .de0
	jml.l assreplace				; replace the assignment with d0
.de0:
	lda.w pucky						; d0 = pucky toward the attacking end
	sta.b d0
	lda.w pfgoal,x
	bne .de1
	lda.b d0
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
.de1:								;zone number
	stz.b d2						; zone 0: own zone
	lda.b d0
	sec
	sbc.w #$FFA8					; first zone limit
	bmi .neg1
	bvc .z1
	bra .de2
.neg1:								; signed compare: overflow flag corrects the sign
	bvc .de2
.z1:
	lda.w #$0008					; zone 8
	sta.b d2
	lda.b d0
	sec
	sbc.w #blueline					; blue line
	bmi .neg2
	bvc .z2
	bra .de2
.neg2:								; signed compare: overflow flag corrects the sign
	bvc .de2
.z2:
	ldy.b a2						; tmflags bit 4: stay in the middle zone
	lda.w tmflags,y
	bit.w #tmfoside
	bne .de2
	asl.b d2						; zone 16
	lda.b d0
	sec
	sbc.w #$0108					; far zone limit
	bmi .neg3
	bvc .z3
	bra .de2
.neg3:								; signed compare: overflow flag corrects the sign
	bvc .de2
.z3:
	lda.w #$0018					; zone 24
	sta.b d2
.de2:
	lda.b d2						; same zone: new spot only 1 in 128
	cmp.w temp5,x					; same zone as last time?
	bne .de3
	lda.w seed+2					; random
	cmp.w #$0200
	bcs .nodec
.de3:
	lda.b d2						; remember the zone
	sta.w temp5,x
	tay								; zone table
	lda.w #.dedata					; temp3/temp4 = .dedata spot + randomas of the range
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
	lda.w temp4,x					; spot y
	sta.b d1
	lda.w pfgoal,x					; which end
	bne .0
	lda.b d1
	eor.w #$FFFF					; negate
	inc a
	sta.b d1
.0:
	lda.w #EvadePC					; skateto with the EvadePC callback
	sta.b a0
	lda.w #EvadePC>>16
	sta.b a0+2
	jml.l skateto					; d0/d1 = target, a0 = callback
.rtl:								; return
	rtl
.dedata:							;per zone (x, random x range, y, random y range)
	dw 0,60,-70,10					; zone 0
	dw 0,60,60,10					; zone 1
	dw 0,40,170,30					; zone 2
	dw 0,80,170,20					; zone 3
unusedFF82:							;unused, $FF fill to the end of the bank
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
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
