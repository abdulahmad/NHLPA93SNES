PrintPerLabel:						;Print the label of the current period
	lda.w gsp						; period number
	sta.b d0
	lda.w #PerLabels				; label list
	sta.b a0
	lda.w #PerLabels>>16
	sta.b a0+2
.next:
	lda.b a0						; a1 = this label
	sta.b a1
	lda.b a0+2
	sta.b a1+2
	lda.b [a0]						; label length
	clc
	adc.b a0						; next label
	sta.b a0
	dec.b d0						; until the right one
	bpl .next
	jml.l print						; print it
