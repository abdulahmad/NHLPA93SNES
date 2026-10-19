HBdefault:							;Default horizontal blank handler: count the line and return
	rep #$30						; 16-bit registers
	inc.b hcount					; count the line
	ply								; restore the registers
	plx
	pla
	rti
