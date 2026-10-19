waitxsr:							;Wait d0 frames or until a button in d1 is pressed (used while the zamboni
									;crosses)
	lda.b d0						; frame count
	pha
.wait:
	jsl.l ReadJoy1					; pad 1
	lda.b d1						; buttons
	bne .exit						; pressed: done
	jsl.l ReadJoy2					; pad 2
	lda.b d1
	bne .exit						; pressed: done
	jsl.l setvideo					; update the screen
	lda.b vcount					; frame counter
.vb:
	cmp.b vcount
	beq .vb							; wait for the next frame
	jsl.l ReadPads					; read the pads
	pla
	dec a							; one frame less
	pha
	bpl .wait						; until past zero
.exit:
	pla
	rtl
