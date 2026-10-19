remap:								;Copy tiles to video memory with each pixel color remapped through a table
	lda.w #$000E					; start at row 14 of the tile
	sta.b tmp2+1
.tile:								; next row pair
	rep #$30						; 16-bit registers
	ldy.b tmp2+1					; row offset
	lda.b [a0],y					; bitplanes 0-1
	sta.b tmp0
	tya
	clc								; bitplanes 2-3 are $10 bytes on
	adc.w #$0010
	tay
	lda.b [a0],y					; bitplanes 2-3
	sta.b tmp1
	sep #$30						; 8-bit registers
	ldx.b tmp2+1
	lda.b #$07						; 8 pixels
	sta.b tmp2
.pixel:								; next pixel
	ldy.b #$00						; color index
	asl.b tmp1+1					; bitplane 3
	bcc .bit3
	ldy.b #$08
.bit3:
	asl.b tmp1						; bitplane 2
	bcc .bit2
	iny
	iny
	iny
	iny
.bit2:
	asl.b tmp0+1					; bitplane 1
	bcc .bit1
	iny
	iny
.bit1:
	asl.b tmp0						; bitplane 0
	bcc .bit0
	iny
.bit0:
	lda.b [a1],y					; new color from the table at [a1]
	lsr a							; its bits into the output planes
	rol.b mula,x
	lsr a
	rol.b mula+1,x
	lsr a
	rol.b mula+16,x
	lsr a
	rol.b mula+17,x
	dec.b tmp2						; next pixel
	bpl .pixel
	dec.b tmp2+1					; next row pair
	dec.b tmp2+1
	bpl .tile
	rep #$30						; 16-bit registers
	ldx.w #$0000
.vram:								; copy the 16 words to video memory
	lda.b mula,x
	sta.w VMDATAL
	inx
	inx
	cpx.w #$0020
	bne .vram
	lda.b a0						; next tile
	clc
	adc.w #$0020
	sta.b a0
	dec.b d0						; tiles left
	bne remap						; loop
	rtl
