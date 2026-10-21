assfight:							;Assignment: fighting. A computer fighter punches when close; both stay
									;near the fight spot
	lda.w pfalock,x					; animation locked?
	beq .go
	jmp.w .rts
.go:								; fight over?
	lda.w Pencntdwn					; fight over
	bpl .chkna
	jml.l assnothing
.chkna:								; new assignment?
	lda.w pflags,x					; player flags
	bit.w #pfna
	beq .nna
	and.w #~pfna&$FFFF
	sta.w pflags,x
	jsl.l getpde					; energy
	lda.w fighting,x				; getpde * fighting / $1000
	sta.b d1
	sta.b mula
	lda.b d0
	sta.b mulb
	jsl.l mulu16					; mulu, mulres = mula*mulb
	xba								; divide by $1000
	and.w #$00FF
	lsr a
	lsr a
	lsr a
	lsr a
	cmp.w #$0006					; minimum 5
	bcs .s
	lda.w #$0005
.s:									;temp3 = strength (min 5)
	sta.w temp3,x					; temp3 = strength
	stz.w temp2,x					; clear the timers
	stz.w temp2b,x
	lda.w #$FFFF					; temp4 = banner timer
	sta.w temp4,x
	lda.w facedir,x					; facing
	cmp.w #$0002					; one player shows the banner
	bne .nna
	lda.w #$005A
	sta.w temp4,x
.nna:								;keep the fighter within x -$6F..$6F
	lda.w Xpos,x					; X position
	sec
	sbc.w #$006F					; upper x limit $6F
	beq .left
	bmi .neg
	bvc .clampr
	bra .left
.neg:								; signed compare: overflow flag corrects the sign
	bvc .left
.clampr:							; clamp x at the right limit
	stz.w Xvel,x					; stop the velocity
	lda.w #$006F					; clamp x
	sta.w Xpos,x
.left:								; lower x limit
	lda.w Xpos,x					; X position
	sec
	sbc.w #$FF91					; lower x limit
	bmi .neg1
	bvs .clampl
	bra .nna2
.neg1:								; signed compare: overflow flag corrects the sign
	bvs .nna2
.clampl:							; clamp x at the left limit
	stz.w Xvel,x					; stop the velocity
	lda.w #$FF91					; clamp x
	sta.w Xpos,x
.nna2:								;temp4 = banner timer (no banner on the SNES)
	lda.w temp4,x					; banner timer
	sec
	sbc.b d7						; minus the frame count
	sta.w temp4,x
	lda.w temp3,x					; strength
	bpl .fight						; negative: done
	jmp.w .rts
.fight:								; a0 = opponent
	lda.w impactp,x					; a0 = opponent; xc1 = half way between the fighters
	asl a
	sta.b a0						; a0 = opponent offset
	tay
	lda.w Xpos,x					; X position
	adc.w Xpos,y
	pha								; sum
	asl a
	pla
	ror a
	sta.w xc1						; xc1 = average
	lda.w pflags,x
	bit.w #pfjoycon					; joystick: no computer punch
	bne .j
	lda.w pf2aip,x					; set pf2aip, test the old value
	pha
	lda.w #$0001
	sta.w pf2aip,x					; set it
	pla
	bne .j							; already punching: skip
	lda.w Xpos,x					; X position
	sec
	sbc.w Xpos,y					; minus the opponent's x
	sta.b d0
	lda.w Xvel,x					; X velocity
	xba
	and.w #$00FF
	bit.w #$0080
	beq .vx1
	ora.w #$FF00
.vx1:								; add the distance
	clc
	adc.b d0						; plus the distance
	sta.b d0
	lda.w Xvel,y					; opponent velocity
	xba
	and.w #$00FF
	bit.w #$0080
	beq .vx2
	ora.w #$FF00
.vx2:								; d1 = his velocity
	sta.b d1						; d1 = his velocity
	lda.b d0
	sec
	sbc.b d1
	sta.b d0						; distance with the velocities
	bit.w #$8000
	beq .inrange
	eor.w #$FFFF					; negate
	inc a
.inrange:							; computer punches only within range
	cmp.w #$0019					; computer punches only within 25 pixels
	bcs .j
	lda.w #$0008					; random 0-7
	sta.b d0
	jsl.l randomd0					; random number 0 to d0-1
	lda.b d0						; 0-2: use as is
	cmp.w #$0003
	bcc .p
	and.w #$0001					; else 0 or 1
	sta.b d0
.p:									;choose the punch type from .al
	asl.b d0						; index into the punch table
	lda.w #.al
	sta.b a1
	lda.w #.al>>16
	sta.b a1+2
	ldy.b d0
	lda.b [a1],y					; punch animation
	sta.b d1
	jsl.l SetSPA					; start animation d1
.j:									; check whether this punch connected
	jsl.l chkhit					; check for a hit
	lda.w SPA,x						; current animation
	cmp.w #SPAfheld					; held: still pushed
	beq .njc
	cmp.w #SPAfight					; ready: no push
	beq .jc
	lda.w pflags,x
	bit.w #pfjoycon					; joystick player?
	bne .jc
.njc:								;push toward the fight spot (xc1+-10)
	lda.w xc1						; xc1 plus 10
	clc
	adc.w #$000A
	sta.b d0
	lda.w facedir,x					; facing
	cmp.w #$0002
	bne .0
	lda.b d0						; minus $14: the other side
	sec
	sbc.w #$0014
	sta.b d0
.0:									; X offset from the opponent
	lda.b d0
	sec								; minus X position
	sbc.w Xpos,x
	sta.b mula
	lda.w #$0023					; 35 toward the spot, 5 away from it
	sta.b mulb
	lda.w facedir,x					; facing
	sec
	sbc.w #$0004
	eor.b mula
	bmi .mul
	lda.w #$0005					; 5 away from it
	sta.b mulb
.mul:								; signed multiply
	jsl.l muls16					; signed multiply
	sta.b d0
	clc
	adc.w Xvel,x					; add to the velocity
	sta.w Xvel,x
.jc:								;Yvel = (yc1-Ypos)*256, +-$1000
	lda.w yc1						; fight y
	sec
	sbc.w Ypos,x					; minus the Y position
	xba
	and.w #$FF00					; times 256
	sta.b d1
	sec
	sbc.w #$1000					; limit +$1000
	bmi .neg2
	bvc .y1
	bra .y2
.neg2:								; signed compare: overflow flag corrects the sign
	bvc .y2
.y1:								; upper clamp done
	lda.w #$1000					; upper limit
	sta.b d1
.y2:								; Y velocity limit
	lda.b d1
	sec
	sbc.w #$F000
	beq .y3							; limit -$1000
	bmi .neg3
	bvs .y3
	bra .sety
.neg3:								; signed compare: overflow flag corrects the sign
	bvs .sety
.y3:								; lower clamp done
	lda.w #$F000					; lower limit
	sta.b d1
.sety:								; store the new Y velocity
	lda.b d1
	sta.w Yvel,x					; new y velocity
.rts:								; return
	rtl
.al:								;punch animations SPAfhigh, SPAflow, SPAfgrab
	dw SPAfhigh,SPAflow,SPAfgrab
