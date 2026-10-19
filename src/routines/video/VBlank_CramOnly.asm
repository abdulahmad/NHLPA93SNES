VBlank_CramOnly:					;Vblank: send the palette every frame
	sep #$20						; 8-bit A
	lda.b #INIDISP_FBLANK			; forced blank
	sta.w INIDISP
	rep #$30
	lda.w #DMA_CGRAM				; DMA to CGRAM
	sta.w DMAP7
	lda.w #palbuffer&$FFFF			; from palbuffer
	sta.w A1T7L
	lda.w #$0100					; $100 bytes
	sta.w DAS7L
	sep #$20
	stz.w CGADD						; CGRAM address 0
	lda.b #palbuffer>>16
	sta.w A1B7
	lda.b #MDMAEN_CH7
	sta.w MDMAEN					; go
	rep #$30
	jmp.w vb2						; then the common vblank end
