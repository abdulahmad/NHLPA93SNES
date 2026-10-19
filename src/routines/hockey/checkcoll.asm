checkcoll:							;Move object X to its new x / y (d2 / d3), checking wall and player
									;collisions and keeping the objects sorted
	stz.b collflag					; collflag = 0
	lda.w sfhormode					; horizontal: exg d2,d3
	beq .nhor1						; collisions flag clear
	lda.b d2
	ldy.b d3						; d3 into d2
	sta.b d3
	sty.b d2
.nhor1:
	lda.w pfnc,x					; pfnc: no collision
	beq .go
	jmp.w .ex
.go:								;movem d0-d6
	lda.b d6+2
	pha
	lda.b d6
	pha
	lda.b d5+2
	pha
	lda.b d5
	pha
	lda.b d4+2
	pha
	lda.b d4
	pha
	lda.b d3+2
	pha
	lda.b d3
	pha
	lda.b d2+2
	pha
	lda.b d2
	pha
	lda.b d1+2
	pha
	lda.b d1
	pha
	lda.b d0+2
	pha
	lda.b d0
	pha
	lda.w Xpos,x					; around the hot spot with the wall
	sta.b d2
	lda.w Ypos,x					; y of X
	sta.b d3
	lda.w radiusx,x					; object radius in x
	sta.w wcradiusx
	lda.w radiusy,x					; object radius in y
	sta.w wcradiusy
	jsl.l checkwallcoll				; check the wall at the hot spot
	lda.w Wallcos,x					; wall hit: done
	ora.w Wallsin,x
	bne .xx							; wall hit: skip the stick
	cpx.w #$0018					; only players: the end of the stick
	bcs .xx							; only players have a stick end
	lda.b $01,s						; restore d0-d6 from the stack
	sta.b d0
	lda.b $03,s
	sta.b d0+2
	lda.b $05,s
	sta.b d1
	lda.b $07,s
	sta.b d1+2
	lda.b $09,s
	sta.b d2
	lda.b $0B,s
	sta.b d2+2
	lda.b $0D,s
	sta.b d3
	lda.b $0F,s
	sta.b d3+2
	lda.b $11,s
	sta.b d4
	lda.b $13,s
	sta.b d4+2
	lda.b $15,s
	sta.b d5
	lda.b $17,s
	sta.b d5+2
	lda.b $19,s
	sta.b d6
	lda.b $1B,s
	sta.b d6+2
	txa								; player number
	jsl.l GetHot					; GetHot
	lda.w Xpos,x					; x of the hot spot
	clc
	adc.b d0
	sta.b d2
	lda.w Ypos,x					; y of the hot spot
	clc
	adc.b d1
	sta.b d3
	lda.w #$0001					; radius 1
	sta.w wcradiusx
	sta.w wcradiusy
	jsl.l checkwallcoll				; check the wall at the stick end
.xx:
	pla								; pull d0-d6 back
	sta.b d0
	pla
	sta.b d0+2
	pla
	sta.b d1
	pla
	sta.b d1+2
	pla
	sta.b d2
	pla
	sta.b d2+2
	pla
	sta.b d3
	pla
	sta.b d3+2
	pla
	sta.b d4
	pla
	sta.b d4+2
	pla
	sta.b d5
	pla
	sta.b d5+2
	pla
	sta.b d6
	pla
	sta.b d6+2
	jsl.l checkplcoll				; checkplcoll
.ex:
	lda.b collflag					; collflag: restore the old position
	beq .sort						; no collision: sort
	jmp.w .restoreold
.sort:
	lda.w OOlistpos,x				; move up/down OOlist by y
	sta.b d1
.2:
	ldy.b d1
	cpy.w #$000F					; top of the list?
	beq .cl2
	lda.w OOlist+1,y				; object above
	and.w #$00FF
	sta.b d4
	tay
	lda.b d3						; new y
	sec
	sbc.w Ylist,y					; minus the y of the object above
	beq .cl2
	bmi .neg
	bvc .swapup						; X is lower: swap up
	bra .cl2
.neg:
	bvc .cl2
.swapup:
	inc.w OOlistpos,x				; move X up the list
	lda.w OOlistpos,y				; and the other down
	dec a
	sta.w OOlistpos,y
	sep #$30						; 8-bit registers
	ldy.b d1
	lda.b d4
	sta.w OOlist,y
	txa
	sta.w OOlist+1,y
	rep #$30						; 16-bit registers
	inc.b d1						; next position
	bra .2
.cl2:
	lda.w OOlistpos,x				; X's position in the sorted list
	beq .ex2						; at the bottom: done
	sta.b d1
.3:
	ldy.b d1
	lda.w OOlist-1,y				; object below
	and.w #$00FF
	sta.b d4
	tay
	lda.b d3						; new y
	sec
	sbc.w Ylist,y					; minus the y of the object below
	bmi .neg1
	bvs .swapdn						; X is higher: swap down
	bra .ex2
.neg1:
	bvs .ex2
.swapdn:
	dec.w OOlistpos,x				; move X down the list
	lda.w OOlistpos,y				; and the other up
	inc a
	sta.w OOlistpos,y
	sep #$30						; 8-bit registers
	ldy.b d1
	lda.b d4
	sta.w OOlist,y
	txa
	sta.w OOlist-1,y
	rep #$30						; 16-bit registers
	dec.b d1						; previous position
	bne .3
.ex2:
	lda.b d3						; new y
	sta.w Ylist,x					; store it
	rtl
.restoreold:
	lda.w OldXpos,x					; restore the old x
	sta.w Xpos,x
	lda.w OldYpos,x					; restore the old y
	sta.w Ypos,x
	rtl
