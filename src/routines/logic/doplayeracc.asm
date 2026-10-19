doplayeracc:						;Player X skates in direction d0 (or glides or stops), turning toward it
									;and skating backwards
		;   in his own zone
	lda.w position,x				; goalie?
	bne .skater
	jml.l goalieacc					; goalie is special
.skater:
	lda.w #SPAglide					; d1 = glide animation
	sta.b d1
	lda.w pfrev,x					; skating backwards?
	beq .d0
	lda.w #SPAglideback				; glide back animation
	sta.b d1
.d0:
	lda.b d0
	and.w #$000F					; low nibble: direction or 8/9
	sta.b d0
	cmp.w #$0008					; 0-7 is a real direction
	bcc .d1
	cmp.w #$0009					; 8 = no direction
	bne .cgl
	lda.w Xvel,x					; 9 = stop
	ora.w Yvel,x
	beq .cgl
	jml.l dostop					; still moving: stop
.cgl:								;no turn animation playing (pf2aip): SetSPA
	lda.w pf2aip,x					; animation in progress: leave it
	bne .rtl
	jml.l SetSPA					; start animation d1
.rtl:								; return
	rtl
.d1:								;a direction: pfrev, then the turn
	lda.b d1						; save the animation
	pha
	lda.b d0						; and the wanted direction
	pha
	sta.b d2						; d2 = wanted direction
	txa
	lsr a
	cmp.w puckc						; the puck carrier never skates backwards
	bne .nocarrier
	jmp.w .clrrev
.nocarrier:
	lda.w puckx						; dx to the puck
	sec
	sbc.w Xpos,x					; minus the x of X
	sta.b d0
	lda.w Ypos,x
	sta.b d3						; d3 = my y
	lda.w puckvy
	lsr a							; y velocity of the puck / 128
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	bit.w #$0100
	beq .sx
	ora.w #$FE00
.sx:
	clc
	adc.w pucky						; plus the puck y
	sec
	sbc.b d3						; dy to the puck, led by its y velocity
	sta.b d1
	lda.w pfgoal,x					; mirror for the team shooting toward +y
	bne .c1
	lda.b d0
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	lda.b d1
	eor.w #$FFFF					; negate
	inc a
	sta.b d1
	lda.b d3
	eor.w #$FFFF					; negate
	inc a
	sta.b d3
	lda.b d2						; and the wanted direction
	eor.w #$0004
	sta.b d2
.c1:
	lda.w pfrev,x					; already skating backwards?
	bne .inrev
	lda.b d3						; backwards only in his own zone
	bpl .clrrev
	lda.b d2
	cmp.w #$0004					; and when the wanted direction is 4
	bne .clrrev
	jsl.l vtoa						; vector to direction
	inc a
	and.w #$0007
	cmp.w #$0003
	bcs .clrrev						; forward unless the puck direction is 7, 0 or 1
	bra .rev
.inrev:
	lda.b d2						; already backwards: wanted direction 3, 4 or 5
	sec
	sbc.w #$0003
	and.w #$0007
	cmp.w #$0003
	bcs .clrrev
	jsl.l vtoa						; vector to direction
	inc a
	inc a
	and.w #$0007
	cmp.w #$0005
	bcs .clrrev
.rev:
	lda.w pfrev,x					; already backwards?
	bne .done
	lda.w Xvel,x
	sta.b d0						; moving?
	ora.w Yvel,x
	beq .setrev						; standing still: start backwards
	lda.w Yvel,x
	sta.b d1
	jsl.l vtoa						; vector to direction
	sec
	sbc.b $01,s						; minus the wanted direction
	inc a
	and.w #$0007
	cmp.w #$0003
	bcs .done						; not within one step: stay forward
.setrev:
	inc a
	sta.w pfrev,x					; start skating backwards
	bra .done
.clrrev:
	stz.w pfrev,x					; skate forwards
.done:								;turn rate = .ftab (direction difference) * d7; 0: noturn0
	pla								; d0 = wanted direction
	sta.b d0
	pla								; d1 = animation
	sta.b d1
	lda.w facedir,x					; facing direction
	sta.b d2
	lda.b d0
	sec
	sbc.b d2
	and.w #$0007					; d0 = wanted - facing
	asl a
	sta.b d0
	tax
	lda.l .ftab,x					; turn step by the difference
	ldx.b a3
	sta.b mula
	lda.b d7
	sta.b mulb
	jsl.l muls16					; signed multiply
	sta.b tmp0
	lda.b tmp0
	bne .turn						; facing the right way: no turn
	jml.l noturn0
.turn:
	lda.w Xvel,x
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b d4
	lda.b mulres+2
	sta.b d4+2
	lda.w Yvel,x
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	adc.b d4
	lda.b mulres+2
	adc.b d4+2
	sta.b d3						; d3 = speed class
	lda.w #$0300					; turn rate base $300
	sec
	sbc.b d3						; falls as speed rises
	sta.b d4
	sec
	sbc.w #$0180					; down to $180
	bmi .neg
	bvs .vs
	bra .iok
.neg:								; signed compare: overflow flag corrects the sign
	bvs .iok
.vs:
	lda.w #$0180
	sta.b d4
.iok:
	lda.b tmp0						; turn step
	sta.b mula
	lda.b d4
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b d4
	lda.b mulres+2
	sta.b d4+2
	lda.w pfrev,x					; backwards: turn the other way
	beq .i0
	lda.w #$0000
	sec
	sbc.b d4
	sta.b d4
	lda.w #$0000
	sbc.b d4+2
	sta.b d4+2
.i0:								;facedir.l + d4
	lda.w facefrac,x				; facing fraction
	clc
	adc.b d4
	sta.w facefrac,x
	lda.w facedir,x					; facing direction
	adc.b d4+2
	and.w #$0007					; 0-7
	sta.w facedir,x
	sta.b d2						; d2 = new facing for playeracc
	lda.b d3
	cmp.w #$0015					; slow: keep the animation
	bcc .s3
	stz.b d1						; fast: pick a turn animation
	lda.b tmp0
	bpl .s1							; turning right or left
	lda.w #SPAturnl-SPAturnr
	sta.b d1
.s1:
	lda.w attribute,x				; attribute flip swaps the sense
	bit.w #attrxflip
	beq .s2
	lda.b d1
	eor.w #SPAturnl-SPAturnr
	sta.b d1
.s2:								;SPAturnr (or SPAturnl), pf2aip
	lda.b d1
	clc
	adc.w #SPAturnr					; SPAturnr or SPAturnl
	sta.b d1
	sta.w pf2aip,x					; animation in progress
.s3:
	jsl.l SetSPA					; start animation d1
	lda.b d3
	cmp.w #$0003					; moving at some speed: accelerate
	bcc .rtl2
	jml.l noturn
.rtl2:
	rtl								; almost still: no acceleration
.ftab:								;turn rate by the direction difference
	dw 0,23,23,23,0,-23,-23,-23		; turn step by (wanted - facing)
