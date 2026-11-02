setplayercolors_palbuffer:			;Convert both teams' colors into the palette buffer (the body of
									;93G setplayercolors; setplayercolors adds the CGRAM upload)
	phx								; keep X and Y
	phy
	ldx.w #$0000					; first team
	lda.w tmdata					; home team colors: palbuffer+$40
	sta.b tmp0						; source pointer
	lda.w #TeamList>>16				; team list bank
	sta.b tmp1
	stz.b tmp2+1					; palette offset 0
	jsl.l setplayercolors_sp		; convert the colors
	lda.w tmdata+2					; away team colors: palbuffer+$60
	sta.b tmp0						; away team
	lda.w #$0020
	sta.b tmp2+1					; palette offset $20
	jsl.l setplayercolors_sp
	ply								; restore Y and X
	plx
	rtl
