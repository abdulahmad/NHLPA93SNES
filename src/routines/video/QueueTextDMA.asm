QueueTextDMA:						;Queue the changed part of the text map for transfer to video memory
	lda.b textdirtylo				; first dirty entry
	bmi .rtl						; none: leave
	ldy.b DMAlistend				; end of the DMA list
	sta.w DMAList+dmavram,y			; video address
	asl a							; word index to bytes
	adc.w #textmap					; plus the text map
	sta.w DMAList,y
	lda.w #textmap>>16				; bank
	sta.w DMAList+dmabank,y
	lda.b textdirtyhi				; last dirty entry
	beq .rtl						; none
	sec
	sbc.b textdirtylo				; minus the first
	inc a							; count
	asl a							; bytes
	sta.w DMAList+dmalen,y
	lda.w #$FFFF					; mark clean
	sta.b textdirtylo
	stz.b textdirtyhi
	tya								; list end advances by one entry
	clc
	adc.w #dmasize
	sta.b DMAlistend
.rtl:
	rtl
