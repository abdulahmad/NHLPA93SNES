VBlank_VScroll:						;Vblank: set the vertical scroll and run the transfer list; once, then
									;back to vb2
	sep #$20						; 8-bit A
	lda.b #INIDISP_FBLANK			; forced blank
	sta.w INIDISP
	lda.b d0						; BG1VOFS = d0 (low, high)
	sta.w BG1VOFS
	lda.b d0+1
	sta.w BG1VOFS
	ldx.b DMAlistend				; last entry
	bra .next						; go
.dmaloop:							; DMA to VRAM, next list entry
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
	lda.w #vb2						; back to vb2
	sta.b VBint
	jmp.w vb2						; finish the vblank
