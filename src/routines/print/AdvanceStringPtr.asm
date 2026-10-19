AdvanceStringPtr:					;a1 = string d0 of the string list [a1]
	bra .cnt						; count first
.next:								; skip to the next string
	lda.b a1
	clc
	adc.b [a1]						; plus the string length: next string
	sta.b a1
.cnt:								; one less to skip
	dec.b d0						; one less to skip
	bpl .next						; more to skip
	rtl
