ContinuePlayoffs:					;Continue the playoffs: read the playoff state back from the password bits
									;and rebuild the tree. Unused
	stx.b xsave
	ldx.w #$0000					; save d0 through d7
.save:
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0020
	bne .save						; restore X
	ldx.b xsave						; X again
	stx.b xsave
	ldx.w #$0000					; save a0 through a3
.savea:
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0010
	bne .savea						; restore X
	ldx.b xsave
	lda.w #passbits					; a3 = passbits
	sta.b a3
	lda.w #$0000
	sta.b a3+2
	jsl.l ReadPassBits				; read the password bits
	lda.w gamelevel					; round
	ora.b bosgames					; plus best of seven
	sta.b d0
	beq .ex							; none: leave
	jsl.l maketree					; build the tree
	lda.w #$0007					; menu value from pojoy
	sec
	sbc.w pojoy
	sta.w OptPlayers				; number of players
.ex:
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
