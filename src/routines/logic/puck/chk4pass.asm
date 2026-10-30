chk4pass:							;Computer player X looks for a good pass: an onside teammate with no
									;opponent in the lane
	lda.w threat					; no threat: pass only now and then (spodds)
	bne .dp0
	lda.w #16
	clc
	adc.w spodds,x
	jsl.l randoma					; random number 0 to A-1
	cmp.w #9
	bcc .dp0
	jmp.w .rtl
.dp0:								; pick a random teammate to pass to
	lda.w #6
	jsl.l randoma					; random number 0 to A-1
	sta.b d0
	cpx.w #12						; team mates of the away team are 6-11
	bcc .dp1
	lda.b d0
	clc
	adc.w #6
	sta.b d0
.dp1:								; from the goalie, or skaters
	lda.w position,x				; not the goalie: only outside the slot
	beq .bl
	lda.w puckx
	bit.w #$8000
	beq .ax
	eor.w #$FFFF					; negate
	inc a
.ax:								; puck X limit
	cmp.w #41
	bcs .bl
	lda.w pucky
	bit.w #$8000
	beq .ay
	eor.w #$FFFF					; negate
	inc a
.ay:								; puck Y limit
	cmp.w #205
	bcc .bl
	jmp.w .rtl
.bl:								; receiver chosen (d0): validate him
	asl.b d0						; not to himself
	cpx.b d0
	bne .b1
	jmp.w .rtl
.b1:								; check the pass target
	ldy.b d0
	sty.b a0
	lda.w position,y				; not to the goalie or an illegal player
	bne .b2
	jmp.w .rtl
.b2:								; illegal pass target: leave
	bpl .b3
	jmp.w .rtl
.b3:								; not unavailable or locked
	lda.w pflags,y					; not unavailable or locked
	and.w #pf2unav
	ora.w pfalock,y
	beq .b4
	jmp.w .rtl
.b4:								; distance in Y to the target
	lda.w Ypos,y
	sta.b d0
	lda.w Ypos,x
	sta.b d1
	lda.w pfgoal,x
	bne .f0
	lda.b d0
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	lda.b d1
	eor.w #$FFFF					; negate
	inc a
	sta.b d1
.f0:								; offsides on?
	lda.w gmode						; offsides: no pass across the blue line
	bit.w #gmoffs
	beq .oko
	lda.b d0
	sec
	sbc.w #Blueline
	sta.b tmp0
	lda.b d1
	sec
	sbc.w #Blueline
	eor.b tmp0
	bpl .oko
	jmp.w .rtl
.oko:								; beyond the blue line?
	lda.b d0						; beyond the blue line, or not more than 15 back
	sec
	sbc.w #Blueline
	beq .le
	bmi .neg
	bvs .le
	bra .ok
.neg:								; signed compare: overflow flag corrects the sign
	bvs .ok
.le:								; compare the lane distance
	lda.b d0
	sec
	sbc.b d1
	sta.b d0
	sec
	sbc.w #-15
	bmi .neg1
	bvc .ok
.miss:								; far branch to .rtl
	jmp.w .rtl
.neg1:								; signed compare: overflow flag corrects the sign
	bvc .miss
.ok:								; receiver accepted: get the pass direction
	lda.w Ypos,y					; passdir, d2 = distance squared
	sec
	sbc.w pucky
	sta.b d1
	pha
	lda.w Xpos,y
	sec
	sbc.w puckx
	sta.b d0
	pha
	jsl.l vtoa						; vector to direction
	sta.w passdir
	pla
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b d2
	lda.b mulres+2
	sta.b d2+2
	pla
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	adc.b d2
	sta.b d2
	lda.b mulres+2
	adc.b d2+2
	sta.b d2+2
	lda.w #5						; the 6 opponents
	sta.b d3
	stz.b a1
	cpx.w #12
	bcs .co0
	lda.w #12
	sta.b a1
.co0:								; check an opponent in the lane
	ldy.b a1
	lda.w Ypos,y
	sec
	sbc.w pucky
	sta.b d1
	lda.w Xpos,y
	sec
	sbc.w puckx
	sta.b d0
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b tmp0
	lda.b mulres+2
	sta.b tmp1
	lda.b d1
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	adc.b tmp0
	sta.b tmp0
	lda.b mulres+2
	adc.b tmp1
	sta.b tmp1
	lda.b d2
	cmp.b tmp0
	lda.b d2+2
	sbc.b tmp1
	bcc .co1
	jsl.l vtoa						; nearer opponent in the lane: no pass
	cmp.w passdir
	beq .rtl
.co1:								; next opponent
	inc.b a1
	inc.b a1
	dec.b d3
	bpl .co0
	jsl.l dopass					; dopass, bank $8F
	lda.w position,x
	beq .rtl
	pla								; drop the return address (3 bytes): assexit returns for the caller
	sep #$20						; 8-bit A
	pla
	rep #$30						; 16-bit registers
	jml.l assexit					; assignment over
.rtl:								; return
	rtl
unusedFF8C:							;unused, $FF fill to the end of the bank
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
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
