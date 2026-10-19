assbench:							;Assignment: player X skates to the bench door and leaves; the new player
									;comes on
	lda.w pfalock,x					; assignment locked?
	beq .na
	jmp.w .rtl
.na:
	lda.w temp1,x					; bench door timer
	cmp.w #100						; temp1 100: at the bench door
	bne .chk
	jmp.w .done
.chk:
	jsl.l check4bench				; check for a bench change
	lda.w pflags,x					; player flags
	bit.w #pf2pen					; pf2pen: assexit
	beq .pen
	jml.l assexit					; assignment over
.pen:
	bit.w #pfna						; assignment just started?
	beq .nna
	and.w #~pfna&$FFFF
	sta.w pflags,x
	stz.w temp2,x					; reset the timers
	lda.w #8
	sta.w temp2b,x
	lda.w #80						; temp4 = bench y +-80, temp3 = bench x -144
	sta.b d0
	lda.w pfteam,x					; which team
	bne .0
	lda.w #-80
	sta.b d0
.0:									; target y at the bench
	lda.b d0
	sta.w temp4,x					; target y at the bench
	lda.w #-144
	sta.w temp3,x					; target x at the bench
	stz.w temp1,x					; clear the door timer
.nna:
	lda.w newpnum,x					; same player: just change position
	cmp.w pnum,x					; same player: only the position changes
	bne .dec
	jmp.w .nobench
.dec:
	lda.w temp1,x					; count the door timer down
	sec
	sbc.b d7
	sta.w temp1,x
	bmi .near						; expired?
	jmp.w .nodec
.near:
	lda.w temp1,x					; reload it
	adc.w #8
	sta.w temp1,x
	lda.w Ypos,x					; distance from the bench in y
	sec
	sbc.w temp4,x
	bit.w #$8000					; absolute value
	beq .ay
	eor.w #$FFFF					; negate
	inc a
.ay:
	cmp.w #41						; within 40 of the bench y?
	bcc .ax
	jmp.w .nodec
.ax:
	lda.w Xpos,x					; distance from the bench in x
	sec
	sbc.w temp3,x
	sta.b d0
	sec
	sbc.w #32						; within 32 of the bench x?
	beq .gli0
	bmi .neg
	bvs .gli0
.nd:								; far branch to .nodec
	jmp.w .nodec
.neg:								; signed compare: overflow flag corrects the sign
	bvs .nd
.gli0:
	lda.w #SPAglide					; SPAglide (goalie SPAgready)
	sta.b d1
	lda.w position,x				; goalie?
	bne .gli
	lda.w #SPAgready				; goalie ready animation
	sta.b d1
.gli:
	jsl.l SetSPA					; start animation d1
	lda.w #1						; no collisions while gliding
	sta.w pfnc,x
	lda.w facedir,x					; face direction
	cmp.w #4						; facing the wall?
	beq .ok
	inc a							; turn one step
	and.w #$0007
	sta.w facedir,x
.ok:
	stz.w Yvel,x					; stop moving in y
	lda.w #$F800					; slide toward the door
	sta.w Xvel,x
	lda.b d0						; distance in x
	sec
	sbc.w #16						; within 16 of the door?
	beq .stop
	bmi .neg1
	bvs .stop
	bra .rtl
.neg1:								; signed compare: overflow flag corrects the sign
	bvs .rtl
.stop:
	stz.w Xvel,x					; stop sliding
	lda.w facedir,x					; facing direction
	cmp.w #4
	bne .rtl
	lda.w #$F800					; keep sliding
	sta.w Xvel,x
	lda.w #2						; face left
	sta.w facedir,x
	lda.w #SPAwallleft				; SPAwallleft
	sta.b d1
	jsl.l SetSPA					; start animation d1
	lda.w #100
	sta.w temp1,x					; door timer 100: at the door
	sta.w pfalock,x					; lock the assignment
.rtl:								; return
	rtl
.done:
	stz.w frame,x					; hide the sprite
	lda.w pnum,x					; player number
	asl a
	sta.b d0
	stz.b a0
	lda.w pfteam,x					; which team
	beq .away
	lda.w #2
	sta.b a0
.away:								; which team's bench
	lda.b a0
	beq .t0
	lda.w #maxros*2					; second team offset
.t0:								; index the bench slot
	clc
	adc.b d0
	tay
	lda.w #TMPDBENCH				; TMPDBENCH: on the bench
	sta.w tmpdst,y
	lda.w newpnum,x					; new player number
	sta.b d3
	jsl.l .nobench2					; put the new player in
	jml.l setplayer					; set up the new player
.nodec:
	lda.w pfnc,x					; collisions on: skate
	bne .rtl
	lda.w temp3,x					; target x at the bench
	sta.b d0
	lda.w temp4,x					; target y at the bench
	sta.b d1
	lda.w #EvadePC					; avoidance routine
	sta.b a0
	lda.w #EvadePC>>16
	sta.b a0+2
	jml.l skateto					; skate to the bench
.nobench:
	lda.w pflags,x					; clear the unavailable flag
	and.w #~pf2unav&$FFFF
	sta.w pflags,x
.nobench2:							;position = newpos (Setplass), newpnum/newpos -1
	lda.w newpos,x					; new position
	sta.b d0
	sta.w position,x				; take it
	jsl.l Setplass					; set up the position
	lda.w #$FFFF					; clear new player and position
	sta.w newpnum,x
	sta.w newpos,x
	rtl
