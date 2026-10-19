SaveRegsStartHL2:					;Save the registers and go on to StartHL2
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d0 through a7 (16 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0020
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; keep X again
	ldx.w #$0000
.savea:								; save a0 and the 13 words after it (14 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$001C
	bne .savea
	ldx.b xsave						; restore X
	jml.l StartHL2					; pulls the saved registers
