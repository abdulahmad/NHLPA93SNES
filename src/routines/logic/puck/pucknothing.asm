pucknothing:						;Assignment: the puck just slides and stops spinning
	lda.w SPAnum+puckobj			; current puck animation
	cmp.w #$0008					; SPAnum 2*4..6*4: flip the face
	bcc .k							; before the spin frames: skip
	cmp.w #$0018
	bcs .k							; after them: skip
	lda.w facedir+puckobj
	eor.w #$0002					; turn the puck face around
	sta.w facedir+puckobj
.k:									; before the spin frames: set the facedir bit
	lda.w #$0004					; facedir |= 4
	tsb.w facedir+puckobj			; set the facedir bit
	stz.w SPAnum+puckobj			; SPAnum = 0, SPAcnt = -1 (restart)
	lda.w #$FFFF
	sta.w SPAcnt+puckobj
	rtl
