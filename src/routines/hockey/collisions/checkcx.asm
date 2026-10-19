checkcx:							;Collision of object X with a nearby object: checks, interference and
									;fights, then the momentum passes between them
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d0 and the words after it (12 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0018
	bne .save
	ldx.b xsave						; restore X
	sty.b a2						; a2 = Y; d0/d1 = relative velocity, d2/d3 = relative position
	stz.b evalue					; evalue (e) = 0
	lda.w Xvel,x					; relative velocity: X minus Y
	sec
	sbc.w Xvel,y
	sta.b d0						; d0 = Vx
	lda.w Yvel,x
	sec
	sbc.w Yvel,y
	sta.b d1						; d1 = Vy
	sta.b mulb
	lda.w Xpos,y					; relative position: Y minus X
	sec
	sbc.w Xpos,x
	sta.b d2						; d2 = Dx
	lda.w Ypos,y
	sec
	sbc.w Ypos,x
	sta.b d3						; d3 = Dy
	sta.b mula
	lda.b d1
	pha								; keep Vy
	lda.b d0
	pha								; and Vx
	jsl.l muls32					; signed 32-bit multiply
	sta.b d1						; d1 = Vy * Dy
	lda.b mulres+2
	sta.b d1+2
	lda.b d2						; Dx
	sta.b mula
	lda.b d0
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	adc.b d1
	sta.b d1
	lda.b d1+2
	adc.b mulres+2					; plus Vy * Dy
	bpl .v1n						; v1n < 0: no collision
	jmp.w .exit4
.v1n:								;V1n = (Vy*Dy + Vx*Dx) / 16
	lsr a							; divide by 16
	ror.b d1
	lsr a
	ror.b d1
	lsr a
	ror.b d1
	lsr a
	ror.b d1
	lda.w pfteam,x					; same team: no impact
	cmp.w pfteam,y
	beq .not
	lda.b d1+1						; impact value
	and.w #$00FF
	sta.b d4						; d4 = V1n
	cmp.w #$0006
	bcs .g40
	lda.w #$0005					; minimum 5
	sta.b d4
.g40:								;minimum impact 5
	clc								; add to the impact of X
	adc.w impact,x
	sta.w impact,x
	lda.w impact,y					; and of Y
	clc
	adc.b d4
	sta.w impact,y
	lda.w pf2fight,y				; impactp = the other (not while fighting)
	bne .if
	txa								; the other player is impactp
	lsr a
	sta.w impactp,y
.if:
	lda.w pf2fight,x				; X not fighting
	bne .if2
	tya								; Y is impactp of X
	lsr a
	sta.w impactp,x
.if2:								;impact under 20: no check sound
	lda.b d4
	cmp.w #$0014					; impact under 20: no check sound
	bcc .n1
	lda.w puckc						; check sound only if one of them has the puck
	cmp.w SCnum,x					; X holds the puck?
	beq .nc
	cmp.w SCnum,y					; Y holds the puck?
	bne .n1
.nc:
	jsl.l newcheck					; new check
.n1:
	jsl.l checkint					; interference
	jsl.l checkcheck				; check
	jsl.l checkfight				; fight
.not:								;same team: no check events
	lda.b d1						; d4 = V1n
	sta.b d4
	pla								; restore Vx
	sta.b d0
	pla								; and Vy
	sta.b d1
	lda.b collflag					; collflag set by holdcheck / Bcheck: no transfer
	bpl .tr
	jmp.w .exit
.tr:								;V1t = (Vx*Dy - Vy*Dx) / 16
	lda.b d2
	sta.b mula
	lda.b d1
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b d1						; keep it
	lda.b mulres+2
	sta.b d1+2
	lda.b d3
	sta.b mula
	lda.b d0
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sec
	sbc.b d1						; minus Vy * Dx
	sta.b d0
	lda.b mulres+2
	sbc.b d1+2
	lsr a
	ror.b d0
	lsr a
	ror.b d0
	lsr a
	ror.b d0
	lsr a
	ror.b d0						; divide by 16
	lda.b d0
	sta.b d5						; d5 = V1t
	lda.w weight,x					; weights + 140
	clc
	adc.w #$008C
	sta.b d0						; d0 = weight of X + 140
	ldy.b a2
	lda.w weight,y					; Y weight plus 140
	clc
	adc.w #$008C
	sta.b d1						; d1 = weight of Y + 140
	sta.b mula
	lda.b evalue
	sta.b mulb
	jsl.l mulu16					; mulu, A = mula*mulb
	lsr a
	lsr a
	lsr a
	lsr a
	sta.b d7+2						; m2*e
	lda.b d1
	clc
	adc.b d0						; d1 = m1 + m2
	sta.b d1
	lda.b d0
	sec								; m1 - m2*e
	sbc.b d7+2
	sta.b mulb						; mulb = m1 - m2*e
	lda.b d4
	sta.b mula						; V1n
	jsl.l muls32					; signed 32-bit multiply
	lda.b d1
	sta.b mula
	jsl.l divs						; signed divide
	sta.b d0						; d0 = V1n'
	lda.b evalue
	sta.b mulb
	lda.b d4
	sta.b mula
	jsl.l muls16					; signed multiply
	lsr a
	lsr a
	lsr a
	lsr a
	bit.w #$0800					; sign extend
	beq .v2n
	ora.w #$F000
.v2n:								;V2n = V1n + V1n*e
	clc
	adc.b d0						; plus the mass term
	sta.b d1						; d1 = V2n
	lda.b d5
	sta.b mula
	lda.b d3
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b tmp0
	lda.b mulres+2
	sta.b tmp1
	lda.b d0
	sta.b mula
	lda.b d2
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	adc.b tmp0
	sta.b tmp0
	lda.b tmp1
	adc.b mulres+2					; add
	lsr a
	ror.b tmp0
	lsr a
	ror.b tmp0
	lsr a
	ror.b tmp0
	lsr a
	ror.b tmp0						; divide by 16
	lda.w Xvel,y
	clc
	adc.b tmp0						; plus Y's x velocity
	sta.w Xvel,x					; new Xvel of X
	lda.b d5
	sta.b mula
	lda.b d2
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b tmp0
	lda.b mulres+2
	sta.b tmp1
	lda.b d0
	sta.b mula
	lda.b d3
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sec
	sbc.b tmp0						; difference
	sta.b tmp0
	lda.b mulres+2
	sbc.b tmp1
	lsr a
	ror.b tmp0
	lsr a
	ror.b tmp0
	lsr a
	ror.b tmp0
	lsr a
	ror.b tmp0						; divide by 16
	lda.w Yvel,y
	clc
	adc.b tmp0						; plus Y's y velocity
	sta.w Yvel,x					; new Yvel of X
	lda.b d1
	sta.b mula
	lda.b d2
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lsr.b mulres+2
	ror a
	lsr.b mulres+2
	ror a
	lsr.b mulres+2
	ror a
	lsr.b mulres+2
	ror a							; divide by 16
	clc
	adc.w Xvel,y					; plus Y's x velocity
	sta.w Xvel,y					; new Xvel of Y
	lda.b d1
	sta.b mula
	lda.b d3
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lsr.b mulres+2
	ror a
	lsr.b mulres+2
	ror a
	lsr.b mulres+2
	ror a
	lsr.b mulres+2
	ror a							; divide by 16
	clc
	adc.w Yvel,y					; plus Y's y velocity
	sta.w Yvel,y					; new Yvel of Y
	lda.w #$FFFF					; collflag
	sta.b collflag					; set collflag
.exit:
	stx.b xsave						; keep X
	ldx.w #$0016
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
.exit4:								;drop the saved Vx/Vy
	pla								; drop the saved Vx and Vy
	pla
	bra .exit
