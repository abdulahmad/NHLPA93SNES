VBlank_Cram:						;Vblank: run the transfer list, set the scroll and send the palette, then
									;switch to VBlank_CramOnly
	sep #$20						; 8-bit A
	lda.b #INIDISP_FBLANK			; forced blank
	sta.w INIDISP
	ldx.b DMAlistend				; last entry
	bra .next						; go
.dmaloop:
	ldy.w DMAList+dmavram,x			; video address
	sty.w VMADDL
	ldy.w DMAList+dmalen,x			; length
	sty.w DAS7L
	ldy.w #DMA_VRAMWORD				; word mode
	sty.w DMAP7
	ldy.w DMAList+dmasrc,x			; source
	sty.w A1T7L
	lda.w DMAList+dmabank,x			; bank
	sta.w A1B7
	lda.b #MDMAEN_CH7				; go
	sta.w MDMAEN
.next:								; next entry (7 bytes)
	dex
	dex
	dex
	dex
	dex
	dex
	dex
	bpl .dmaloop
	rep #$30						; 16-bit
	stz.b DMAlistend				; list empty
	sep #$20
	lda.w Hscroll					; scroll x
	and.b #$07						; low 3 bits
	sta.w BG1HOFS					; BG1HOFS = Hscroll&7
	stz.w BG1HOFS					; high byte 0
	stz.w BG1VOFS					; vertical scroll 0
	stz.w BG1VOFS
	rep #$30
	lda.w #DMA_CGRAM				; DMA to CGRAM
	sta.w DMAP7
	lda.w #palbuffer&$FFFF			; colors 0-127
	sta.w A1T7L
	lda.w #$0100					; $100 bytes
	sta.w DAS7L
	sep #$20
	stz.w CGADD						; CGRAM address 0
	lda.b #palbuffer>>16			; bank
	sta.w A1B7
	lda.b #MDMAEN_CH7				; go
	sta.w MDMAEN
	rep #$30
	lda.w #VBlank_CramOnly			; from now on: CGRAM every frame
	sta.b vbint
	ldx.w #$0012					; short delay
.wait:								;short delay before leaving the handler
	dex
	bne .wait
	jmp.w vb2						; finish the vblank
