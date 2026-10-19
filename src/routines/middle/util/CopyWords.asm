CopyWords:							;Copy d0 bytes from [d2] to [d1], a word at a time
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d0 through d5
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$000C
	bne .save
	ldx.b xsave						; restore X
.copy:								; copy a word from [d2] to [d1]
	lda.b [d2]						; word from [d2]
	sta.b [d1]						; to [d1]
	inc.b d1						; next word
	inc.b d1
	inc.b d2
	inc.b d2
	dec.b d0						; two bytes
	dec.b d0
	bne .copy						; until done
	stx.b xsave						; X again
	ldx.w #$000A
.restore:							; pull them back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
