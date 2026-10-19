SprSort:							;Sort the objects by screen position for drawing
	phx								; save X and Y
	phy
	stx.b xsave						; keep X
	ldx.w #$0000					; start at object 0
.save:								; save d0 and the words after it (6 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$000C
	bne .save
	ldx.b xsave						; restore X
	ldx.w #$0000					; first object
	lda.w sfhormode					; horizontal mode sorts by x
	bne .xlist
.loop0:								; sort by y: copy Ypos into Ylist
	lda.w Ypos,x					; y of the object
	sta.w Ylist,x
	inx
	inx
	cpx.w #$0020
	bne .loop0
	bra .loop						; sorted list ready
.xlist:
	lda.w Xpos,x					; sort by x: copy Xpos into Ylist
	sta.w Ylist,x					; x of the object
	inx
	inx
	cpx.w #$0020
	bne .xlist
.loop:
	stz.b d2						; swap count
	ldx.w #$0000					; list position
.0:
	lda.w OOlist+1,x				; object above
	and.w #$00FF
	sta.b d1
	lda.w OOlist,x					; object below
	and.w #$00FF
	sta.b d0
	tay
	lda.w Ylist,y					; y of the lower one
	ldy.b d1
	sec
	sbc.w Ylist,y					; minus y of the upper one
	beq .1							; in order: next
	bmi .neg
	bvc .swap
	bra .1
.neg:
	bvc .1
.swap:
	lda.w OOlist,x					; swap the two list entries
	xba
	sta.w OOlist,x
	txa
	sta.w OOlistpos,y				; new position of the upper one
	inc a
	ldy.b d0
	sta.w OOlistpos,y				; new position of the lower one
	inc.b d2						; count the swap
.1:
	inx								; next pair
	cpx.w #$000F					; 15 pairs
	bne .0
	lda.b d2						; swapped: sort again
	bne .loop						; swapped: sort again
	stx.b xsave						; keep X
	ldx.w #$000A
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	ply								; restore Y and X
	plx
	rtl
