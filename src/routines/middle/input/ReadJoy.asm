ReadJoy:							;Read one pad: d1 = buttons held, d0 = its direction
	lda.w PadRaw1,x					; buttons
	sta.b d0+2
	sta.b d1						; buttons held
	xba								; r/l/d/u bits
	and.w #$000F					; direction bits
	tax
	lda.l jdtab,x					; bits to direction number
	and.w #$00FF
	sta.b d0
	rtl
