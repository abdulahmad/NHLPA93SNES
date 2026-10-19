GetNameandAttrib:					;Print player d0's number and name, then the roster column picked by d4
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d0 and the words after it (10 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0014
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
	jsl.l getname					; get the player name
	jsl.l print						; print it
	lda.w #$001A					; rating column at x 26
	sta.w printx
	lda.b d4						; status, energy, handed: no ratings
	cmp.w #$0003
	bcs .rate
	jmp.w .jump
.rate:								; player rating attributes
	ldy.b a2
	lda.w #TeamList>>16
	sta.b a0+2
	lda.w tmdata,y					; team data, player records
	sta.b a0
	clc
	ldy.w #Playerdata				; player records offset
	adc.b [a0],y
	sta.b a0
.skip:								; skip to the next team entry
	lda.b a0
	clc
	adc.b [a0]
	adc.w #$0008
	sta.b a0
	dec.b d0
	bpl .skip
	stz.b d0						; d0 = sum of the ratings
	stz.b d1
	lda.w #$000F					; test 16 attribute bits
	sta.b d2
	lda.b d4						; swap the two halves of d4
	ldy.b d4+2
	sta.b d4+2
	sty.b d4
.bit:								; test one attribute bit
	lda.b d4
	sta.b tmp0
	lda.b d4+2
	sta.b tmp1
	lda.b d2
	sta.b tmp2
.shift:								; shift the remaining bits
	dec.b tmp2
	bmi .test
	lsr.b tmp1
	ror.b tmp0
	bra .shift
.test:								; bit set: read the attribute
	lsr.b tmp0
	bcc .next
	lda.b d2
	lsr a
	eor.w #$FFFF					; negate
	inc a
	dec a
	clc
	adc.b a0
	sta.b tmp0
	lda.b a0+2
	sta.b tmp1
	lda.b [tmp0]					; read the packed attribute byte
	sta.b d3
	lda.b d2
	lsr a
	bcc .2							; odd attribute: high nibble
	lda.b d3
	lsr a
	lsr a
	lsr a
	lsr a
	sta.b d3
.2:									; keep the low nibble
	lda.b d3
	and.w #$000F
	sta.b d3
	clc
	adc.b d0
	sta.b d0						; d0 = sum of ratings
	lda.b d1
	clc
	adc.w #$000F
	sta.b d1						; d1 = 15 * count (max)
.next:								; next attribute
	dec.b d2
	bpl .bit
	lda.b d4
	ldy.b d4+2
	sta.b d4+2
	sty.b d4
.jump:								;go to attribjmp[d4] through jmlvector
	lda.w #attribjmp
	sta.b a0
	lda.w #attribjmp>>16
	sta.b a0+2
	ldy.b d4						; d4 selects the routine
	lda.b [a0],y
	clc
	adc.b a0
	sta.b a0
	sta.w jmlvector+1				; patch the jump address
	lda.b a0+1
	sta.w jmlvector+2
	jsl.l jmlvector
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
	ldx.w #$0012
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
