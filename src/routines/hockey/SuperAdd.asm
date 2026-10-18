SuperAdd:							;password bits += d0
	phx
	lda.w pwddatabuffer
	clc
	adc.b d0
	sta.w pwddatabuffer
	bcc .ex
	ldx.w #$0002
.carry:
	inc.w pwddatabuffer,x
	bne .ex
	inx
	inx
	cpx.w #16
	bne .carry
.ex:
	plx
	clc
	rtl
