HBjsr:								;IRQ vector: jump through hbint when the timer fired
	rep #$30						; save the registers
	pha
	phx
	phy
	sep #$20						; 8-bit A
	lda.w TIMEUP
	bpl HBdefault					; not a timer IRQ
	rep #$30						; 16-bit again
	lda.b hbint						; handler address
	dec a							; minus 1 for the rts
	pha								; jump to it
	rts
