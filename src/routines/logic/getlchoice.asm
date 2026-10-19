getlchoice:							;d0 = the line for line choice d0 of team a2, by the man advantage; -1 =
									;none
	stx.b xsave						; keep the caller's X
	ldx.w #$0000
.save:								; save d1 through d4 on the stack
	lda.b d1,x
	pha
	inx
	inx
	cpx.w #$0008
	bne .save
	ldx.b xsave						; restore X
	lda.b a2						; d2 = other tmap - our tmap: players short
	eor.w #2						; the other team's slot
	tay
	lda.w tmap,y					; other team's tmap
	ldy.b a2
	sec
	sbc.w tmap,y					; minus our tmap
	sta.b d2
	beq .1							; equal strength: table section 0 (no power play)
	lda.b d0						; penalty killing: +21
	clc
	adc.w #21
	sta.b d0
	lda.b d2						; sign of the difference
	bmi .1							; bmi: the penalty killing section, no more added
	lda.b d0						; power play: +21 more
	clc
	adc.w #21
	sta.b d0
.1:									; section chosen: add 3 * the team's current line (tmline)
	ldy.b a2						; + 3 * tmline
	lda.w tmline,y
	sta.b d1
	lda.b d0
	clc
	adc.b d1
	clc
	adc.b d1
	clc
	adc.b d1
	sta.b d0
	tay								; offset into the table
	lda.w #.tab						; a0 = the table
	sta.b a0
	lda.w #.tab>>16
	sta.b a0+2
	lda.b [a0],y					; choice for this button, -1 = none
	and.w #$00FF
	bit.w #$0080
	beq .sext						; a negative byte: sign extend
	ora.w #$FF00
.sext:
	sta.b d0						; d0 = the line, or -1
	stx.b xsave						; keep X
	ldx.w #$0006
.restore:							; pull d1 and the words after it back
	pla
	sta.b d1,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
.tab:								;line for choice 0-2 by tmline, 3 entries per line (-1 = none)
	db 0,1,2, 1,2,0, 2,0,1, 0,1,2, 0,1,2, 0,1,2, 0,1,2	; no power play: lines 0-6
	db 3,4,-1, 3,4,-1, 3,4,-1, 3,4,-1, 4,3,-1, 3,4,-1, 3,4,-1	; penalty killing: lines 0-6
	db 5,6,-1, 5,6,-1, 5,6,-1, 5,6,-1, 5,6,-1, 5,6,-1, 6,5,-1	; power play: lines 0-6
