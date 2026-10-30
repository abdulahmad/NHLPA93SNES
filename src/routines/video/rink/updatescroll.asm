updatescroll:							;Set the rink scroll from the camera position
	lda.w sfhormode
	bne .rtl						; horizontal mode has its own scroll
	lda.w Hpos						; camera x
	sec
	sbc.w #$0080					; minus half the screen: scroll x
	sta.w Hscroll
	lda.w Vpos						; camera y
	eor.w #$FFFF					; negate
	inc a
	sec
	sbc.w #$0070					; minus $70: scroll y
	sta.w Vscroll
.rtl:								; return
	rtl
