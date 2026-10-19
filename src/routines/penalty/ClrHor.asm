ClrHor:								;Switch back from the horizontal rink to the vertical ice rink
	stx.b xsave						; keep X
	ldx.w #$0000
.savea:								; save a0 and 29 more words (30 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$003C
	bne .savea
	ldx.b xsave
	stz.w sfhormode					; vertical
	lda.w #999						; Oldrow = 999: redraw the rink rows
	sta.w Oldrow
	jsl.l SprSort					; sort the sprites
	lda.w sflags					; flags
	bit.w #sfpz						; paused: keep the text
	bne .ex							; keep the text
	lda.w blankchar					; clear the text map
	clc								; plus the character offset
	adc.w charofs
	ldx.w #$07FE					; 2KB
.clr:
	sta.l textmap,x					; clear the text map
	dex
	dex
	bpl .clr
	stz.b textdirtylo				; whole text map dirty
	lda.w #$03FF
	sta.b textdirtyhi				; 1023 words
	jsl.l printscores1				; redraw the scores
.ex:
	stx.b xsave						; X again
	ldx.w #$003A
.resta:								; pull the registers back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	ldx.b a3						; X = a3
	rtl
