vb2:								;Vblank for palette fades only: set the brightness, no transfers
	sep #$20						; 8-bit A
	lda.b brightness				; brightness
	sta.w INIDISP					; to the screen
vb2_main:							;common vblank tail: Vcount, sound tick (p_music_vblank), brightness fades
									;(cramfade), rti
	rep #$30						; 16-bit registers
	inc.b Vcount					; frame counter
	bne .tick						; carry into the high word
	inc.b Vcount+2
.tick:								; sound tick
	jsl.l p_music_vblank			; sound tick
	stz.b hcount					; clear the IRQ count every frame
	lda.b fadeout					; fading out
	beq .fadein						; no
	lda.b brightness				; brightness
	beq .fadeoutdone				; zero: done
	lda.b Vcount					; frame
	bit.w #$0003					; every 4th frame
	bne .fadein						; not this frame
	dec.b brightness				; darker
	bra .fadein
.fadeoutdone:						; fade out done
	stz.b fadeout					; done
.fadein:							; 1 = fading in, >1 = delay first
	lda.b fadein					; fading in
	beq .exit						; no
	cmp.w #$0001					; 1 = fading in, >1 = delay first
	bne .fadeindelay				; delay first
	lda.b brightness				; brightness
	cmp.w #$000F					; full brightness
	beq .fadeindone					; full: done
	lda.b Vcount					; frame
	bit.w #$0003
	bne .exit						; not this frame
	inc.b brightness				; brighter
	bra .exit
.fadeindelay:						; count down the delay
	dec.b fadein					; count down the delay
	bra .exit
.fadeindone:						; fade in done
	stz.b fadein					; done
.exit:								; restore the registers
	ply								; restore the registers
	plx
	pla
	stz.b vbactive					; vblank done
	rti
