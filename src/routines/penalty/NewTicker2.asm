NewTicker2:							;d3 = the next game for the ticker, or negative when none is left
	lda.w OptPlayMode				; regular season: no ticker
	beq .rtl
	lda.w TickerNum					; next ticker game
	sta.b d3
	bmi .rtl						; none left
	dec.w TickerNum					; following one next time
	lda.b d3
	cmp.w gamenum					; the current game itself
	beq NewTicker2					; skip it
	bra NewTicker3					; show it
.rtl:
	rtl
