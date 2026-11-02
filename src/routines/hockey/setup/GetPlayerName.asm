GetPlayerName:						;mesarea = the number and name of player TempPlOffset
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d0 and d0+2
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0004
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; X again
	ldx.w #$0000
.savea2:							; save a2 and a2+2
	lda.b a2,x
	pha
	inx
	inx
	cpx.w #$0004
	bne .savea2
	ldx.b xsave						; restore X
	stz.b a2						; team 0
	lda.w TempPlOffset				; bit 15: away team
	sta.b d0						; id
	bpl .name						; home
	and.w #$00FF					; player number
	sta.b d0
	inc.b a2						; away: a2 = 2
	inc.b a2
.name:								; get the name text
	jsl.l getname					; name text
	stx.b xsave						; X again
	ldx.w #$0002
.resta2:							; pull a2 back
	pla
	sta.b a2,x
	dex
	dex
	bpl .resta2
	ldx.b xsave						; restore X
	stx.b xsave						; X again
	ldx.w #$0002
.restore:							; pull d0 back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
