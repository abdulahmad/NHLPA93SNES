FormatPlayerNumInitial:				;mesarea = the number, first initial and last name of roster player d0 of
									;team a2
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d0 and the words after it (8 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0010
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0000
.savea2:							; save a2 and the words after it (2 words)
	lda.b a2,x
	pha
	inx
	inx
	cpx.w #$0004
	bne .savea2
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0000
.savea:								; save a0 and the words after it (2 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0004
	bne .savea
	ldx.b xsave						; restore X
	jsl.l GetRosterEntry89
	stx.b xsave						; keep X
	ldx.w #$0000
.pushrec:							; save a0 and the words after it (2 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0004
	bne .pushrec
	ldx.b xsave						; restore X
	lda.w #$0000
	sta.b a1+2
	lda.w #mesarea+2				; a1 = mesarea+2
	sta.b a1
	lda.b a0
	clc
	adc.b [a0]
	sta.b a0
	lda.b [a0]
	and.w #$00FF
	sta.b d0
	jsl.l ConvertByteToDigits		; number
	lda.w #' '
	sta.b [a1]
	inc.b a1
	stx.b xsave						; keep X
	ldx.w #$0002
.poprec:							; pull a0 and the words after it back
	pla
	sta.b a0,x
	dex
	dex
	bpl .poprec
	ldx.b xsave						; restore X
	lda.b [a0]						; name length
	sta.b d0
	clc
	adc.b a0
	sta.b a2
	lda.b a0+2
	sta.b a2+2
	inc.b a0
	inc.b a0
	lda.b [a0]						; first initial
	inc.b a0
	sta.b [a1]
	inc.b a1
	lda.w #'.'
	sta.b [a1]
	inc.b a1
	lda.w #' '
	sta.b [a1]
	inc.b a1
.skipfirst:
	lda.b [a0]						; skip to the last name
	inc.b a0
	and.w #$00FF
	cmp.w #' '
	bne .skipfirst
.last:								; last character
	lda.b [a0]
	inc.b a0
	sta.b [a1]
	inc.b a1
	lda.b a0
	cmp.b a2
	bne .last
	jsl.l FinalizeTextBuffer
	stx.b xsave						; keep X
	ldx.w #$0002
.resta:								; pull a0 and the words after it back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0002
.resta2:							; pull a2 and the words after it back
	pla
	sta.b a2,x
	dex
	dex
	bpl .resta2
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$000E
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
