passtoa0:							;Pass the puck to player a0, leading him by his speed
	jsl.l loadTeamStruct			; a2 = team of X, a1 = the other
	lda.b a0						; receiver is a0
	lsr a
	sta.w passReceiverPlayerNum		; remember the receiver
	lda.w passspeed					; passspeed in pix/sec
	lsr a
	lsr a
	bit.w #$2000
	beq .sx
	ora.w #$C000
.sx:
	sta.b d5						; d5 = passspeed / 4
	ldx.b a0						; swap a0 and a3
	ldy.b a3
	stx.b a3
	sty.b a0
	lda.w #$0013					; assignment $13: pass receive
	sta.b d0
	jsl.l assinsert					; insert assignment d0
	ldx.b a0						; swap back
	ldy.b a3
	stx.b a3
	sty.b a0
	tya
	jsl.l GetHot					; receiver hot spot offset
	ldy.b a0
	lda.b d1
	clc
	adc.w Ypos,y					; add the receiver's y
	sec
	sbc.w pucky						; minus the puck y
	sta.b d1						; d1 = y vector puck to receiver
	pha
	lsr a							; vector / 4
	lsr a
	bit.w #$2000
	beq .sy
	ora.w #$C000
.sy:
	sta.b d3						; d3 = y / 4
	lda.b d0
	clc
	adc.w Xpos,y					; add the receiver's x
	sec
	sbc.w puckx						; minus the puck x
	sta.b d0						; d0 = x vector puck to receiver
	pha
	lsr a
	lsr a
	bit.w #$2000
	beq .sx2
	ora.w #$C000
.sx2:
	sta.b d2						; d2 = x / 4
	lda.w Yvel,y					; receiver y velocity
	sta.b mulb
	lda.w #$00F0					; times $F0
	sta.b mula
	jsl.l muls32					; signed 32-bit multiply
	lda.b mulres+2					; y pixels per 1/4 second
	sta.b d1
	pha
	lda.w Xvel,y					; receiver x velocity
	sta.b mulb
	lda.w #$00F0
	sta.b mula
	jsl.l muls32					; signed 32-bit multiply
	lda.b mulres+2					; x pixels per 1/4 second
	sta.b d0
	pha
	sta.b mulb
	lda.b d2
	sta.b mula
	jsl.l muls16					; signed multiply
	sta.b d0
	lda.b d3
	sta.b mula
	lda.b d1
	sta.b mulb
	jsl.l muls16					; signed multiply
	adc.b d0
	asl a							; times 2
	sta.b d4						; d4 = j
	lda.b $01,s
	sta.b mula
	sta.b mulb
	jsl.l muls16					; signed multiply
	sta.b d0
	lda.b $03,s
	sta.b mula
	sta.b mulb
	jsl.l muls16					; signed multiply
	sta.b d1
	lda.b d5
	sta.b mula
	eor.w #$FFFF					; negate
	inc a
	sta.b mulb
	jsl.l muls16					; signed multiply
	adc.b d0
	clc
	adc.b d1
	sta.b d5						; k
	lda.b d2
	sta.b mula
	sta.b mulb
	jsl.l muls16					; signed multiply
	sta.b d2
	lda.b d3
	sta.b mula
	sta.b mulb
	jsl.l muls16					; signed multiply
	adc.b d2
	sta.b mulb
	lda.b d5
	sta.b mula
	jsl.l muls32					; signed 32-bit multiply
	sta.b d3
	lda.b mulres+2
	sta.b d3+2
	asl.b d3						; times 4
	rol.b d3+2
	asl.b d3
	rol.b d3+2
	lda.b d4
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sec
	sbc.b d3
	sta.b d0
	lda.b mulres+2
	sbc.b d3+2
	sta.b d0+2
	jsl.l sroot						; square root of the discriminant
	lda.w #$0001					; retry counter
	sta.b d3
	lda.b d5
	lsr a							; k / 4
	lsr a
	bit.w #$2000
	beq .sx3
	ora.w #$C000
.sx3:
	sta.b d5
	lda.b d5
	bne .0							; avoid dividing by zero
	lda.w #$0001
	sta.b d5
.0:
	lda.b d0						; d2 = (sqrt - j) / k: intercept time
	sta.b d2
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	lda.b d2
	sec
	sbc.b d4
	sta.b mulb
	lda.b d5
	sta.b mula
	jsl.l divs16					; divide
	sta.b d2
	bpl .pos						; negative: try the other root
	dec.b d3
	bpl .0
.pos:
	bne .1
	inc.b d2						; time can't be zero
.1:
	lda.b d2
	cmp.w #$0019					; limit to 3 seconds
	bcc .2
	lda.w #$0018
	sta.b d2
.2:
	lda.b d2
	sep #$20						; 8-bit A
	sta.w puckvz+1					; time in 1/8 sec for puckvz
	rep #$30						; 16-bit registers
	cmp.w #$000C					; longer than 12?
	bcc .3
	sep #$20						; 8-bit A
	lda.b #$0C						; limit 12
	sta.w puckvz+1
	rep #$30						; 16-bit registers
.3:
	ldy.b a0
	lda.b d2
	asl a							; time * 8
	asl a
	asl a
	sec
	sbc.w #$000A					; minus 10
	sta.w temp1,y					; receiver temp1
	sec
	sbc.w #$0006					; minus 6
	sta.w nopuck+puckobj			; puck pickup lockout
	pla
	sta.b d0
	sta.b mulb
	pla
	sta.b d1
	lda.b d2
	sta.b mula
	jsl.l muls32					; signed 32-bit multiply
	lda.b mulres+2
	lsr a
	lda.b mulres
	ror a
	sta.b d0						; halved
	lda.b mulres+2
	pha
	asl a
	pla
	ror a
	sta.b d0+2
	pla
	clc
	adc.b d0						; plus receiver motion
	sta.b d0
	clc
	adc.w puckx						; plus the puck x
	ldy.b a0
	sta.w temp3,y					; receiver target x
	lda.b d2
	sta.b mula
	lda.b d1
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lda.b mulres+2
	lsr a
	lda.b mulres
	ror a
	sta.b d1
	lda.b mulres+2
	pha
	asl a
	pla
	ror a
	sta.b d1+2
	pla
	clc
	adc.b d1
	sta.b d1						; plus receiver motion
	clc
	adc.w pucky						; plus the puck y
	ldy.b a0
	sta.w temp4,y					; receiver target y
	lda.w #$0078
	sta.b mula
	lda.b d2
	sta.b mulb
	jsl.l mulu16					; A = mula * mulb
	sta.b d2
	sta.b mula
	lda.b d0
	sta.b mulb+2
	lda.b d0+2
	sta.b mulb
	jsl.l divs						; signed divide
	sta.b d0
	sta.w puckvx					; puck x velocity
	lda.b d2
	sta.b mula
	lda.b d1
	sta.b mulb+2
	lda.b d1+2
	sta.b mulb
	jsl.l divs						; signed divide
	sta.b d1
	sta.w puckvy					; puck y velocity
	rtl
