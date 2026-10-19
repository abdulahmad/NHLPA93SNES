PushRef:							;Draw referee frame d0 in the referee window; frame $40 erases the window
	phx
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d0 and the words after it (6 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$000C
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0000
.savea:								; save a0 and the words after it (4 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0008
	bne .savea
	ldx.b xsave						; restore X
	lda.b d0
	cmp.w #$40
	bne .draw
	jmp.w .clearit
.draw:
	sta.b mulb
	lda.w #$70
	sta.b mula
	jsl.l mulu16					; A = mula * mulb
	sta.b d0
	lda.w #RefsMap
	sta.b a0
	lda.w #RefsMap>>16
	sta.b a0+2
	lda.w #(2*32+2)*2				; textmap offset of the window: row 2, column 2
	sta.b tmp1
	lda.w refchars
	sta.b tmp0
	lda.w sfhormode
	beq .nosfhormode
	lda.w refcharshor
	sta.b tmp0
	lda.w #(15*32+13)*2				; horizontal rink: row 15, column 13
	sta.b tmp1
	lda.w #RefsMapHor
	sta.b a0
	lda.w #RefsMapHor>>16
	sta.b a0+2
.nosfhormode:
	lda.b a0
	clc
	adc.b d0
	sta.b a0
	lda.w #$0008
	sta.b tmp2
.row:
	ldy.w #$0007
.1:
	lda.b [a0]
	clc
	adc.b tmp0
	adc.w charofs
	ldx.b tmp1
	ora.w #$2000
	sta.l textmap,x
	txa
	lsr a
	cmp.b textdirtylo
	bcs .lo
	sta.b textdirtylo
.lo:
	cmp.b textdirtyhi
	bcc .hi
	sta.b textdirtyhi
.hi:
	inc.b a0
	inc.b a0
	inc.b tmp1
	inc.b tmp1
	dey
	bne .1
	lda.b tmp1
	clc
	adc.w #$0032
	sta.b tmp1
	dec.b tmp2
	bne .row
	lda.w #sf2refref
	tsb.w sflags
	bra .ex
.clearit:
	lda.w #$0007
	sta.b d0
	lda.w #$0008
	sta.b d1
	lda.w blankchar
	sta.b d2
	lda.w #$0002
	sta.w printx
	sta.w printy
	lda.w sfhormode
	beq .nosfhormode2
	lda.w #$000D
	sta.w printx
	lda.w #$000F
	sta.w printy
.nosfhormode2:
	jsl.l eraser					; erase d0 x d1 with tile d2
	lda.w #sf2refref
	tsb.w sflags
	lda.w #$FFFF
	sta.b d0
	jsl.l prefmes
.ex:
	stx.b xsave						; keep X
	ldx.w #$0006
.resta:								; pull a0 and the words after it back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$000A
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	plx
	rtl
