ChkShotStat:						;If a shot was taken, add it to the shooting team's shots
	lda.w #sf2shot					; shot flag
	trb.w sflags
	beq .rtl						; no shot
	stx.b xsave						; keep X
	ldx.w #$0000					; save d0 through d3
.save:								; save d0 and the words after it (4 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0008
	bne .save
	ldx.b xsave						; restore X
	phx								; keep X
	lda.w shotplayer				; shooter
	asl a							; times 2
	tax								; X
	stx.b a3						; a3 = the shooter
	lda.w #$0001					; add 1
	sta.b d0
	lda.w #tmshots					; shots
	sta.b d1
	jsl.l ChkShotStat_add				; to the team stat
	plx								; restore X
	stx.b a3						; X again
	stx.b xsave						; keep X
	ldx.w #$0006					; pull them back
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
.rtl:								; return
	rtl
