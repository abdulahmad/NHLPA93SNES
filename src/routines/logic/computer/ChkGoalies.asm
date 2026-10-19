ChkGoalies:							;A computer team with the puck pulls its goalie on a delayed penalty, or
									;late in a game it trails by two
	lda.w gmclock					; clock stopped
	bne ChkGoalies_CPG_rtl			; stopped: leave
	stz.b a2						; team 0
	lda.w #$0001					; team 1
	sta.b d0
	inc a							; other team
	sta.b a1
	jsl.l ChkGoalies_CPG			; check team 1
	lda.w #$0002					; team 2
	sta.b d0
	lda.b a1						; swap a2 and a1
	ldy.b a2
	sta.b a2
	sty.b a1
ChkGoalies_CPG:						;d0 = team (1/2), a2/a1 = team/other
	lda.b d0						; team
	cmp.w cont1team					; controlled team: no
	beq .rtl						; human team
	cmp.w cont2team
	beq .rtl
	ldy.b a2						; team offset
	lda.w tmgoalie,y				; goalie already out
	bmi .rtl						; already out
	lda.w puckc						; puck carrier
	bmi .rtl						; none
	sec								; distance from the carrier
	sbc.w #$0006					; puckc - 6, negated for the away team: negative = team a2 has the puck
	ldy.b a2						; team
	beq .side						; home: as is
	eor.w #$FFFF					; negate for away
	inc a
.side:
	sta.b d0						; d0 = side
	cmp.w #$0000					; compare
	bpl .rtl						; puck is on its own side
	lda.w pucky						; puck y
	sta.b d1						; d1 = y
	lda.w gmode						; game mode
	bit.w #gmpendel					; gmpendel
	bne .pull						; delayed penalty
	jmp.w CPgoalie					; else the usual rule
.pull:								;delayed penalty: pull the goalie, any team
	lda.w tmgoalie,y				; goalie
	ora.w #$FF00					; tmgoalie high byte $FF: pulled
	sta.w tmgoalie,y				; pulled
	jmp.w setpersonel
.rtl:								; return
	rtl
