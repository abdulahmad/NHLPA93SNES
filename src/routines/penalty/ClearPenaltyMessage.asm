ClearPenaltyMessage:				;Blank the penalty message line on the horizontal rink
	jsl.l printz
	%StringCt(CC_Font1Pri,$05,$0B,"                      ")	;printz inline string: length (counts itself), then control bytes / text
	rtl
