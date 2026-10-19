ChkOffsides:						;Clear each team's offsides flag once it is back onside; when the puck
									;crosses a blue line into the zone
		;   with an attacker already past it, flag that team offsides
	lda.w gmode						; game mode
	bit.w #gmoffs
	beq .rtl						; gmoffs clear: return
	stz.b a1						; a1 = home, a2 = away; then swapped
	lda.w #$0002
	sta.b a2
	jsl.l ClearOffsidesIfAllPlayers	; clear the flag for the home side when all its players are back
	stz.b a2
	lda.w #$0002
	sta.b a1
	jsl.l ClearOffsidesIfAllPlayers	; and for the away side
	lda.w #blueline-4				; blueline-4
	sta.b d0
	sec
	sbc.w pucky						; puck y against the line
	beq .top
	bmi .neg1
	bvs .top
	bra .neg
.neg1:
	bvs .neg
.top:								;puck crossed the top line this frame?
	lda.w #blueline-4
	sec
	sbc.w OldYpos+puckobj			; puck y last frame against the line
	beq .rtl
	bmi .neg2
	bvc .t
	bra .rtl
.neg2:
	bvc .rtl
.t:
	lda.w #blueline-4+$A			; +$A
	sta.b d0
	lda.w gmode
	bit.w #gmdir					; gmdir
	beq .t0
	lda.b a2
	ldy.b a1
	sta.b a1
	sty.b a2
.t0:
	lda.w #$0005					; check 6 players
	sta.b d2
	ldy.b a2
	lda.w tmsort,y					; first player of the attacking team
	sta.b a0
.0:
	ldy.b a0
	lda.w position,y				; skip empty positions
	bmi .1
	lda.b d0
	sec
	sbc.w Ypos,y					; player y against the line
	bmi .neg3
	bvs .set0
	bra .1
.neg3:
	bvs .1
.set0:
	ldy.b a2
	lda.w tmflags,y					; flag the team offsides
	ora.w #tmfoside					; tmfoside
	sta.w tmflags,y
.rtl:
	rtl
.1:
	inc.b a0						; next player
	inc.b a0
	dec.b d2
	bpl .0
	rtl
.neg:								;bottom line
	lda.b d0						; line for the bottom end
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	sec
	sbc.w pucky
	bmi .neg4
	bvc .b1
	bra .rtl
.neg4:
	bvc .rtl
.b1:
	lda.b d0
	sec
	sbc.w OldYpos+puckobj
	bmi .neg5
	bvs .b2
	bra .rtl
.neg5:
	bvs .rtl
.b2:
	lda.b d0
	sec
	sbc.w #$000A					; -$A
	sta.b d0
	lda.w gmode
	bit.w #gmdir
	bne .t1
	lda.b a2
	ldy.b a1
	sta.b a1
	sty.b a2
.t1:
	lda.w #$0005
	sta.b d2
	ldy.b a2
	lda.w tmsort,y
	sta.b a0
.2:
	ldy.b a0
	lda.w position,y
	bmi .3
	lda.b d0
	sec
	sbc.w Ypos,y
	beq .3
	bmi .neg6
	bvc .set2
	bra .3
.neg6:
	bvc .3
.set2:
	ldy.b a2
	lda.w tmflags,y
	ora.w #tmfoside
	sta.w tmflags,y
	rtl
.3:
	inc.b a0
	inc.b a0
	dec.b d2
	bpl .2
	rtl
