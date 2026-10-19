SetHor_rink:						;Clear the text screen, draw the horizontal rink scoreboard background,
									;then the scoreboard
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1,$00,$00)
	lda.w #$0020
	sta.b d0
	lda.w #$001D
	sta.b d1
	lda.w blankchar
	sta.b d2
	jsl.l eraser					; erase d0 x d1 with tile d2
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1,$00,$00)
	lda.w #$0418
	sta.w VMADDL
	lda.w #$001C
	sta.b tmp0
	ldx.w #$0000
.row:
	ldy.w #$0020
.col:
	lda.l HorRinkMap,x
	sta.w VMDATAL
	inx
	inx
	dey
	bne .col
	txa
	clc
	adc.w #$0020
	tax
	dec.b tmp0
	bne .row
	lda.w #$0800
	sta.w VMADDL
	lda.w #$001C
	sta.b tmp0
	ldx.w #$0000
.row2:
	ldy.w #$0020
.col2:
	lda.l HorRinkMap+$10,x
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
	jmp.w USBoard
