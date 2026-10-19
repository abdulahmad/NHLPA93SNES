PrintTeamNames:						;Print both team names, then set up the teams
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d0 and the words after it (16 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0020
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0000
.savea:								; save a0 and the words after it (6 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$000C
	bne .savea
	ldx.b xsave						; restore X
	lda.w OptPlayMode				; OptPlayMode 0: teams from the options
	bne .print
	lda.w OptTeam1
	sta.w HomeTeam
	lda.w OptTeam2
	sta.w VisTeam
.print:
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font2Pri,$02,$01)
	lda.w VisTeam
	sta.b d1
	jsl.l DrawTeamBlocks			; print team d1 name
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font2Pri,$15,$01)
	lda.w HomeTeam
	sta.b d1
	jsl.l DrawTeamBlocks			; print team d1 name
	jsl.l setteams
	stx.b xsave						; keep X
	ldx.w #$000A
.resta:								; pull a0 and the words after it back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$001E
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
