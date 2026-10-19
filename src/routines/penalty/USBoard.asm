USBoard:							;Update the scoreboard, with the players in the
									;penalty box and their time left
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
.savea:								; save a0 and the words after it (8 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0010
	bne .savea
	ldx.b xsave						; restore X
	jsl.l printscores1				; redraw the scores
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1Pri,$14,$08)
	stz.b a2
	jsl.l .dispen
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1Pri,$05,$08)
	lda.w #$0002
	sta.b a2
	jsl.l .dispen
	stx.b xsave						; keep X
	ldx.w #$000E
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
	ldx.b a3
.rtl:								; return
	rtl
.dispen:							;penalty box list of team a2: timed players first
	lda.b a2
	beq .noa2
	lda.w #$001A
.noa2:
	sta.b a0
.l1:
	ldy.b a0
	lda.w tmboxlist,y
	inc.b a0
	and.w #$00FF
	sta.b d0
	bit.w #$0080
	bne .p2
	lda.b a2
	beq .noa22
	lda.w #$0034
.noa22:
	clc
	adc.b d0
	tay
	lda.w tmpdst,y
	bit.w #$4000
	bne .l1
	jsl.l pplpen
	bra .l1
.p2:
	lda.b a2
	beq .noa23
	lda.w #$001A
.noa23:
	sta.b a0
.l2:
	ldy.b a0
	lda.w tmboxlist,y
	inc.b a0
	and.w #$00FF
	sta.b d0
	bit.w #$0080
	bne .rtl
	lda.b a2
	beq .noa24
	lda.w #$0034
.noa24:
	clc
	adc.b d0
	tay
	lda.w tmpdst,y
	bit.w #$4000
	beq .l2
	jsl.l pplpen
	bra .l2
