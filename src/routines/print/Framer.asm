Framer:								;Draw a frame and fill it. d0 / d1 = width / height, printx / printy /
									;printm = top left corner

									;a d0 x d1 box of FramerMap pieces at printx/printy
	phx								; keep X
	lda.w printx					; print x
	sta.b tmp0						; left edge
	lda.b d0						; width
	sta.b tmp2
	ldx.w #$0000					; top left piece
	jsl.l .setter					; set it
	dec.b tmp2						; width - 2
	dec.b tmp2
.top:								; top middle piece
	ldx.w #$0002					; top middle piece
	jsl.l .setter					; set it
	dec.b tmp2						; next
	bne .top
	ldx.w #$0004					; top right piece
	jsl.l .setter					; set it
	dec.b d1						; height - 2
	dec.b d1
.row:								; next row
	lda.b tmp0						; left edge
	sta.w printx					; back to the left
	inc.w printy					; next row
	lda.b d0						; width
	dec a							; -2
	dec a
	sta.b tmp2
	ldx.w #$0006					; left piece
	jsl.l .setter					; set it
.mid:								; middle piece
	ldx.w #$0008					; middle piece
	jsl.l .setter					; set it
	dec.b tmp2						; next
	bne .mid
	ldx.w #$000A					; right piece
	jsl.l .setter					; set it
	dec.b d1						; next row
	bne .row
	lda.b tmp0						; left edge
	sta.w printx
	inc.w printy					; next row
	dec.b d0						; width - 2
	dec.b d0
	ldx.w #$000C					; bottom left piece
	jsl.l .setter					; set it
.bot:								; bottom middle piece
	ldx.w #$000E					; bottom middle piece
	jsl.l .setter					; set it
	dec.b d0						; next
	bne .bot
	ldx.w #$0010					; bottom right piece
	jsl.l .setter					; set it
	lda.b tmp0						; left edge
	sta.w printx
	inc.w printy					; next row
	plx								; restore X
	rtl
.setter:							;one FramerMap piece (X = piece * 2) at printx/printy, printx + 1
	lda.l FramerMap,x
	clc
	adc.w framercset
	clc
	adc.w printfontset
	pha
	lda.w printy
	asl a
	asl a
	asl a
	asl a
	asl a
	adc.w printx
	asl a
	adc.b printm
	tax
	pla
	ora.w printa
	sta.l textmap,x
	inc.w printx
	txa
	lsr a
	cmp.b textdirtylo
	bcs .lo
	sta.b textdirtylo
.lo:								; low end of the dirty range
	cmp.b textdirtyhi
	bcc .hi
	sta.b textdirtyhi
.hi:								; high end of the dirty range
	rtl
