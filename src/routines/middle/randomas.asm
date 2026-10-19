randomas:							;A = a random number from -A to A-1
	sta.b tmp0						; keep A
	asl a							; times 2
	jsl.l randoma					; random 0 to 2A-1
	sec
	sbc.b tmp0						; minus A: -A to A-1
	clc
	rtl
