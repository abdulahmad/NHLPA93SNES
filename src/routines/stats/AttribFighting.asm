AttribFighting:						;Roster column: fighting rating (the handedness bit is left out)
	lda.b d0
	and.w #$000E					; drop the handedness bit
	sta.b d0
	dec.b d1						; 15 ratings: d1 - 1
AttribRating:						;Sum d0 of d1/15 ratings as a percentage
	lda.w #$0064					; rating * 100
	sta.b mula
	lda.b d0
	sta.b mulb
	jsl.l mulu						; mulres = mula*mulb
	lda.b d1						; divided by the sum d1
	sta.b mula
	jsl.l divu
	sta.b d0						; percentage
AttribPrintPct:						;print d0 4 wide plus padding
	lda.w #$0004					; width 4
	sta.b d1
	jsl.l PushNumberWidth			; number to text
	jsl.l print						; print it
	jsl.l printz					; then a space
	%String("  ")
	rtl
