assdopen:							;Assignment: put player X in the penalty box
	lda.w pfalock,x					; already locked
	bne .rtl						; yes: leave
	lda.w #$0010					; team 0: add $10
	sta.b d0
	lda.w pfteam,x					; team 1
	beq .1							; team 0
	lda.w #$0001					; team 1: add 1
	sta.b d0
.1:
	lda.w PBnum						; penalty box count
	clc
	adc.b d0
	sta.w PBnum						; one more in the box
	lda.w #$FFFF					; off the ice
	sta.w position,x
	stz.w frame,x					; frame 0
.rtl:								; return
	rtl
