sfx:								;Play the sound effect number pushed before the call, unless sound effects
									;are muted for now
	pla								; return address +1 into jmlvector
	inc a
	sta.w jmlvector+1				; return address in the jump vector
	sep #$20						; 8-bit A
	pla								; bank of the return address
	sta.w jmlvector+3				; stored too
	rep #$20						; 16-bit A
	lda.b vcount					; sound effects muted?
	sec
	sbc.w sfxmutetime
	cmp.w #$00B4					; muted for 180 frames
	bcc .drop						; muted: drop it
	pla								; lastsfx = sound number
	sta.w lastsfx					; remember the sound
	beq .ret						; no sound: skip
	jsl.l QueueSound				; queue it
.ret:								;return through jmlvector
	jml.l jmlvector
.drop:								; muted: drop the sound
	pla								; drop the pushed sound
	bra .ret
