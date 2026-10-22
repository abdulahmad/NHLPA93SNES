Fprint:								;Print string d0 of the string list [a1]
	lda.b d0
	bne .step						; not the first: skip one
	jml.l print						; print this string
.step:								; next string
	lda.b [a1]
	clc
	adc.b a1						; next string
	sta.b a1
	dec.b d0
	bra Fprint
