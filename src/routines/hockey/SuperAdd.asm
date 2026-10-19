SuperAdd:							;password bits += d0
	phx								; keep X
	lda.w passbits					; low word
	clc
	adc.b d0						; add d0
	sta.w passbits
	bcc .ex							; no carry: done
	ldx.w #$0002					; carry into the next words
.carry:
	inc.w passbits,x				; increment
	bne .ex							; no carry out: done
	inx
	inx
	cpx.w #16						; 8 words in all
	bne .carry
.ex:
	plx								; restore X
	clc
	rtl
