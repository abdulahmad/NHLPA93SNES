UnpackNibbles:						;Unpack d0 4-bit values at [a0] (high nibble first) into words at
									;nibblebuffer
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d0 through d5
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$000C
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; X again
	ldx.w #$0000
.savea:								; save a0 through a3
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0008
	bne .savea
	ldx.b xsave						; restore X
	lda.w #nibblebuffer				; nibble buffer
	sta.b a1
	lda.w #$0000
	sta.b a1+2
	stz.b d2						; nibble counter
	bra .next						; go
.loop:								; next nibble (one count per pass)
	lda.b [a0]						; byte
	inc.b a0						; next byte
	and.w #$00FF
	sta.b d1						; d1 = byte
	inc.b d2						; count
	lda.b d2
	lsr a							; odd nibble?
	bcc .lo
	dec.b a0						; same byte again
	lda.b d1
	lsr a							; high nibble
	lsr a
	lsr a
	lsr a
	sta.b d1
.lo:								; low nibble
	lda.b d1
	and.w #$000F					; 4 bits
	sta.b [a1]						; store
	inc.b a1
	inc.b a1
.next:								; loop count in d0
	dec.b d0						; count down
	bpl .loop
	stx.b xsave						; X again
	ldx.w #$0006
.resta:								; pull a0 back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	stx.b xsave						; X again
	ldx.w #$000A
.restore:							; pull d0 back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
