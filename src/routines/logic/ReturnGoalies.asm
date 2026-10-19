ReturnGoalies:						;If the computer pulled its goalie, should he come back?
	stz.b a2						; team a2 = 0
	lda.w #$0001					; team 1
	sta.b d0
	inc a							; other team
	sta.b a1						; a1 = 2
	jsl.l ReturnGoalies_r			; check team 1
	lda.w #$0002					; team 2
	sta.b d0
	lda.b a1						; swap a2 and a1
	ldy.b a2
	sta.b a2
	sty.b a1
ReturnGoalies_r:					;d0 = team (1/2), a2/a1 = team/other
	lda.b d0
	cmp.w cont1team					; controlled team: no
	beq .rtl
	cmp.w cont2team					; controlled team: no
	beq .rtl
	ldy.b a2						; team offset
	lda.w tmgoalie,y				; goalie state
	bpl .rtl						; goalie in
	and.w #$00FF					; number of the goalie to return
	cmp.w #$000A					; low byte = goalie to return
	bcs .rtl
	sta.w tmgoalie,y				; goalie back in
	lda.w foy						; d1 = foy
	sta.b d1
	jmp.w CPgoalie					; put the goalie back
.rtl:
	rtl
