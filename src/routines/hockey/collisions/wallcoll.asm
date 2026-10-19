wallcoll:							;Bounce object X off a wall: the puck loses speed and spins; a hard hit
									;makes a sound
	lda.b d0						; Wallcos/Wallsin
	sta.w Wallcos,x					; Wallcos = cos
	lda.b d1
	sta.w Wallsin,x					; Wallsin = sin
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d2 and the words after it (4 words)
	lda.b d2,x
	pha
	inx
	inx
	cpx.w #$0008
	bne .save
	ldx.b xsave						; restore X
	lda.b d1						;v1n = (Yvel*cos - Xvel*sin)/256, negated; v1t = (Xvel*cos + Yvel*sin)/256
	pha
	lda.b d0
	pha
	sta.b mulb
	lda.w Yvel,x					; Yvel * cos
	sta.b mula
	jsl.l muls32					; signed 32-bit multiply
	sta.b d0
	lda.b mulres+2
	sta.b d0+2
	lda.w Xvel,x					; Xvel * sin
	sta.b mula
	lda.b d1
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lda.b d0						; Yvel*cos - Xvel*sin
	sec
	sbc.b mulres
	sta.b d0
	lda.b d0+2
	sbc.b mulres+2
	sta.b d0+2
	lda.b d0+1						; high word
	eor.w #$FFFF					; negate
	inc a
	sta.b d2						; d2 = v1n, speed into the wall
	lda.w Xvel,x					; Xvel * cos
	sta.b mula
	lda.b $01,s
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b d0
	lda.b mulres+2
	sta.b d0+2
	lda.w Yvel,x					; Yvel * sin
	sta.b mula
	lda.b d1
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	adc.b d0						; Xvel*cos + Yvel*sin
	sta.b d0
	lda.b d0+2
	adc.b mulres+2
	sta.b d0+2
	lda.b d0+1						; high word
	sta.b d3						; d3 = v1t, speed along the wall
	cpx.w #$001C					; the puck?
	beq .puck
	jmp.w .player
.puck:
	lda.w #sf2shot					; puck: clear sf2shot
	trb.w sflags
	lda.b d2						; moving away from the wall
	bmi .pn
	jmp.w .nocoll
.pn:
	lsr a							; normal speed /4
	lsr a
	bit.w #$2000
	beq .pn1
	ora.w #$C000
.pn1:
	sta.b d2						; keep it
	sec
	sbc.w #$FC00					; hard hit (v1n <= -$400): pop up, flip, sound by speed
	beq .hard
	bmi .neg
	bvs .hard
	bra .pok
.neg:								; signed compare: overflow flag corrects the sign
	bvs .pok
.hard:								; hard hit: random bounce
	lda.w #$0800
	jsl.l randoma					; random number 0 to A-1
	eor.w #$FFFF					; negate
	inc a
	sta.w puckvz					; pop the puck up
	sta.b d0
	jsl.l puckflip					; flip the puck
	lda.w #SFXpuckwall1				; wall sound
	pha
	lda.b d2
	sec
	sbc.w #$EE00					; faster than -$1200?
	bmi .neg1
	bvc .s2
	bra .snd
.neg1:								; signed compare: overflow flag corrects the sign
	bvc .snd
.s2:								; louder wall sound, variant 2
	pla
	lda.w #SFXpuckwall1+1			; louder variant 2
	pha
	lda.b d2
	sec
	sbc.w #$F800					; faster than -$800?
	bmi .neg2
	bvc .s3
	bra .snd
.neg2:								; signed compare: overflow flag corrects the sign
	bvc .snd
.s3:								; wall sound, variant 3
	pla
	lda.w #SFXpuckwall1+2			; variant 3
	pha
.snd:
	jsl.l sfx						; play the sound
.pok:								;reduce the tangent speed of the puck
	lda.b d3						; tangent speed
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	bit.w #$0200
	beq .t1
	ora.w #$FC00
.t1:
	sta.b d0						; d0 = tangent speed / 64
	pha
	asl a
	pla
	ror a
	sta.b d0+2						; and half of that
	lda.b d3
	sec
	sbc.b d0
	sec
	sbc.b d0+2
	sta.b d3						; reduce the tangent speed
	bra .noadd						; rotate back
.player:
	lda.b d2						; player: normal speed
	sec
	sbc.w #$03E8					; player: v1n > 1000: no collision
	beq .p1
	bmi .neg3
	bvs .p1
.nocoll1:							; far branch to .nocoll
	jmp.w .nocoll
.neg3:								; signed compare: overflow flag corrects the sign
	bvs .nocoll1
.p1:								; fast into the boards: board sound
	lda.b d2
	sec
	sbc.w #$F000					; v1n <= -$1000 and impact >= 10: board sound
	beq .imp
	bmi .neg4
	bvs .imp
	bra .nosfx
.neg4:								; signed compare: overflow flag corrects the sign
	bvs .nosfx
.imp:
	lda.w impact,x					; impact
	sec
	sbc.w #$000A
	bmi .neg5
	bvc .psnd
	bra .nosfx
.neg5:								; signed compare: overflow flag corrects the sign
	bvc .nosfx
.psnd:
	lda.w seed+1					; random sound variant
	and.w #$0001
	clc
	adc.w #SFXplayerwall			; player wall sound
	pha
	jsl.l sfx
.nosfx:
	lda.b d2						; normal speed / 4
	lsr a
	lsr a
	bit.w #$2000
	beq .n1
	ora.w #$C000
.n1:
	sta.b d2						; keep it
	sec
	sbc.w #$FC7C					; v1n >= -900: -1000
	bmi .neg6
	bvc .min
	bra .noadd
.neg6:								; signed compare: overflow flag corrects the sign
	bvc .noadd
.min:
	lda.w #$FC18					; limit -1000
	sta.b d2
.noadd:								;rotate back: new Xvel/Yvel
	lda.b $01,s						; cos
	sta.b mula
	lda.b d3						; v1t
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b tmp0						; tmp0 = cos * v1t
	lda.b mulres+2
	sta.b tmp1
	lda.b $03,s
	sta.b mula						; sin
	lda.b d2
	sta.b mulb						; v1n
	jsl.l muls32					; signed 32-bit multiply
	lda.b tmp0
	sec
	sbc.b mulres					; minus sin * v1n
	sta.b tmp0
	lda.b tmp1
	sbc.b mulres+2
	sta.b tmp1
	lda.b tmp0+1
	sta.w Xvel,x					; new x velocity
	lda.b $03,s						; sin
	sta.b mula
	lda.b d3						; v1t
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b d3						; sin * v1t
	lda.b mulres+2
	sta.b d3+2
	lda.b $01,s
	sta.b mula						; cos
	lda.b d2
	sta.b mulb						; v1n
	jsl.l muls32					; signed 32-bit multiply
	adc.b d3						; plus cos * v1n
	sta.b d3
	lda.b d3+2
	adc.b mulres+2
	sta.b d3+2
	lda.b d3+1
	sta.w Yvel,x					; new y velocity
	lda.w Zvel,x					; moving up: Zvel = 0
	bmi .nocoll
	stz.w Zvel,x					; Zvel = 0
.nocoll:
	pla								; drop the stacked cos and sin
	pla
	stx.b xsave						; keep X
	ldx.w #$0006
.restore:							; pull d2 and the words after it back
	pla
	sta.b d2,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
