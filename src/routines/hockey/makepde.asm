makepde:							;d0 = rating A scaled by player a0's energy
	pha
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								;movem d1/a2-a3
	lda.b d1,x
	pha
	inx
	inx
	cpx.w #$0004
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0000
.savea:								; save a2 and the words after it (4 words)
	lda.b a2,x
	pha
	inx
	inx
	cpx.w #$0008
	bne .savea
	ldx.b xsave						; restore X
	ldx.b a0						; a3 = a0 for getpde
	stx.b a3
	jsl.l getpde
	stx.b xsave						; keep X
	ldx.w #$0006
.resta:								; pull a2 and the words after it back
	pla
	sta.b a2,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0002
.restore:							; pull d1 and the words after it back
	pla
	sta.b d1,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	ldx.b a3
	pla
	sta.b mula
	lda.b d0
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	asl a							; *16, high word: *energy/$1000
	rol.b mulres+2
	asl a
	rol.b mulres+2
	asl a
	rol.b mulres+2
	asl a
	rol.b mulres+2
	lda.b mulres+2
	sta.b d0
	clc
	rtl
