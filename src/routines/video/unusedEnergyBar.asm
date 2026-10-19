unusedEnergyBar:					;Build an energy bar of d0 in the message area without printing it. Unused
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d0 and the words after it (8 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0010
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0000
.savea:								; save a1 and the words after it (2 words)
	lda.b a1,x
	pha
	inx
	inx
	cpx.w #$0004
	bne .savea
	ldx.b xsave						; restore X
	lda.w #$2000
	sta.w printa
	lda.b d0
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	cmp.w #$0020
	bcc .cap
	lda.w #$001F
.cap:
	sta.b d0
	ldy.w #$0002
	lda.w #$0006
	sta.w mesarea
	lda.w #$0003
	sta.b d3
.char:
	lda.w #$FFFF
	sta.b d2
	lda.b d0
	bmi .level
	sta.b d2
	cmp.w #$0008
	bcc .level
	lda.w #$0007
	sta.b d2
.level:
	lda.b d2
	sec
	adc.b d1
	and.w #$00FF
	bne .tile
	lda.w #$0020
.tile:
	sta.w mesarea,y
	iny
	lda.b d0
	sec
	sbc.w #$0008
	sta.b d0
	dec.b d3
	bpl .char
	lda.b d1
	beq .nod1
	lda.w #$0C00
	tsb.w printa
.nod1:
	lda.w #mesarea
	sta.b a1
	lda.w #mesarea>>16
	sta.b a1+2
	lda.w printx
	sec
	sbc.w #$000B
	sta.w printx
	lda.w #$4000
	tsb.w printa
	lda.w #mesarea
	sta.b a1
	lda.w #mesarea>>16
	sta.b a1+2
	sep #$20						; 8-bit A
	lda.w mesarea+5
	ldy.w mesarea+2
	sta.w mesarea+2
	sty.w mesarea+5
	rep #$30						; 16-bit registers
	lda.w mesarea+3
	xba
	sta.w mesarea+3
	lda.w #$4000
	trb.w printa
	stx.b xsave						; keep X
	ldx.w #$0002
.resta:								; pull a1 and the words after it back
	pla
	sta.b a1,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$000E
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
