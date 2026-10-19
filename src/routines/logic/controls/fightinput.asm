fightinput:							;Pad input in a fight: move and punch
	lda.w temp3,x					; punch timer
	ora.w Pencntdwn					; or the penalty countdown
	bpl .go							; neither running
	jmp.w .rtl						; else leave
.go:
	lda.w SPA,x						; animation
	cmp.w #SPAfight					; already fighting
	bne .input						; no
	jmp.w .rtl						; leave
.input:
	lda.b d1						; keep the presses
	pha
;skate with the dpad (unless no direction) while fighting
	lda.b d0						; pad direction
	sta.b d2
	bit.w #$0008					; no direction
	bne .noa						; set
	and.w #$0007					; 0-7
	sta.b d2
	jsl.l playeracc					; skate that way
.noa:
;keep the fighter face to face and near the fight scroll x (xc1): brake Xvel when it points away
	lda.w xc1						; view x
	clc
	adc.w #$000C					; plus 12
	sta.b d0
	lda.w facedir,x					; facing
	cmp.w #$0002					; right
	bne .0
	lda.b d0						; left: minus 24
	sec
	sbc.w #$0018
	sta.b d0
.0:									; distance to the opponent
	lda.b d0
	sec
	sbc.w Xpos,x					; minus the player x
	sta.b d0
	lda.w Xvel,x					; x speed
	eor.b d0						; against the target
	sta.b d1
	bpl .ind						; same direction
	lda.b d0
	bit.w #$8000					; negative
	beq .1
	eor.w #$FFFF					; absolute value
	inc a
.1:									; use the X speed
	sta.b d0
	lda.w Xvel,x					; x speed
	sta.b mula
	lda.b d0						; distance
	sta.b mulb
	jsl.l muls32					; signed multiply
	lda.w #$0006					; divided by 6
	sta.b mula
	jsl.l divs						; signed divide
	sta.b d0
	lda.w Xvel,x					; x speed
	sec
	sbc.b d0						; minus it
	sta.w Xvel,x
.ind:
	pla								; presses back
	sta.b d1
	lda.w pf2aip,x					; already punching
	bne .rtl
	lda.b d1						; presses
	sta.b d2
	lda.w #SPAfhigh					; high punch
	sta.b d1
	sta.w pf2aip,x					; animation flag
	lda.b d2
	bit.w #$0080					; button
	beq .p2
	jml.l SetSPA					; start it
.p2:
	lda.w #SPAflow					; low punch
	sta.b d1
	lda.b d2
	bit.w #$8000					; button
	beq .p3
	jml.l SetSPA					; start it
.p3:
	lda.w #SPAfgrab					; grab
	sta.b d1
	lda.b d2
	bit.w #$4000					; button
	beq .nopunch
	jml.l SetSPA					; start it
.nopunch:
	stz.w pf2aip,x					; no punch
.rtl:								; return
	rtl
