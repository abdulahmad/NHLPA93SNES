GetPlayerNumInitial:				;a1 = the number, first initial and last name of player TempPlOffset
	lda.b d0+2						; save d0
	pha
	lda.b d0
	pha
	lda.b a2+2						; save a2
	pha
	lda.b a2
	pha
	stz.b a2						; team 0
	lda.w TempPlOffset				; player id with the team flag
	sta.b d0
	bpl .home						; home team
	and.w #$00FF					; player number
	sta.b d0
	lda.w #$0002					; away team
	sta.b a2
.home:								; format the number and initial
	jsl.l FormatPlayerNumInitial	; format the text
	pla								; restore a2
	sta.b a2
	pla
	sta.b a2+2
	pla								; restore d0
	sta.b d0
	pla
	sta.b d0+2
	rtl
