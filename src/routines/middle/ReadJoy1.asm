ReadJoy1:							;Read pad 1: d0 = direction, d1 = new presses, d2 = changed buttons, d3 =
									;buttons held
	phx								; keep X
	ldx.w #$0000					; X = pad 1
	jsl.l ReadJoy					; d0 = direction, d1 = buttons held
	plx								; restore X
	lda.w lj1						; d2 = changed, d3 = held, d1 = new presses
	sta.b d2
	lda.b d1
	sta.w lj1
	sta.b d3
	eor.b d2
	sta.b d2
	and.b d1						; new presses = changed and held
	sta.b d1
	rtl
