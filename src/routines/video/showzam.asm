showzam:							;Draw the zamboni moving across the horizontal rink
	lda.b vcount					; frame counter
	ldy.b vcount+2
	cmp.b vcount					; stable
	bne showzam
	sbc.w vcountmark				; minus the mark: elapsed frames
	sta.b tmp0
	tya
	sbc.w vcountmark+2
	bne .rtl						; more than 255 frames: done
	lda.w sfhormode					; horizontal mode
	beq .rtl
	lda.b tmp0
	lsr a							; elapsed / 4
	lsr a
	sta.b sprx						; sprite x
	lda.w #$00C8					; sprite y = $C8
	sta.b spry
	lda.w #SPFzamboni				; zamboni sprite
	sta.b sprframe
	jsl.l addframe					; add it
.rtl:
	rtl
