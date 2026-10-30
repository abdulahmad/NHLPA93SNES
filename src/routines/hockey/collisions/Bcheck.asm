Bcheck:								;Player a2 body checks a3: a3 falls if he is in front, and a charging
									;penalty may be called on a2
	ldy.b a2						; y = the checker
	lda.w pfalock,x					; animation locked?
	beq .pos
	jmp.w .rtl
.pos:								; position of X: goalies can't be checked
	lda.w position,x				; position
	bne .fight						; goalies can't be checked
	jmp.w .rtl
.fight:								; fighting? then the penalties option
	lda.w pf2fight,x				; fighting?
	bne .rtl
	lda.w OptPen					; penalties off: a2 needs randomd0($10 + checking - a3 legstr) >= 12
	bne .dir
	lda.w pflags,y
	bit.w #pfjoycon
	beq .dir
	lda.w #16
	clc
	adc.w checking,y
	sec
	sbc.w legstr,x
	jsl.l randomd0A					; random number 0 to A-1
	cmp.w #12
	bcc .rtl
.dir:								; direction test: x of X minus the checker's x
	lda.w Xpos,x					; x of X
	sec
	sbc.w Xpos,y					; minus the checker's x
	sta.b d0
	lda.w Ypos,x					; y of X
	sec
	sbc.w Ypos,y					; minus the checker's y
	sta.b d1
	jsl.l vtoa						; vector to direction
	ldy.b a2						; checker
	lda.b d0						; within one direction of a2 facing
	sec
	sbc.w facedir,y
	inc a
	and.w #$0007
	cmp.w #$0003
	bcs .rtl
	ldx.b a2						; swap a2 and a3
	ldy.b a3
	stx.b a3
	sty.b a2
	jsl.l FallDown					; a3 falls
	jsl.l checkagr					; aggression check
	lda.b d0
	cmp.w #$0005					; aggression under 5?
	bcs .swap
	lda.w #PenTripping				; penalty $20
	sta.b d0
	jsl.l AddPenalty				; call it
.swap:								; swap X and the checker back
	ldx.b a2						; swap back
	ldy.b a3
	stx.b a3
	sty.b a2
	lda.w #$FFFF					; set collflag
	sta.b collflag
.rtl:								; return
	rtl
