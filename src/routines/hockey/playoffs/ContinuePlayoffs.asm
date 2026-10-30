ContinuePlayoffs:					;Continue the playoffs: read the playoff state back from the password bits
									;and rebuild the tree. Unused
	stx.b xsave						; keep X
	ldx.w #$0000					; save d0 through d7
.save:								; save d0 and the words after it (16 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0020
	bne .save						; restore X
	ldx.b xsave						; X again
	stx.b xsave						; keep X
	ldx.w #$0000					; save a0 through a3
.savea:								; save a0 and the words after it (8 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0010
	bne .savea						; restore X
	ldx.b xsave						; restore X
	lda.w #passbits					; a3 = passbits
	sta.b a3
	lda.w #$0000
	sta.b a3+2
	jsl.l ReadPassBits				; read the password bits
	lda.w gamelevel					; round
	ora.b bosgames					; plus best of seven
	sta.b d0
	beq .ex							; none: leave
	jsl.l MakeTree					; build the tree
	lda.w #$0007					; menu value from pojoy
	sec
	sbc.w pojoy
	sta.w OptNOP				; number of players
.ex:								; restore the registers
	stx.b xsave						; X again
	ldx.w #$000E
.resta:								; pull a0 back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	stx.b xsave						; X again
	ldx.w #$001E
.restore:							; pull d0 back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	ldx.b a3						; X = a3
	rtl
