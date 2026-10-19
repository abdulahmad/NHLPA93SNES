shotdiradj:							;Aim a computer shot at the open side when the goalie covers the middle of
									;the net
	lda.w pflags,x					; joystick player: skip
	bit.w #pfjoycon
	beq .go
	jmp.w .rtl
.go:
	lda.w #$0008					; default: no direction (8)
	sta.b d0
	lda.w #$0005					; search 6 players
	sta.b d1
	lda.w #$FFFE					; first player of the other team
	sta.b a0
	lda.w pfteam,x					; which team
	bne .g
	lda.w #$000A					; second team's first player
	sta.b a0
.g:									;find position 0 on the other team
	inc.b a0						; next player
	inc.b a0
	ldy.b a0
	lda.w position,y				; his position
	beq .found						; position 0: the goalie
	dec.b d1						; next candidate
	bpl .g
	jmp.w .x						; none found
.found:								;goalie x/y + half his velocity - puck; d2 = distance
	lda.w Xvel+1,y					; goalie x velocity high byte
	and.w #$00FF
	bit.w #$0080
	beq .gx
	ora.w #$FF00					; sign extend
.gx:
	pha								; half of it
	asl a
	pla
	ror a
	clc
	adc.w Xpos,y					; plus his x
	sec
	sbc.w puckx						; minus the puck x
	sta.b d0						; d0 = dx to the goalie
	lda.w Yvel+1,y					; goalie y velocity high byte
	and.w #$00FF
	bit.w #$0080
	beq .gy
	ora.w #$FF00					; sign extend
.gy:
	pha								; half of it
	asl a
	pla
	ror a
	clc
	adc.w Ypos,y					; plus his y
	sec
	sbc.w pucky						; minus the puck y
	sta.b d1						; d1 = dy to the goalie
	pha
	lda.b d0
	pha
	sta.b mula						; dx squared
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b d0
	lda.b mulres+2
	sta.b d0+2
	lda.b d1
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sec
	adc.b d0
	sta.b d0
	lda.b mulres+2
	adc.b d0+2
	sta.b d0+2
	jsl.l sroot						; distance to the goalie
	lda.b d0
	sta.b d2						; d2 = distance
	pla
	sta.b d0
	pla
	sta.b d1
	lda.w #$0012					; d3/d4 = post x/goal y
	sta.b d3
	lda.w #$0108					; goal y $108
	sta.b d4
	lda.w pfgoal,x					; goal end
	bne .l
	lda.w #$FEF8					; other end: -$108
	sta.b d4
.l:									;posts at x +-18, y +-$108
	lda.b d4
	pha
	lda.b d3
	pha
	jsl.l CalcAngleOffset			; angle to one post
	lda.b d4
	sta.b d5
	pla
	eor.w #$FFFF					; negate
	inc a
	sta.b d3						; post at -x
	pla
	sta.b d4
	jsl.l CalcAngleOffset			; angle to the other post
	lda.b d4						; sum of both angles
	clc
	adc.b d5
	sta.b d4
	stz.b d0						; default 0
	lda.b d4
	bit.w #$8000					; absolute value
	beq .abs
	eor.w #$FFFF					; negate
	inc a
.abs:
	cmp.w #$002D					; |angle| < 45: shoot at the open side
	bcs .x
	lda.w pfgoal,x
	beq .s
	lda.b d4						; mirror for the other end
	eor.w #$FFFF					; negate
	inc a
	sta.b d4
.s:
	lda.w #$0002
	sta.b d0
	lda.b d4						; sign of the angle
	bpl .x
	lda.w #$0006					; direction 6 on the other side
	sta.b d0
.x:
	lda.b d0
	sta.w passdir					; set the pass direction
.rtl:
	rtl
