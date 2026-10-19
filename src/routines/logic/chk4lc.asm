chk4lc:								;Should the computer call a line change? Then shoot the puck in
	lda.w pucky						; puck y
	sta.b d0
	lda.w pfgoal,x					; goal end
	bne .gu							; top end
	lda.b d0
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
.gu:								; puck on the far side: no line change
	lda.b d0
	bmi .rts						; puck is on the far side
	sec
	sbc.w #blueline					; blueline
	beq .inzone						; at the blue line
	bmi .neg						; short of it
	bvs .inzone						; overflow
	bra .rts						; beyond: no call
.neg:
	bvs .rts						; overflow: inside
.inzone:							;in own half, inside the blue line
	lda.w seed						; random
	and.w #$0003					; one time in four
	bne .rts						; nonzero: no call
	lda.w pflags,x					; flags
	bit.w #pf2lcm					; pf2lcm
	bne .rts						; already in line change mode
	stz.b a2						; a2 = 0
	lda.w #$0002
	sta.b a1						; a1 = 2
	lda.w pfteam,x					; team
	beq .0
	stz.b a1
	lda.w #$0002
	sta.b a2
.0:									;a2 = own team, a1 = other team
	jsl.l AvgCline					; average energy of the line
	lda.b d0						; d0
	cmp.w #$0C01					; average energy of the line still above $C00: no change
	bcs .rts
	jsl.l CompLine					; choose a line
	jsl.l setpersonel				; personnel
	jsl.l printscores1				; redraw
	jmp.w CompShoot					; then shoot
.rts:								; return
	rtl
