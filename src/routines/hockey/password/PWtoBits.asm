PWtoBits:							;Turn the password characters into the password bits
	jsl.l ClrPassBits				; passbits = 0
	ldx.w #$0000					; first character
.char:								; passbits = passbits * PWrange + the character
	lda.w #PWrange					; passbits = passbits * PWrange + PassWord[x]
	sta.b d0
	jsl.l SuperMult					; passbits *= d0
	lda.w PassWord,x				; character
	and.w #$00FF
	sta.b d0
	stz.b d0+2
	jsl.l SuperAdd					; passbits += d0
	inx								; next character
	cpx.w #pwlength					; all of the password
	bne .char
	rtl
