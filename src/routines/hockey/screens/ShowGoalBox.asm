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
	stz.b a2						; find the line change data for both teams
	jsl.l lcfound2
	inc.b a2
	inc.b a2
	jsl.l lcfound2
	lda.w #$0000					; a4 = latest entry of the score summary
	sta.b a4+2
	lda.w #ScoreSum-6
	clc
	adc.w ScoreSumbytes
	sta.b a4
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1Pri,$0B,$02)
	lda.w #$0013					; box width 19
	sta.b d0
	lda.w #$0005					; box height 5
	sta.b d1
	ldy.w #ssassist1				; assist byte
	lda.b [a4],y
	bit.w #$0080					; no assist: box one row smaller
	bne .frame
	inc.b d1
	inc.b d1
	lda.b [a4],y
	bmi .frame
	inc.b d1
.frame:								; draw the box frame
	jsl.l Framer					; draw the frame d0 x d1
	stz.b a2
	ldy.w #ssflags
	lda.b [a4],y					; home or visitor flag in the entry
	bit.w #$0080
	beq .home
	inc.b a2
	inc.b a2
.home:								; print the home team box
	lda.w #GoalBoxText				; goal box text
	sta.b a1
	lda.w #GoalBoxText>>16
	sta.b a1+2
	ldy.w #ssscorer					; scorer number
	lda.b [a4],y
	and.w #$00FF
	ldy.b a2
	beq .tmofs
	clc
	adc.w #$001A
.tmofs:								; goals of the scorer
	tay
	lda.w tmgoals,y					; goals of the scorer
	and.w #$00FF
	cmp.w #$0003					; third goal: hat trick text
	bne .goal
	lda.b a1
	clc
	adc.b [a1]
	sta.b a1
.goal:								; print the goal box
	jsl.l printbig
	ldy.w #ssscorer
	lda.b [a4],y
	and.w #$00FF
	sta.b d0
	jsl.l FormatPlayerNumInitial	; format number and initial
	jsl.l print						; print it
	ldy.w #$0004					; first assist byte
	lda.b [a4],y
	and.w #$00FF
	sta.b d0
	bit.w #$0080					; none: done
	bne .ex
	jsl.l printz					; print the string that follows
	%StringCtc(CC_Font1Pri,$0E,$06,"Assist by:",CC_Font1Pri,$0C,$07)	; print "Assist by:"
	jsl.l FormatPlayerNumInitial
	jsl.l print						; print it
	ldy.w #$0005					; second assist byte
	lda.b [a4],y
	and.w #$00FF
	sta.b d0
	bit.w #$0080					; none: done
	bne .ex
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1Pri,$0C,$08)
	jsl.l FormatPlayerNumInitial
	jsl.l print						; print it
.ex:								; restore registers
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
