RemovePlayerFromList:				;Remove entry a0 from a penalty box list by moving the rest down
	lda.w #$FFFF					; d2 = -1
	sta.b d2
.loop:								; next entry
	inc.b d2						; next entry
	lda.b a0
	clc
	adc.b d2
	tay								; index
	sep #$20						; 8-bit A
	lda.w tmboxlist,y				; entry
	sta.w tmboxlist-1,y				; move it down
	rep #$30						; 16-bit registers
	bit.w #$0080					; end mark in bit 7
	beq .loop
	dec.b a0						; one entry less
	rtl
