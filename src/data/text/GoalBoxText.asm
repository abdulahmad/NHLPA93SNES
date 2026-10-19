GoalBoxText:						;printbig strings of ShowGoalBox: GOAL!, then HAT TRICK!
	%StringCtc(CC_Font1Pri,$0F,$03,"GOAL!",CC_Font1Pri,$0C,$05)
	%StringCtc(CC_Font1Pri,$0C,$03,"HAT TRICK!",CC_Font1Pri,$0C,$05)
unusedFF8F:							;the end of the ROM: zero fill
	db 0,0,0,0,0
