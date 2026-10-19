QueueBackmapDMA:					;Queue the background map for transfer to video memory
	ldy.b DMAlistend				; end of the DMA list
	lda.w #backmap					; source: backmap
	sta.w DMAList,y
	lda.w #backmap>>16				; bank
	sta.w DMAList+dmabank,y
	lda.w #$0800					; length $800
	sta.w DMAList+dmalen,y
	lda.w #$0400					; video address $400
	sta.w DMAList+dmavram,y
	tya								; list end advances by one entry
	clc
	adc.w #dmasize
	sta.b DMAlistend
	rtl
