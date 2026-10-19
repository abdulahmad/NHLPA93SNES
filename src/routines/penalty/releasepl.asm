releasepl:							;Player d0's penalty time is up: let him out of the box and put him on the
									;ice
	stx.b xsave
	ldx.w #$0000
.save:								; save d0 through d7
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0010
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; X again
	ldx.w #$0000
.savea:								; save a0 through a7
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0010
	bne .savea
	ldx.b xsave						; restore X
	ldy.b a2						; team
	ldx.w tmsort,y					; first player of the team
	dex
	dex
.find:
	inx								; next player
	inx
	lda.w position,x				; position
	bpl .find						; a free slot (negative position)
	lda.b d0						; player number
	lsr a
	sta.b d3						; d3 = player index
	ldy.b a2
	lda.w tmap,y					; players on the ice
	sta.b d1
	inc a							; one more
	sta.w tmap,y
	lda.w #$0001
	tsb.w tmflags					; team flags
	tsb.w tmflags+2
	lda.w #priolist					; priority list
	sta.b a0
	lda.w #priolist>>16
	sta.b a0+2
	lda.w tmgoalie,y				; goalie out
	bpl .tmgoaliepos
	inc.b a0						; else the second list
.tmgoaliepos:
	ldy.b d1						; number of players
	lda.b [a0],y					; position for him
	and.w #$00FF
	sta.w position,x				; store it
	stx.b a3						; X
	jsl.l Setplass					; assignment from the position
	jsl.l setplayer					; set up the player
	lda.w pflags,x
	ora.w #pf2unav					; unavailable
	sta.w pflags,x
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
	ldx.w #$000E
.restore:							; pull d0 back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	ldx.b a3						; X = a3
	rtl
