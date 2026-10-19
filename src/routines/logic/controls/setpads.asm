setpads:							;Store which player a pad marker belongs to, so the graphics can show it
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d0 through d3
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0008
	bne .save
	ldx.b xsave						; restore X
	lda.w #$0002					; d0 = (2 + d4) * 2 = nibble shift
	clc
	adc.b d4						; plus d4
	asl a							; times 2
	sta.b d0						; d0 = shift
	sta.b tmp0						; loop counter
	lda.w #$FFF0					; mask $FFF0
	sta.b d1
.m1:								;d1 = $FFF0 rotated left by d0
	lda.b tmp0						; loop
	beq .and						; done
	dec.b tmp0						; count down
	asl.b d1						; rotate the mask
	bcc .m2							; no carry
	inc.b d1						; carry into bit 0
.m2:								; again
	bra .m1							; again
.and:								; clear the nibble
	lda.w PadControlBits			; pad bits
	and.b d1						; clear the nibble
	sta.w PadControlBits
	lda.w SCnum,x					; marker number
	sta.b d1
.sh:								;d1 = SCnum << d0
	lda.b d0						; shift loop
	beq .or
	dec.b d0						; count down
	asl.b d1						; shift
	bra .sh
.or:								; insert the marker
	lda.w PadControlBits			; pad bits
	ora.b d1						; insert the marker
	sta.w PadControlBits			; store
	stx.b xsave						; X again
	ldx.w #$0006
.restore:							; pull them back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
