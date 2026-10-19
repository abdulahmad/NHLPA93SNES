loadTeamStruct:						;a2 = player X's team, a1 = the other team
	stz.b a2						; a2 = team 0 offset
	lda.w #$0002
	sta.b a1						; a1 = team 1 offset
	lda.w pfteam,x					; player team
	beq .rtl						; team 0: done
	stz.b a1						; swap them
	lda.w #$0002
	sta.b a2
.rtl:
	rtl
