prefmes:							;Print the message for penalty d0, or clear it when negative: under the
									;referee on the vertical rink,
		;   one centered line on the horizontal rink
	stx.b xsave						; save d0 through d5
	ldx.w #$0000
.save:
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$000C
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; X again
	ldx.w #$0000
.savea1:							; save a1 and a1+2
	lda.b a1,x
	pha
	inx
	inx
	cpx.w #$0004
	bne .savea1
	ldx.b xsave						; restore X
	lda.w sfhormode					; horizontal mode
	beq .nosfhormode
	jmp.w .hor						; yes
.nosfhormode:
	lda.b d0						; penalty number
	bpl .d0pos						; a penalty
	jsl.l printz					; clear the message
	%StringCp(CC_Font1Pri,$00,$0A)
	lda.w #$000D					; 13 wide
	sta.b d0
	lda.w #$0003					; 3 high
	sta.b d1
	lda.w blankchar					; blank character
	sta.b d2
	jsl.l eraser					; erase
	jmp.w .ex
.d0pos:
	jsl.l printz					; set the position
	%StringCp(CC_Font1Pri,$05,$0A)
	ldy.b d0						; penalty offset
	lda.w #Penaltylist				; penalty list
	sta.b a1
	lda.w #Penaltylist>>16
	sta.b a1+2
	lda.b [a1],y					; data offset
	clc
	adc.b a1
	inc a
	inc a
	sta.b a1						; a1 = penalty data
	lda.b [a1]						; text length
	dec a
	dec a
	sta.b d0						; characters
	beq .ex							; no text
	inc a
	lsr a
	sta.b d0						; half of it
	lda.w printx
	sec
	sbc.b d0
	sta.w printx					; center the text
	bpl .pos						; not negative
	stz.w printx					; clamp to 0
.pos:
	lda.b [a1]						; text length
	sta.b d0						; d0
	tay
	dec.b a1
	lda.b [a1],y					; first delay byte
	inc.b a1
	and.w #$00FF					; zero?
	bne .nonzero
	dec.b d0						; one less
.nonzero:
	lda.w #$0003					; 3 high
	sta.b d1
	jsl.l Framer					; draw the frame
	dec.w printy					; up to the text row
	dec.w printy
	inc.w printx					; inside the frame
	jsl.l print						; print the text
	bra .ex
.hor:
	jsl.l ClearPenaltyMessage		; clear the old message
	lda.b d0						; a penalty?
	bmi .ex							; no: leave
	jsl.l printz					; set the position
	%StringCp(CC_Font1Pri,$11,$0B)
	lda.w #Penaltylist
	sta.b a1
	lda.w #Penaltylist>>16
	sta.b a1+2
	ldy.b d0						; penalty offset
	lda.b [a1],y					; data offset
	clc
	adc.b a1
	inc a
	inc a
	sta.b a1						; text
	lda.b [a1]
	lsr a							; half of the text length
	sta.b d0
	lda.w printx
	sec
	sbc.b d0
	sta.w printx					; center
	jsl.l print						; print it
.ex:
	stx.b xsave						; keep X
	ldx.w #$0002					; pull a1 back
.resta1:
	pla
	sta.b a1,x
	dex
	dex
	bpl .resta1
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
