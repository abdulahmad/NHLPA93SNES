forceblack:							;Turn the screen black: default interrupt handlers, mark the sprite tile
									;caches stale and empty the transfer list
	phx								; keep X
	lda.w #vb2_blank				; blank vblank handler
	sta.b vbint
	lda.w #HBdefault				; default HBlank handler
	sta.b hbint
	lda.b vcount					; frame counter
	pha
	lda.b sprclock					; sprite clock
	sec
	sbc.w #$003C					; minus 60
	ldx.w #$0000					; clear the frame times
.frametime:							; stamp the sprite frame times as stale
	sta.l sprframetime,x
	inx								; stale
	inx
	cpx.w #$4C74					; $4C74 bytes
	bne .frametime
	ldx.w #$0000					; clear the slot times
.slottime:							; stamp the sprite slot times as stale
	sta.w sprslottime,x
	inx
	inx
	cpx.w #$0400					; $400 bytes
	bne .slottime
	pla
.vb:								; wait for the next frame
	cmp.b vcount
	beq .vb
	stz.b DMAlistend				; empty the DMA list
	plx								; restore X
	rtl
