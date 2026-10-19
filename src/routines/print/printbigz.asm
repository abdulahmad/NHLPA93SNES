printbigz:							;printbig with the string following the call
	lda.b $03,s						; farptr-style: a1 = the inline string after the caller
	sta.b a1+2						; bank of the return address
	lda.b $01,s
	inc a							; address after the call
	sta.b a1
	lda.b [a1]						; string length
	clc
	adc.b $01,s						; skip over the string on return
	sta.b $01,s
	jml.l printbig					; print the inline string
