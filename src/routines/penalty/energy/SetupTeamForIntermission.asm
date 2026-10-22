SetupTeamForIntermission:			;Before a period: reset the bench, refill every player's energy and pick
									;each team's starting line
									;(power play or penalty kill line when a team is a man up or short)
	jsl.l ResetBench				; bench reset
	stz.b a2						; team 0
	lda.w #$0002					; other team 1
	sta.b a3
	jsl.l .team
	stz.b a3						; swap them
	lda.w #$0002					; other team
	sta.b a2
.team:								;team a2 (a3 = the other)
	jsl.l reenergizeteam			; full energy
	ldx.b a3						; other team
	ldy.b a2						; this team
	stz.w tmline,x					; line 0
	lda.w OptLine					; line changes
	bne .rtl						; off: line 0
	lda.w tmap,x					; difference in players on the ice
	sec
	sbc.w tmap,y
	sta.b d0						; equal
	beq .rtl						; equal: line 0
	lda.w #$0003					; power play line
	sta.w tmline,x
	lda.b d0						; sign
	bpl .rtl						; ahead
	lda.w #$0005					; penalty kill line
	sta.w tmline,x
.rtl:								; return
	rtl
