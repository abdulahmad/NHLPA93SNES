ScrollDisplayUp:					;The next line of the scouting report text; scroll the text box up when it
									;is full
	stz.w DispAttribCtr				; attribute counter 0
	inc.w VertLineScrolling			; next line
	lda.w VertLineScrolling			; full?
	sec
	sbc.w #$0007
	bmi .neg
	bvc .up							; not yet
.ex1:								; signed compare done: leave
	jmp.w UpdateScoutingDisplay_rtl	; full: leave
.neg:								; signed compare: overflow flag corrects the sign
	bvc .ex1
.up:								; back to the last line
	dec.w VertLineScrolling			; back to the last line
	stx.b xsave						; keep X
	ldx.w #$0000					; save d0 through d7
.save:								; save d0 and the words after it (8 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0010
	bne .save
	ldx.b xsave						; restore X
	lda.w #$0007					; 8 rows
	sta.b d3
	lda.w #textmap+(4*$40)+(10*2)	; the text box (row 4, column 10)
	sta.b d1
	lda.w #textmap>>16
	sta.b d1+2
.loop:								; copy 8 rows of the text box up by one row
	lda.w #$0028					; 40 bytes
	sta.b d0
	lda.b d1						; source = destination row
	clc
	adc.w #$0040					; plus a row ($40)
	sta.b d2
	lda.b d1+2
	sta.b d2+2
	jsl.l CopyWords					; copy a textmap row
	lda.b d2
	sta.b d1
	lda.b d2+2
	sta.b d1+2
	dec.b d3						; next row
	bpl .loop
	stx.b xsave						; X again
	ldx.w #$000E
.restore:							; pull them back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
