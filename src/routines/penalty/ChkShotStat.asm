ChkShotStat:						;If a shot was taken, add it to the shooting team's shots
	lda.w #sf2shot					; shot flag
	trb.w sflags
	beq .rtl						; no shot
	stx.b xsave						; keep X
	ldx.w #$0000					; save d0 through d3
.save:
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
	jsl.l addteamstat				; to the team stat
	plx								; restore X
	stx.b a3						; X again
	stx.b xsave
	ldx.w #$0006					; pull them back
.restore:
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
.rtl:
	rtl
