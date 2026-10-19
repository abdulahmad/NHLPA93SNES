UpdateRosterPlayers:				;One frame of the two roster players shown in the team blocks
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d0 through d7
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0020
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; X again
	ldx.w #$0000
.savea:								; save a0 and 13 more words
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$001C
	bne .savea
	ldx.b xsave						; restore X
	lda.w #$0001					; d7 = 1 frame
	sta.b d7						; one frame
	stz.b a2						; team 0
	jsl.l UpdateRosterPlayer		; animate player
	lda.w #$0002					; team 1
	sta.b a2
	jsl.l UpdateRosterPlayer		; animate player
	jsl.l UpdateTeamSprites			; update the sprites
	stx.b xsave						; X again
	ldx.w #$001A
.resta:								; pull the registers back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	stx.b xsave						; X again
	ldx.w #$001E
.restore:							; pull d0 through d7 back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	ldx.b a3						; X = a3
	rtl
