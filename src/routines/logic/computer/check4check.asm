check4check:						;Look for a good chance to check an opponent
	lda.w #$0014					; $14
	sec
	sbc.w checking,x				; minus the checking rating
	sta.b d0
	lda.w OptPen					; penalties on: half the chance
	beq .nopen
	asl.b d0						; double it
.nopen:								; 0 <= d0 < ($14 - checking) [*2]
	lda.b d0						; random 0 to d0
	jsl.l randoma					; random number 0 to A-1
	cmp.w #$0004					; under 4: check
	bcc .go
	lda.b d0
	jsl.l randoma					; random number 0 to A-1
	cmp.w #$0004
	bcs .rts						; 4 or more: no check
.go:								; 6 opponents
	lda.w #$0005					; 6 opponents
	sta.b d2
	stz.b a0						; first opponent
	cpx.w #$000C					; which team
	bcs .0
	lda.w #$000C
	sta.b a0
.0:									;each opponent within 30 pixels in the facing direction
	ldy.b a0						; opponent
	lda.w position,y				; position
	beq .next
	lda.w pfalock,y					; animation locked?
	bne .next
	lda.w pf2fight,y				; fighting?
	bne .next
	lda.w Xpos,y					; x distance
	sec
	sbc.w Xpos,x
	sta.b d0
	bit.w #$8000					; absolute value
	beq .dx
	eor.w #$FFFF					; negate
	inc a
.dx:								; within 30 in x?
	cmp.w #$001F					; within 30?
	bcs .next
	lda.w Ypos,y					; y distance
	sec
	sbc.w Ypos,x
	sta.b d1
	bit.w #$8000					; absolute value
	beq .dy
	eor.w #$FFFF					; negate
	inc a
.dy:								; within 30 in y: vector to direction
	cmp.w #$001F					; within 30?
	bcs .next
	jsl.l vtoa						; vector to direction
	lda.b d0
	cmp.w facedir,x					; opponent in the facing direction
	bne .next
	lda.w seed+3					; random: 1 in 4 hold, else check
	and.w #$0003
	sta.b d0
	bne burst						; burst
	jml.l Acheck					; check
.next:								; next opponent
	inc.b a0						; next opponent
	inc.b a0
	dec.b d2						; opponents left
	bpl .0
.rts:								; return
	rtl
