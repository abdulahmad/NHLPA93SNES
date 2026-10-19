ClearPenaltyMessage:				;Blank the penalty message line on the horizontal rink
	jsl.l printz					; print the string that follows
	%StringCt(CC_Font1Pri,$05,$0B,"                      ")
	rtl
