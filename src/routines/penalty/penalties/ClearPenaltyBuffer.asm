ClearPenaltyBuffer:					;Clear the list of called penalties
	lda.w #$001F					; 32 words
	sta.b d0
	lda.w #PenBuf					; PenBuf
	sta.b a0
	lda.w #$0000
	sta.b a0+2
.loop:								; clear a word
	lda.w #$0000
	sta.b [a0]
	inc.b a0						; next word
	inc.b a0
	dec.b d0						; count down
	bpl .loop
	rtl
