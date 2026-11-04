setplayercolors_sp:					;Convert one team's colors into the palette buffer
									;(93G setplayercolors .sp)
	ldy.w #$0002					; team data + word at +2: palette
	lda.b [tmp0],y					; palette offset
	clc
	adc.b tmp2+1					; plus the team slot
	tay
	lda.w #$0010					; 16 colors
	sta.b tmp2+1
.col:								;0BGR (4 bits) -> 0BBBBBGGGGGRRRRR
	lda.b [tmp0],y
	xba								; swap bytes
	and.w #$000F					; red
	asl a							; times 2
	sta.b tmp1+1
	lda.b [tmp0],y
	xba								; green
	and.w #$00F0
	asl a							; to bits 5-9
	asl a
	ora.b tmp1+1
	sta.b tmp1+1
	lda.b [tmp0],y
	xba
	and.w #$0F00					; blue
	asl a
	asl a
	asl a							; to bits 10-14
	ora.b tmp1+1
	sta.l palbuffer+(2*$20),x		; team slot in the palette buffer
	sta.l palbuffer+(10*$20),x		; second copy
	inx
	inx
	iny
	iny
	dec.b tmp2+1					; next color
	bne .col						; until 16
	rtl
