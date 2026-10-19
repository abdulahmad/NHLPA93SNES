avdgoal:							;Do not skate through the goal: when the path to d0 / d1 crosses the net,
									;aim beside it instead
									;Called by skateto and skatetopuck: X = the player,
									;d0 / d1 = the target (in and out).
	stz.b tmp2						; tmp2 = 1 once a goal line has redirected the target
	lda.w #-258						; goal line at y -258 ($FEFE) and 258 ($102)
	jsl.l .ch1						; goal line at y = -258
	lda.w #258
	jsl.l .ch1						; goal line at y = +258
	lda.b tmp2
	bne .rtl						; target already redirected: done
	lda.w Xpos,x					; not crossing: is the player in front of a net?
	eor.b d0						; against the target's x
	bpl .rtl						; same side of the center line: leave the target alone
	lda.w Ypos,x					; player's y
	sec								; distance to the +258 goal line
	sbc.w #258
	bit.w #$8000
	beq .b
	eor.w #$FFFF					; negate
	inc a
.b:
	cmp.w #32
	bcc .x							; within 32 of the +258 line: aim at the center
	lda.w Ypos,x					; player's y
	sec
	sbc.w #-258						; distance to the -258 goal line
	bit.w #$8000
	beq .c
	eor.w #$FFFF					; negate
	inc a
.c:
	cmp.w #32
	bcs .rtl						; further than 32 from both lines: leave the target
.x:
	stz.b d1						; aim along the center line (y = 0)
	rtl
.ch1:								;goal line A: crossed within 40 of the net: d1 = line, d0 = +-60 by Xvel,
									;tmp2 = 1
	sta.b tmp0						; tmp0 = the goal line, A = its y
	lda.b d1
	sec
	sbc.b tmp0						; tmp1 = target y - line
	sta.b tmp1
	lda.w Ypos,x
	sec								; player y - line
	sbc.b tmp0
	eor.b tmp1						; different signs: the straight path crosses the line
	bpl .rtl						; same side: no crossing
	lda.w Xpos,x					; player's x
	bit.w #$8000
	beq .ax
	eor.w #$FFFF					; negate
	inc a
.ax:								; |x| computed
	cmp.w #40						; more than 40 from the center: the path passes the net
	bcs .rtl
	inc.b tmp2						; a line was crossed
	lda.b tmp0						; aim at the goal line
	sta.b d1
	lda.w #60						; aim 60 to the side of the net: right
	sta.b d0
	lda.w Xvel,x					; player's x velocity
	bpl .rtl						; moving right: keep +60
	lda.w #-60						; moving left: aim left
	sta.b d0
.rtl:								; return
	rtl
unused008D:							;unused, zero fill to the end of the bank
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
