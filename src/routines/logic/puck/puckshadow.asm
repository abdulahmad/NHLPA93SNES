puckshadow:							;Assignment: the puck shadow follows the puck
	lda.w frame,x					; frame
	cmp.w #SPFpuck					; puck frame: shadow under the puck
	bne .none						; not the puck
	lda.w puckx						; puck x
	sta.w Xpos,x
	lda.w pucky						; puck y
	sta.w Ypos,x
	stz.w Zpos,x					; on the ice
	lda.w sfhormode					; horizontal mode
	beq .nhor
	inc.w Xpos,x					; x + 1
	rtl
.nhor:								; shadow is drawn 1 unit off the puck
	inc.w Ypos,x					; y + 1
	rtl
.none:								; nothing to show
	tay								; frame 0
	beq .rtl						; nothing to show
	stz.w Xpos,x					; x = 0
	lda.w #300						; behind the goal
	sta.w Ypos,x					; y
	lda.w #14						; z
	sta.w Zpos,x
	lda.w pucky						; puck y
	bpl .rtl						; top half
	lda.w #$8000					; upside down
	sta.w attribute,x
	lda.w #-300						; y
	sta.w Ypos,x
	dec.w Zpos,x					; z
.rtl:								; return
	rtl
