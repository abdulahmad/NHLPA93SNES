ClampYPosition:						;d1 = y kept inside the goal lines, measured from goal line d3. d0 = 0 if
									;X has the puck
	lda.w puckc						; puck carrier
	sta.b d2
	cmp.w SCnum,x					; X has the puck
	bne .0
	stz.b d0						; else d0 = 0
.0:									; clamp d1 to the range -$103..$103
	lda.b d1						; y
	sec
	sbc.w #$0103					; minus $103
	bmi .neg
	bvc .hi
	bra .one
.neg:								; signed compare: overflow flag corrects the sign
	bvc .one
.hi:								; clamp to $103
	lda.w #$0103
	sta.b d1
.one:								; clamp to the lower limit
	lda.b d1
	sec
	sbc.w #$FEFD					; minus -$103
	beq .lo
	bmi .neg1
	bvs .lo
	bra .two
.neg1:								; signed compare: overflow flag corrects the sign
	bvs .two
.lo:								; clamp to -$103
	lda.w #$FEFD					; clamp to -$103
	sta.b d1
.two:								; minus d3
	lda.b d1						; y
	sec
	sbc.b d3						; minus d3
	sta.b d1						; d1 = result
	rtl
