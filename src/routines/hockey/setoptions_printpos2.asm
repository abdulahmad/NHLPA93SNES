setoptions_printpos2:				;Where the name of a player shown on the scouting report is printed
	jsl.l printz
	%StringCp(CC_Font1Pri,$01,$0A)
	lda.b a2
	bne .rtl
	lda.w #20
	sta.w printx
.rtl:
	rtl
