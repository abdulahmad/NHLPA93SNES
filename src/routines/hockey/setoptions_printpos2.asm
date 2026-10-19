setoptions_printpos2:				;Where the name of a player shown on the scouting report is printed
	jsl.l printz					; set font and position (1,10)
	%StringCp(CC_Font1Pri,$01,$0A)
	lda.b a2						; team 0 keeps it
	bne .rtl
	lda.w #20						; else x = 20
	sta.w printx
.rtl:
	rtl
