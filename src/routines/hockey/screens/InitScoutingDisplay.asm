InitScoutingDisplay:				;Reset the scouting report text scroll
	lda.w #$FFFF					; no line scrolling
	sta.w VertLineScrolling
	sta.w PlayerScrollCtr			; no player scrolling
	stz.w SelectedPlayerIdx			; first player
	stz.w ScoutingReportTimer		; timer 0
	lda.w #TestList&$FFFF			; a0 = TestList
	sta.b a0
	lda.w #TestList>>16
	sta.b a0+2
	rtl
