ShowGoalBox:						;The goal box: "GOAL!" or "HAT TRICK!" with the scorer and the assists
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
.savea:								; save a0 and the words after it (10 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0014
	bne .savea
	ldx.b xsave						; restore X
	stz.b a2
	jsl.l lcfound2
	inc.b a2
	inc.b a2
	jsl.l lcfound2
	lda.w #$0000
	sta.b a4+2
	lda.w #ScoreSum-6
	clc
	adc.w ScoreSumbytes
	sta.b a4
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1Pri,$0B,$02)
	lda.w #$0013
	sta.b d0
	lda.w #$0005
	sta.b d1
	ldy.w #$0004
	lda.b [a4],y
	bit.w #$0080
	bne .frame
	inc.b d1
	inc.b d1
	lda.b [a4],y
	bmi .frame
	inc.b d1
.frame:
	jsl.l Framer					; draw the frame d0 x d1
	stz.b a2
	ldy.w #$0002
	lda.b [a4],y
	bit.w #$0080
	beq .home
	inc.b a2
	inc.b a2
.home:
	lda.w #GoalBoxText
	sta.b a1
	lda.w #GoalBoxText>>16
	sta.b a1+2
	ldy.w #$0003
	lda.b [a4],y
	and.w #$00FF
	ldy.b a2
	beq .tmofs
	clc
	adc.w #$001A
.tmofs:
	tay
	lda.w tmgoals,y					; goals of the scorer
	and.w #$00FF
	cmp.w #$0003
	bne .goal
	lda.b a1
	clc
	adc.b [a1]
	sta.b a1
.goal:
	jsl.l printbig
	ldy.w #$0003
	lda.b [a4],y
	and.w #$00FF
	sta.b d0
	jsl.l FormatPlayerNumInitial
	jsl.l print						; print it
	ldy.w #$0004
	lda.b [a4],y
	and.w #$00FF
	sta.b d0
	bit.w #$0080
	bne .ex
	jsl.l printz					; print the string that follows
	%StringCtc(CC_Font1Pri,$0E,$06,"Assist by:",CC_Font1Pri,$0C,$07)
	jsl.l FormatPlayerNumInitial
	jsl.l print						; print it
	ldy.w #$0005
	lda.b [a4],y
	and.w #$00FF
	sta.b d0
	bit.w #$0080
	bne .ex
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1Pri,$0C,$08)
	jsl.l FormatPlayerNumInitial
	jsl.l print						; print it
.ex:
	stx.b xsave						; keep X
	ldx.w #$0012
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
	ldx.b a3
	rtl
