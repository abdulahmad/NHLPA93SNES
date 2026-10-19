appendz:							;appstring with the string following the call
	lda.b $03,s						; bank of the return address
	sta.b a1+2
	lda.b $01,s						; address after the call
	inc a
	sta.b a1						; a1 = the inline string
	lda.b [a1]
	clc								; string length
	adc.b $01,s
	sta.b $01,s						; skip over the string on return
	jml.l appstring
