SetPA2:								;Step the referee animation to its next frame and delay
	phx
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d0 and the words after it (6 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$000C
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0000
.savea:								; save a0 and the words after it (4 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0008
	bne .savea
	ldx.b xsave						; restore X
	lda.w #$0040					; d0 = $40 (clear the ref window) when RefStep is negative
	sta.b d0
	lda.w RefStep
	bmi .pr
	sta.b d0
	inc.w RefStep
	inc.w RefStep
	lda.w RefPen					;Penaltylist entry of RefPen: its animation offset (+2), then the
									;frame/delay word at RefStep
	sta.b d1
	tax
	lda.l Penaltylist,x
	inc a
	inc a
	tax
	clc
	adc.l Penaltylist,x
	adc.b d0
	tax
	lda.l Penaltylist,x
	sta.b d0
	bpl .0
	eor.w #$FFFF					; negative: last pair, RefStep = -1
	inc a
	sta.b d0
	lda.w #$FFFF
	sta.w RefStep
.0:									; low byte = delay
	lda.b d0						; RefCnt = delay * 8, d0 = frame
	and.w #$00FF
	asl a
	asl a
	asl a
	sta.b d1
	sta.w RefCnt
	lda.b d0
	xba
	and.w #$00FF
	sta.b d0
.pr:								; push a referee, keep X
	jsl.l PushRef
	stx.b xsave						; keep X
	ldx.w #$0006
.resta:								; pull a0 and the words after it back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$000A
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	plx
	rtl
