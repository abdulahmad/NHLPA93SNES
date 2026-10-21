SetHor_rink:						;Clear the text screen, draw the horizontal rink scoreboard background,
									;then the scoreboard
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1,$00,$00)
	lda.w #$0020					; erase 32 x 29
	sta.b d0
	lda.w #$001D
	sta.b d1
	lda.w blankchar					; blank tile
	sta.b d2
	jsl.l eraser					; erase d0 x d1 with tile d2
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1,$00,$00)
	lda.w #$0418					; VRAM address $0418
	sta.w VMADDL
	lda.w #$001C					; 28 rows
	sta.b tmp0
	ldx.w #$0000					; map offset 0
.row:								; 32 words per row
	ldy.w #$0020					; 32 words per row
.col:								; rink map word
	lda.l HorRinkMap,x				; rink map word
	sta.w VMDATAL
	inx
	inx
	dey
	bne .col
	txa								; skip to the next map row
	clc
	adc.w #$0020
	tax
	dec.b tmp0
	bne .row
	lda.w #$0800					; second map at VRAM $0800
	sta.w VMADDL
	lda.w #$001C					; 28 rows
	sta.b tmp0
	ldx.w #$0000					; map offset 0
.row2:								; second half of the rink map
	ldy.w #$0020
.col2:								; rink map words from + $10
	lda.l HorRinkMap+(8*2),x		; rink map words from column 8
	sta.w VMDATAL
	inx
	inx
	dey
	bne .col2
	txa
	clc
	adc.w #$0020
	tax
	dec.b tmp0
	bne .row2
	jmp.w USBoard					; draw the scoreboard
