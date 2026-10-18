setplayercolors_palbuffer:			;Convert both teams' colors into the palette buffer (the body of
									;93G setplayercolors; setplayercolors adds the CGRAM upload)
	phx
	phy
	ldx.w #$0000
	lda.w tmdata					; home team colors: palbuffer+$40
	sta.b tmp0
	lda.w #TeamList>>16
	sta.b tmp1
	stz.b tmp2+1
	jsl.l setplayercolors_sp
	lda.w tmdata+2					; away team colors: palbuffer+$60
	sta.b tmp0
	lda.w #$0020
	sta.b tmp2+1
	jsl.l setplayercolors_sp
	ply
	plx
	rtl
