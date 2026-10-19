PenGoalStuff:						;After a goal on a power play, let the first player out of the box whose
									;penalty is not coincidental.
		;   a1 = team scored on, a2 = scoring team
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
.savea:								; save a0 and the words after it (2 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0004
	bne .savea
	ldx.b xsave						; restore X
	jsl.l ClearPenaltyBuffer
	ldy.b a2
	lda.w tmap,y					; tmap(a2) - tmap(a1) > 0?
	ldy.b a1
	sec
	sbc.w tmap,y
	beq .ex
	bmi .neg
	bvc .more
	bra .ex
.neg:
	bvc .ex
.more:								;scoring team had more players on the ice
	lda.b a1
	beq .lst
	lda.w #$001A
.lst:
	sta.b a0
.loop:								;next player in the box list (negative = end)
	ldy.b a0
	lda.w tmboxlist,y
	inc.b a0
	and.w #$00FF
	sta.b d2
	bit.w #$0080
	bne .ex
	lda.b a1
	beq .tm
	lda.w #$0034
.tm:
	clc
	adc.b d2
	tay
	lda.w tmpdst,y					; coincidental penalty: skip
	bit.w #$4000
	bne .loop
	lda.w #$0000					; out of the box, one more on the ice, power play goal
	sta.w tmpdst,y
	jsl.l RemovePlayerFromList
	ldy.b a1
	lda.w tmap,y
	inc a
	sta.w tmap,y
	ldy.b a2
	lda.w tmPwrGoals,y
	inc a
	sta.w tmPwrGoals,y
	lda.w #tmflcc
	tsb.w tmflags					; line change box redraw
	tsb.w tmflags+2
.ex:
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
	ldx.w #$000A
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
