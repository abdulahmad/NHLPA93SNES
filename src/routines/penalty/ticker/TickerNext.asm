TickerNext:							;Go to the next ticker game
	lda.w TickerNum
	bmi .last						; none yet
	ora.w gamenum					; and not the current game
	bne .new
.last:
	jsl.l GetShifter				; find the next game
	lda.b d1
	sta.w TickerNum					; the ticker game
	bmi IntermissionTick_rtl		; none left: leave
.new:
	jmp.w NewTicker2				; show it
