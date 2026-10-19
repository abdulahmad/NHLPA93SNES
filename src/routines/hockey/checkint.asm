checkint:							;A goalie and another player collide: the skater falls, and a hard hit may
									;draw an interference penalty
	lda.b d0+2						; a2 and a3 swapped for the second call
	pha								; keep d0
	lda.b d0
	pha
	jsl.l .ci						; a2 goalie vs X
	ldx.b a2						; swap a2 and a3
	ldy.b a3
	stx.b a3
	sty.b a2
	jsl.l .ci						; and the other way round
	ldx.b a2
	ldy.b a3
	stx.b a3
	sty.b a2
	pla								; restore d0
	sta.b d0
	pla
	sta.b d0+2
.rtl:								; return
	rtl
.ci:								;a2 must be a goalie, clock running
	ldy.b a2						; a2
	lda.w position,y				; goalie?
	bne .rtl
	lda.w gmclock					; clock running?
	bne .rtl
	lda.w puckc						; a3 has the puck: skip the impact 26 test
	asl a
	cmp.b a3
	beq .pc
	lda.w impact,x					; impact of X
	sec
	sbc.w #$001A					; minus 26
	beq .rtl
	bmi .neg
	bvc .pc
	bra .rtl
.neg:								; signed compare: overflow flag corrects the sign
	bvc .rtl
.pc:								;impact of X > 2
	lda.w impact,x					; impact of X
	sec
	sbc.w #$0003					; minus 3
	beq .rtl
	bmi .neg1
	bvc .fall
	bra .rtl
.neg1:								; signed compare: overflow flag corrects the sign
	bvc .rtl
.fall:								;X falls
	ldx.b a2						; X falls
	ldy.b a3
	stx.b a3
	sty.b a2
	jsl.l FallDown					; make X fall
	ldx.b a2
	ldy.b a3
	stx.b a3
	sty.b a2
	lda.w impact,y					; impact of a2 > 31
	sec
	sbc.w #$001F					; minus 31
	beq .rtl
	bmi .neg2
	bvc .pen
	bra .rtl
.neg2:								; signed compare: overflow flag corrects the sign
	bvc .rtl
.pen:								;no double minor; penalty 3 times in (20 - GGSleft)
	lda.w pflags,x					; player flags
	bit.w #pf2pen					; already penalised?
	bne .rtl
	lda.w #$0014
	sec
	sbc.w GGSleft,x					; 20 minus the games left
	jsl.l randoma					; random number 0 to A-1
	cmp.w #$0003					; 3 in 20
	bcs .rtl
	lda.w gmode						; not in highlights
	bit.w #gmhl						; not in highlights
	bne .rtl
	lda.w #PenInterference			; interference penalty
	sta.b d0
	jmp.w AddPenalty				; call it
