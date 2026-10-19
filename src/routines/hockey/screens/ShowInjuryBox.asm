ShowInjuryBox:						;The injury box: the injured player and whether he is out for the period
									;or the game
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
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1Pri,$0B,$03)
	lda.w #$0012
	sta.b d0
	lda.w #$0005
	sta.b d1
	jsl.l Framer					; draw the frame d0 x d1
	jsl.l printz					; print the string that follows
	%StringCtctc(CC_Font1Pri,$0C,$04,"Injury to:",CC_Font1Pri,$0C,$06,"Out for period",CC_Font1Pri,$0C,$05)
	jsl.l GetPlayerNumInitial
	jsl.l print						; print it
	lda.w pf2fight+puckobj
	beq .period
	jsl.l printz					; print the string that follows
	%StringCt(CC_Font1Pri,$14,$06,"the game")
.period:							; restore registers
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
