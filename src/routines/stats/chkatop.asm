chkatop:							;Once a second, add to the attack zone time of the team with the puck past
									;the blue line
	stz.b d1						; team 0
	lda.w pucky						; puck y
	sec
	sbc.w #$0058					; minus $58
	beq .lo							; at the line
	bmi .neg						; signed compare
	bvs .lo
	bra .1
.neg:								; signed compare: overflow flag corrects the sign
	bvs .1
.lo:
	inc.b d1						; team 1
	inc.b d1
	lda.w pucky						; puck y
	sec
	sbc.w #$FFA8					; minus -$58
	bmi .neg1
	bvs .1
	bra .rtl
.neg1:								; signed compare: overflow flag corrects the sign
	bvs .rtl
.1:									; in the zone
	lda.w gmode						; gmdir: swap the teams
	bit.w #gmdir					; direction swapped?
	beq .0							; yes
	lda.b d1
	eor.w #$0002					; swap the teams
	sta.b d1
.0:
	ldy.b d1						; team
	lda.w tmATOP,y					; attack zone time
	inc a							; one more
	sta.w tmATOP,y
.rtl:								; return
	rtl
