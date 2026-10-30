GetPeriodTime:						;d0 = the period length in seconds for the period length option
	phx								; keep X
	lda.w Optperlen
	asl a							; option times 2: word table
	tax
	lda.l GetPeriodTime_timetab,x	; length in seconds
	sta.b d0
	plx								; restore X
	rtl
