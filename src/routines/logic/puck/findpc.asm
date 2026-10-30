findpc:								;When and where the puck will cross each goal line
	stx.b xsave						; keep X
	ldx.w #$0000					; save d0 through d4
.save:								; save d0 and the words after it (10 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0014
	bne .save
	ldx.b xsave						; restore X
	lda.w #Blueline+goalline		; top goal line (Blueline+goalline)
	sta.b d4						; y of the goal line
	ldy.w #$0000					; result slot 0
	jsl.l findpc_calc				; time and place there
	lda.w #-(Blueline+goalline)		; bottom goal line
	sta.b d4						; y of the other goal line
	ldy.w #$0004					; result slot 4
	jsl.l findpc_calc				; time and place there
	stx.b xsave						; keep X
	ldx.w #$0012
.restore:							; pull d0-d4 back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
