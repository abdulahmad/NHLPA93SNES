VBlank_SprPal:						;Vblank: as VBlank, plus the sprite palettes; once, then back to vb2
	sep #$20						; 8-bit A
	lda.b #INIDISP_FBLANK			; forced blank
	sta.w INIDISP
	ldx.b DMAlistend				; last entry
	bra .next
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
	lda.w #DMA_OAM					; DMA to OAM
	sta.w DMAP7
	lda.w #Satt						; sprite table
	sta.w A1T7L
	lda.w #$0220					; $220 bytes
	sta.w DAS7L
	stz.w OAMADDL					; OAM address 0
	sep #$20
	lda.b #$00
	sta.w A1B7
	lda.b #MDMAEN_CH7				; go
	sta.w MDMAEN
	rep #$30						; 16-bit
	lda.w #DMA_CGRAM				; DMAP7=$00, BBAD7=$22 (CGDATA)
	sta.w DMAP7
	lda.w #(palbuffer+$140)&$FFFF	; color $A0
	sta.w A1T7L
	lda.w #$0040					; 32 colors
	sta.w DAS7L
	sep #$20
	lda.b #$A0						; sprite palettes 2-3
	sta.w CGADD
	lda.b #palbuffer>>16			; bank
	sta.w A1B7
	lda.b #MDMAEN_CH7				; go
	sta.w MDMAEN
	rep #$30
	lda.w #vb2						; back to vb2 next frame
	sta.b vbint
	jmp.w vb2
