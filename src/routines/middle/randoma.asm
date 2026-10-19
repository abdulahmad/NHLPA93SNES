randoma:							;A = a random number from 0 to A-1
	pha								; keep the limit
	jsl.l random					; random 16-bit number
	sta.b mula
	pla								; limit
	sta.b mulb
	jsl.l mulu						; mulres = mula*mulb
	lda.b mulres+2					; high word = the result
	clc
	rtl
