BitstoPW:							;Turn the password bits into the password characters
	ldx.w #$000F					; 16 characters
.char:								; PassWord[x] = passbits mod PWrange
	lda.w #PWrange					; PassWord[x] = passbits mod PWrange
	sta.b d0
	jsl.l SuperDiv					; divide the bits by it
	sep #$20						; 8-bit A
	lda.b d0						; remainder
	sta.w PassWord,x				; store the character
	rep #$30						; 16-bit registers
	dex								; next character
	bpl .char
	rtl
