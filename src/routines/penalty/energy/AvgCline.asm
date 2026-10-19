AvgCline:							;d0 = the average energy of team a2's current line
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d1 and the words after it (6 words)
	lda.b d1,x
	pha
	inx
	inx
	cpx.w #$000C
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0000
.savea:								; save a0 and the words after it (2 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0004
	bne .savea
	ldx.b xsave						; restore X
	stz.b d0
	stz.b d1
	lda.w #$0005
	sta.b d2
	ldy.b a2
	lda.w tmsort,y
	sta.b a0
.l0:								; each player on the line
	ldy.b a0
	lda.w position,y
	beq .next
	bmi .next
	lda.w pnum,y
	and.w #$00FF
	asl a
	sta.b d3
	lda.b a2
	beq .idx
	lda.w #maxros*2
.idx:								; index the player energy
	adc.b d3
	tay
	lda.w tmpde,y
	adc.b d0
	sta.b d0
	inc.b d1
.next:								; next player
	inc.b a0
	inc.b a0
	dec.b d2
	bpl .l0
	lda.b d1						; players counted
	beq .ex
	sta.b mula
	lda.b d0
	sta.b mulb
	jsl.l divu16					; mulb / mula
	sta.b d0
.ex:								; restore and return
	stx.b xsave						; keep X
	ldx.w #$0002
.resta:								; pull a0 and the words after it back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$000A
.restore:							; pull d1 and the words after it back
	pla
	sta.b d1,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
