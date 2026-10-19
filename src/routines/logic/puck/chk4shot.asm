chk4shot:							;Computer player X looks for a shot. A penalty killer under pressure in
									;front of his net may clear the puck
	jsl.l chkpk						; penalty killer check
	bne .npk						; not a penalty killer
	lda.w threat					; threat on the puck carrier
	beq .npk
	lda.w Ypos,x					; |Y| of the player
	bit.w #$8000
	beq .yabs
	eor.w #$FFFF					; negate
	inc a
.yabs:								; in front of the net?
	cmp.w #$00ED					; in front of the net
	bcs .npk
	lda.w seed						; one time in four: clear the puck
	and.w #$0003
	bne .npk
	jmp.w CompShoot
.npk:								;d4 = shot odds ($20-spodds)*16
	lda.w #$0020
	sec
	sbc.w spodds,x
	asl a
	asl a
	asl a
	asl a
	sta.b d4
	lda.w #blueline+goalline		; blueline+goalline
	sta.b d1
	lda.w pfgoal,x					; pfgoal selects which goal is attacked
	bne .c0
	lda.w #-(blueline+goalline)
	sta.b d1
.c0:								; d1 = y distance to the goal line, d0 = x distance
	lda.b d1						; d1 = goal distance in Y
	sec
	sbc.w pucky
	sta.b d1
	pha
	lda.w puckx						; puck X negated for the distance
	eor.w #$FFFF					; negate
	inc a
	sta.b mula
	sta.b mulb
	pha
	jsl.l muls32					; signed 32-bit multiply
	sta.b d0
	lda.b mulres+2
	sta.b d0+2
	lda.b d1
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	adc.b d0
	sta.b tmp0
	lda.b mulres+2
	adc.b d0+2
	sta.b tmp1
	pla								; restore X
	sta.b d0
	pla								; restore Y
	sta.b d1
	lda.b tmp0
	cmp.w #$2711					; distance^2 > 100*100?
	lda.b tmp1
	sbc.w #$0000
	bcs .no1
	lsr.b d4
	lsr.b d4
	lsr.b d4
	lsr.b d4
	jsl.l vtoa						; vector to direction
	sta.b d5						; d5 = direction to the goal
	lda.w #$0005					; 6 opponents
	sta.b d3
	stz.b a1						; a1 = first opponent slot
	cpx.w #$000C					; pick the opposing team's slots
	bcs .co0
	lda.w #$000C
	sta.b a1
.co0:								;each opponent: a defender in the shot line doubles d4; a busy goalie
									;means shoot now
	ldy.b a1
	lda.w position,y				; empty slot: the goalie
	beq .gl
	lda.w Xpos,y
	sec
	sbc.w puckx
	sta.b d0
	lda.w Ypos,y
	sec
	sbc.w pucky
	sta.b d1
	jsl.l vtoa						; vector to direction
	cmp.b d5
	bne .co1
	asl.b d4
	bra .co1
.gl:								; goalie busy, shoot now
	lda.w pf2aip,y					; goalie flagged (pf2aip): shoot now
	beq .co1
	stz.b d3						; stop checking
	lda.w #$0001
	sta.b d4
.co1:								; next opponent
	inc.b a1						; next opponent
	inc.b a1
	dec.b d3
	bpl .co0						; loop
.no1:								; odds check passed: roll the dice
	lda.b d4
	jsl.l randoma					; random number 0 to A-1
	cmp.w #$0009					; no shot if random(d4) > 8
	bcs .rts						; too unlikely: no shot
	lda.w pucky
	sta.b d0						; d0 = puck Y relative to our goal
	lda.w pfgoal,x
	bne .ds0
	lda.b d0
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
.ds0:								; shot distance from the goal line
	lda.b d0
	bmi .rts						; behind the goal line: no shot
	lda.w #blueline+goalline
	sec
	sbc.b d0
	bmi .rts						; beyond the blue line: no shot
	lda.w sflags					; sf2offsig: player is offside
	bit.w #sf2offsig
	bne .rts
	bra CompShoot					; take the shot
.rts:								; return
	rtl
