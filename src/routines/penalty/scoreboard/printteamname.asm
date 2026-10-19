printteamname:						;Print team d3's name, then move down two rows
	lda.w printx					; keep print x
	pha
	lda.w tmdata					; tmdata of team d3
	sta.b a1
	lda.w #TeamList>>16
	sta.b a1+2
	lda.b d3						; team 0?
	beq .name						; yes
	lda.w tmdata+2					; else the away team
	sta.b a1
.name:								; team name offset
	ldy.w #Teamname					; team name offset
	lda.b [a1],y
	clc								; name pointer
	adc.b a1
	sta.b a1
	lda.b [a1]						; name string
	adc.b a1
	sta.b a1
	jsl.l print						; print it
	pla
	sta.w printx					; restore x
	inc.w printy					; down two rows
	inc.w printy
	rtl
