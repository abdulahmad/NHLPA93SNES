asspuckc:							;Assignment: the puck carrier. Checks for offsides, line changes, shots
									;and passes, and skates to a good spot
	txa								; not the carrier: assexit
	lsr a
	cmp.w puckc						; the puck carrier?
	beq .nl
	jmp.w assexit
.nl:								; animation locked?
	lda.w pfalock,x					; anim locked
	beq .clk
	jmp.w .rtl
.clk:								; clock stopped: donothing
	lda.w gmclock					; clock stopped: donothing
	beq .go
	jml.l donothing
.go:								; joystick controlled: assexit
	lda.w pflags,x					; joystick controlled: assexit
	bit.w #pfjoycon
	beq .na
	jmp.w assexit
.na:								; new assignment: temp1 = 0
	bit.w #pfna						; new assignment: temp1 = 0, temp2b = 8, temp3 = random 0-3
	beq .nna
	and.w #~pfna&$FFFF
	sta.w pflags,x
	stz.w temp1,x
	stz.w temp2,x
	lda.w #$0008
	sta.w temp2b,x
	lda.w seed						; random 0-3
	and.w #$0003
	sta.w temp3,x
.nna:								; decision timer counts down by d7 (elapsed frames)
	lda.w temp1,x					; every aioff frames: checkob, chk4lc, chk4shot, chk4pass
	sec
	sbc.b d7						; minus the frame count
	sta.w temp1,x
	bpl .nodec
	adc.w aioff,x					; reload from aioff
	bpl .set
	lda.w #$0000
.set:								; store the countdown, then check the other team and line changes
	sta.w temp1,x
	jsl.l checkob					; check the other team
	jsl.l chk4lc					; line change
	jsl.l chk4shot					; shot
	jsl.l chk4pass					; pass
.nodec:								;d0 = 6 + temp3 (random spot), or position when offsides
	lda.w #$0006					; spot index 6
	clc
	adc.w temp3,x
	sta.b d0
	lda.w #asspuckc_postab				; spot table
	sta.b a0
	lda.w #asspuckc_postab>>16
	sta.b a0+2
	lda.w sflags					; sf2offsig: spot by position
	bit.w #sf2offsig
	beq .nd1
	lda.w position,x				; position index
	sta.b d0
.nd1:								; 4 bytes per entry (x,y words)
	lda.b d0						; d0/d1 = spot x/y, negated for pfgoal clear
	asl a
	asl a
	tay
	lda.b [a0],y					; spot x
	sta.b d0
	iny
	iny
	lda.b [a0],y					; spot y
	sta.b d1
	lda.w pfgoal,x					; which end
	bne .nd0
	lda.b d0
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	lda.b d1
	eor.w #$FFFF					; negate
	inc a
	sta.b d1
.nd0:								; a0 = routine skateto calls to adjust the direction
	lda.w #.chkdir					; skateto with the .chkdir callback
	sta.b a0
	lda.w #.chkdir>>16
	sta.b a0+2
	jml.l skateto					; d0/d1 = target, a0 = callback
.rtl:								; return
	rtl
.chkdir:							;skateto callback. d0 = direction; turn away from an opponent within 20 of
									;where the puck will be (threat = count)
	lda.b d0						; direction from skateto
	and.w #$00FF
	bit.w #$0080
	beq .cd
	ora.w #$FF00
.cd:								; d2/d3 = puck + velocity
	sta.b d0						; d2/d3 = puck + velocity
	lda.w Xvel+1,x					; x velocity high byte
	and.w #$00FF
	bit.w #$0080
	beq .x2
	ora.w #$FF00
.x2:								; future puck X
	clc
	adc.w puckx						; plus the puck x
	sta.b d2						; d2 = future puck x
	lda.w Yvel+1,x
	and.w #$00FF
	bit.w #$0080
	beq .y2
	ora.w #$FF00
.y2:								; future puck Y
	clc
	adc.w pucky						; plus the puck y
	sta.b d3						; d3 = future puck y
	stz.w threat					; no threat yet
	lda.w #$0005					; 6 opponents
	sta.b d4
	stz.b a0						; the 6 opponents
	cpx.w #$000C
	bcs .cd0
	lda.w #$000C
	sta.b a0
.cd0:								; opponent x + velocity - predicted puck x
	ldy.b a0						; opponent
	lda.w Xvel+1,y
	and.w #$00FF
	bit.w #$0080
	beq .cx
	ora.w #$FF00
.cx:								; X distance from the opponent
	clc
	adc.w Xpos,y					; plus his x
	sec
	sbc.b d2						; minus the future puck x
	bit.w #$8000
	beq .ax
	eor.w #$FFFF					; negate
	inc a
.ax:								; within 20 in x?
	cmp.w #$0015					; within 20?
	bcs .next
	lda.w Yvel+1,y
	and.w #$00FF
	bit.w #$0080
	beq .cy
	ora.w #$FF00
.cy:								; Y distance from the opponent
	clc
	adc.w Ypos,y					; plus his y
	sec
	sbc.b d3						; minus the future puck y
	bit.w #$8000
	beq .ay
	eor.w #$FFFF					; negate
	inc a
.ay:								; within 20 in y?
	cmp.w #$0015					; within 20?
	bcs .next
	inc.w threat					; threat +1; facing straight at it: turn one step either way
	lda.w Xpos,x					; vector from him to X
	sec
	sbc.w Xpos,y
	sta.b d0
	lda.w Ypos,x
	sec
	sbc.w Ypos,y
	sta.b d1
	jsl.l vtoa						; vector to direction
	lda.w facedir,x					; X's facing
	eor.w #$0004
	cmp.b d0						; facing straight at him?
	bne .next
	lda.w seed+2					; random
	and.w #$0001					; one step either way
	clc
	adc.b d0
	and.w #$0007					; new direction
	sta.b d0
.next:								; next opponent
	inc.b a0						; next opponent
	inc.b a0
	dec.b d4						; opponents left
	bmi .rtl2
	jmp.w .cd0
.rtl2:								; return
	rtl
