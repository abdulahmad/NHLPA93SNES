addteamstat:						;Add d0 to a team stat for player X's team
	ldy.b d1						; pfteam: team 2 word
	lda.w pfteam,x
	beq .add						; team 0: stat as is
	iny								; team 1: the next word
	iny
.add:
	lda.w $0000,y					; absolute stat address in d1 (+$0000,y)
	clc								; stat + d0
	adc.b d0
	sta.w $0000,y					; store it
	rtl
