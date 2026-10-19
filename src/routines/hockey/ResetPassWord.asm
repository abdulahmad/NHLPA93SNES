ResetPassWord:						;Blank the password
	sep #$30						; 8-bit registers
	stz.w PassWord					; first character 0
	ldy.b #$0F						; 15 characters
	lda.b #$1E						; blank character
.blank:
	sta.w PassWord,y
	dey
	bne .blank						; until all are blank
	rep #$30						; 16-bit registers
	rtl
