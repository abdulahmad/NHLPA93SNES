SetHor:								;Switch to the horizontal rink (the scoreboard screen)
	stx.b xsave						; keep the caller's X
	ldx.w #$0000
.save:								; save d0 through a3 (14 words) on the stack
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$001C
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; X again for the second save
	ldx.w #$0000
.savea:								; save a0 and the 13 words after it (14 words)
	lda.b a0,x						
	pha
	inx
	inx
	cpx.w #$001C
	bne .savea
	ldx.b xsave						; restore X
	lda.w puckvx
	pha
	asl a							; carry = sign of puckvx
	pla
	ror a							; arithmetic shift right: puckvx / 2
	sta.w puckvx
	lda.w puckvy
	pha
	asl a							; carry = sign of puckvy
	pla
	ror a							; arithmetic shift right: puckvy / 2
	sta.w puckvy
	jsl.l forceblack				; blank the screen while it changes
	lda.w #$0001
	sta.w sfhormode					; horizontal rink mode on
	stz.w Hscroll					; scroll x = 0
	lda.w #$FFFF
	sta.w Vscroll					; scroll y = -1
	lda.w #$002E
	sta.w Oldrow					; row to draw from
	stz.w vramrow					; vram row = 0
	jsl.l SprSort					; sort the sprites
	jsl.l SetHor_rink				; set up the horizontal rink
	stx.b xsave
	ldx.w #$001A					
.resta:								; pull a0 and the 13 words after it back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	stx.b xsave						; X again for the second restore
	ldx.w #$001A					
.restore:							; pull d0 through a3 back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave
	ldx.b a3						; X = a3
	rtl
