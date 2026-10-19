BitstoPW:							;Turn the password bits into the password characters
	ldx.w #$000F					; 16 characters
.char:
	lda.w #PWrange					; PassWord[x] = passbits mod PWrange
	sta.b d0
	jsl.l SuperDiv					; divide the bits by it
	sep #$20
	lda.b d0						; remainder
	sta.w PassWord,x				; store the character
	rep #$30
	dex								; next character
	bpl .char
	rtl
