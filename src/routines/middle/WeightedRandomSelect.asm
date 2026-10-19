WeightedRandomSelect:				;d0 = a random index from 0 to d0-1, weighted by the words at nibblebuffer
	lda.b d1+2						; keep d1
	pha
	lda.b d1
	pha
	lda.b a1+2						; keep a1
	pha
	lda.b a1
	pha
	lda.w #nibblebuffer				; weights
	sta.b a1
	lda.w #$0000
	sta.b a1+2
	stz.b d1						; sum = 0
	bra .next						; go
.sum:
	lda.b d1						; sum
	clc
	adc.b [a1]						; plus the weight
	sta.b d1
	inc.b a1						; next weight
	inc.b a1
.next:
	dec.b d0						; count down
	bpl .sum
	lda.b d1						; sum
	sta.b d0						; random limit
	jsl.l randomd0					; 0 to sum-1
.find:
	dec.b a1						; back one weight
	dec.b a1
	lda.b d0						; random
	sec
	sbc.b [a1]						; minus the weight
	sta.b d0
	bpl .find						; until below zero
	lda.b a1						; index
	sec
	sbc.w #nibblebuffer				; minus the buffer
	lsr a							; words to index
	sta.b d0
	pla								; restore the registers
	sta.b a1
	pla
	sta.b a1+2
	pla
	sta.b d1
	pla
	sta.b d1+2
	rtl
