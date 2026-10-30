PauseExit:							;Restore the screen and leave pause mode
	stz.w cuetimer					; cue off
	stz.w crowdvol					; crowd off
	jsl.l forceblack				; blank the screen
	phx								; keep X
	ldx.w #$07FE					; 2KB
.restoretext:						; restore the saved text map
	lda.l textsave,x				; saved text
	sta.l textmap,x					; back to the text map
	dex
	dex
	bpl .restoretext
	plx								; restore X
	stz.b textdirtylo				; all dirty
	lda.w #$03FF					; 1023 words
	sta.b textdirtyhi
	pla								; flags from the stack
	sta.w sflags
	pla								; horizontal mode
	sta.w sfhormode
	bne .hor						; vertical: redo it
	jsl.l ClrHor					; clear horizontal
.hor:								; redraw the scores in horizontal mode
	lda.w #$0001					; first flag bit
	trb.w sflags					; clear it
	jsl.l printscores1				; redraw the scores
	jsl.l setvideo					; update the video
	lda.b Vcount					; frame counter
	sta.w lastframevc				; last frame
	sta.w OldVcount					; old counter
	rtl
