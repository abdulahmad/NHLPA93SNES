ShowRinkRows:						;Queue the rink map rows that the vertical scroll brought on screen
	ldy.b DMAlistend				; end of the DMA list
	lda.w Vscroll					; vertical scroll
	clc
	adc.w #$0170					; plus $170
	lsr a
	lsr a
	lsr a							; /8: rink row
	tax								; X = row
	sec
	sbc.w Oldrow					; minus the old row
	bne .moved						; unchanged
	jmp.w .done						; nothing to do
.moved:
	bpl .down						; moved down
	stx.w Oldrow					; new old row
	eor.w #$FFFF					; negate: rows moved up
	inc a
	cmp.w #$0019					; more than 24 rows
	bcs .redraw						; redraw all
	sta.b tmp1						; rows to draw
	lda.w vramrow					; video row
	sec
	sbc.b tmp1						; minus the rows
	and.w #$001F					; wrap at 32
	sta.w vramrow					; store
	sta.b tmp2
	bra .rows
.redraw:							; redraw
	lda.w #$001D					; 30 rows
	sta.b tmp1
	stz.w vramrow					; from video row 0
	stz.b tmp2
	bra .rows
.down:								; rows moved down
	stx.w Oldrow					; new old row
	cmp.w #$0019					; more than 24 rows
	bcs .redraw
	sta.b tmp1						; rows to draw
	adc.w vramrow					; video row
	and.w #$001F					; wrap at 32
	sta.w vramrow
	adc.w #$001D
	sec
	sbc.b tmp1
	and.w #$001F
	sta.b tmp2						; first video row to fill
	txa
	clc
	adc.w #$001D
	sec
	sbc.b tmp1
	tax								; map row
.rows:
	txa								; map row
	asl a
	asl a
	asl a
	asl a
	asl a							; times 32
	sta.b tmp0
	asl a							; times 3
	adc.b tmp0
	adc.w #IceRinkMap				; rink map
	sta.b tmp0
	lda.b tmp2						; video row
	asl a
	asl a
	asl a
	asl a
	asl a							; times 32
	adc.w #$0400					; plus $400
	sta.b tmp2
	ldx.b tmp1						; row count
.rowloop:							; per row: two DMA entries
	lda.w #IceRinkMap>>16
	sta.w DMAList+dmabank,y			; bank
	sta.w DMAList+dmasize+dmabank,y
	lda.b tmp2
	sta.w DMAList+dmavram,y			; video address
	clc
	adc.w #$0400					; second half
	sta.w DMAList+dmasize+dmavram,y
	sec
	sbc.w #$03E0
	cmp.w #$0800					; wrap at $800
	bne .nowrap
	lda.w #$0400					; back to $400
.nowrap:
	sta.b tmp2
	lda.b tmp0						; map source
	sta.w DMAList,y
	clc
	adc.w #$0040
	sta.w DMAList+dmasize+dmasrc,y	; second half source
	adc.w #$0020
	sta.b tmp0
	lda.w #$0040					; $40 bytes
	sta.w DMAList+dmalen,y
	lsr a
	sta.w DMAList+dmasize+dmalen,y	; half of it
	tya
	adc.w #$000E					; next entry pair
	tay
	dex								; next row
	bne .rowloop
.done:
	sty.b DMAlistend				; new list end
	rtl
