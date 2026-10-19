ReadJoy2:							;Read pad 2: d0 = direction, d1 = new presses, d2 = changed buttons, d3 =
									;buttons held
	phx								; keep X
	ldx.w #$0002					; X = pad 2
	jsl.l ReadJoy					; d0 = direction, d1 = buttons held
	plx								; restore X
	lda.w lj2						; last held buttons
	sta.b d2
	lda.b d1
	sta.w lj2
	sta.b d3
	eor.b d2						; changed
	sta.b d2
	and.b d1						; new presses = changed and held
	sta.b d1
	rtl
