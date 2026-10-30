orjoy:							;Read pads 1 and 2: d1 = the new presses of both
	jsl.l ReadJoy1					; pad 1 or pad 2
	lda.b d1						; presses of pad 1
	pha								; keep them
	jsl.l ReadJoy2					; read pad 2
	pla								; pad 1 presses back
	ora.b d1						; or both together
	sta.b d1
	rtl
