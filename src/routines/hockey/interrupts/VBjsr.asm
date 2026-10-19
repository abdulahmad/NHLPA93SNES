VBjsr:								;NMI: jump through the vblank handler vector
	rep #$30						; 16-bit registers
	pha								; save A
	lda.w RDNMI						; NMI flag
	bit.w #$0080					; vblank bit
	beq .rti						; not a vblank NMI
	lda.b vbactive
	beq .dispatch					; previous handler finished
.rti:								;not a vblank NMI, or the last handler still runs
	pla
	rti
.dispatch:							;push vbint-1 and rts into it (A/X/Y stay on the stack for the handler to
									;pull)
	inc.b vbactive					; mark the handler as running
	phx								; save X and Y
	phy
	lda.b vbint						; handler address
	dec a							; minus 1 for the rts
	pha
	rts								; jump to the handler
