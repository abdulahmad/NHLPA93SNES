PushRef:							;Draw referee frame d0 in the referee window; frame $40 erases the window
	phx								; save X
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
	lda.b d0						; frame number
	cmp.w #$40						; $40: erase the window
	bne .draw
	jmp.w .clearit
.draw:
	sta.b mulb						; frame number
	lda.w #$70						; frame size $70
	sta.b mula
	jsl.l mulu16					; A = mula * mulb
	sta.b d0						; offset of the frame
	lda.w #RefsMap					; referee map
	sta.b a0
	lda.w #RefsMap>>16
	sta.b a0+2
	lda.w #(2*32+2)*2				; textmap offset of the window: row 2, column 2
	sta.b tmp1
	lda.w refchars					; referee tile base
	sta.b tmp0
	lda.w sfhormode					; horizontal mode?
	beq .nosfhormode
	lda.w refcharshor
	sta.b tmp0						; horizontal tile base
	lda.w #(15*32+13)*2				; horizontal rink: row 15, column 13
	sta.b tmp1
	lda.w #RefsMapHor
	sta.b a0						; horizontal referee map
	lda.w #RefsMapHor>>16
	sta.b a0+2
.nosfhormode:
	lda.b a0						; frame address
	clc
	adc.b d0
	sta.b a0
	lda.w #$0008					; 8 rows
	sta.b tmp2
.row:
	ldy.w #$0007					; 7 tiles per row
.1:
	lda.b [a0]						; map word
	clc
	adc.b tmp0						; plus the tile base
	adc.w charofs					; plus the character offset
	ldx.b tmp1						; text map position
	ora.w #$2000					; priority and palette bits
	sta.l textmap,x					; store it
	txa
	lsr a							; dirty range low
	cmp.b textdirtylo
	bcs .lo
	sta.b textdirtylo				; new low
.lo:
	cmp.b textdirtyhi				; dirty range high
	bcc .hi
	sta.b textdirtyhi				; new high
.hi:
	inc.b a0
	inc.b a0
	inc.b tmp1						; next position
	inc.b tmp1
	dey
	bne .1
	lda.b tmp1						; next row
	clc
	adc.w #$0032					; row stride
	sta.b tmp1
	dec.b tmp2						; rows left
	bne .row
	lda.w #sf2refref				; referee window changed
	tsb.w sflags
	bra .ex
.clearit:
	lda.w #$0007					; erase size 7 x 8
	sta.b d0
	lda.w #$0008
	sta.b d1
	lda.w blankchar					; blank tile
	sta.b d2
	lda.w #$0002					; window at column 2, row 2
	sta.w printx
	sta.w printy
	lda.w sfhormode					; horizontal mode?
	beq .nosfhormode2
	lda.w #$000D					; column $0D
	sta.w printx
	lda.w #$000F					; row $0F
	sta.w printy
.nosfhormode2:
	jsl.l eraser					; erase d0 x d1 with tile d2
	lda.w #sf2refref				; referee window changed
	tsb.w sflags
	lda.w #$FFFF					; no message
	sta.b d0
	jsl.l prefmes					; clear the referee message
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
