checkgoalp:							;Player X runs into the goal a2
	lda.w pflags,x					; player flags
	bit.w #pf2npc					; no collisions with players?
	beq .npc
	jmp.w .rtl
.npc:
	lda.w Zpos,x					; height of the player
	sec
	sbc.w #$000A					; above $0A: no hit
	beq .pl
	bmi .neg
	bvs .pl
.ex1:
	jmp.w .rtl
.neg:								; signed compare: overflow flag corrects the sign
	bvs .ex1
.pl:								;players only (SCnum <= 11)
	cpx.w #$0017					; only players
	bcc .go
	jmp.w .rtl
.go:
	ldy.b a2						; d0 = -dy, d1 = dx
	lda.b d3						; keep y
	pha
	sec
	sbc.w Ypos,y					; minus the goal y
	sta.b d3
	eor.w #$FFFF					; negate
	inc a
	sta.b d0						; d0 = -dy
	lda.b d2						; keep x
	pha
	sec
	sbc.w Xpos,y					; minus the goal x
	sta.b d1						; d1 = dx
	asl a
	asl a
	asl a
	asl a
	sta.b mula						; dx * 16
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lda.w #$0400					; divide by $400
	sta.b mula
	jsl.l divu
	cmp.w #$0101					; more than $100?
	bcc .inx
	jmp.w .exit
.inx:								;(dy*16)^2/$79 + (dx*16)^2/$400 <= $100?
	sta.b d2						; keep it
	lda.b d3						; dy * 16
	asl a
	asl a
	asl a
	asl a
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lda.w #$0079					; divide by $79
	sta.b mula
	jsl.l divu
	adc.b d2						; plus the x term
	cmp.w #$0101					; inside the goal ellipse?
	bcs .exit
	pla								; restore x
	sta.b d2
	pla								; restore y
	sta.b d3
	jsl.l CheckBump					; CheckBump, then wallcoll with the normal (d0,d1)/r
	lda.b d3						; keep y
	pha
	lda.b d2						; and x
	pha
	lda.b d1						; and d1
	pha
	lda.b d0						; and d0
	pha
	sta.b mula						; d0 squared
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b d0
	lda.b mulres+2
	sta.b d0+2
	lda.b d1						; d1 squared
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	adc.b d0						; plus d0 squared
	sta.b d0
	lda.b d0+2
	adc.b mulres+2
	sta.b d0+2
	jsl.l sroot						; length of the normal
	inc a							; plus one
	sta.b d2
	sta.b mula						; d2 = length
	pla								; d0 back
	sta.b d0
	pla								; d1 back
	sta.b d1
	stz.b mulb
	lda.b d0
	sta.b mulb+1
	lda.b d0+2
	sta.b mulb+3
	jsl.l divs						; signed divide
	sta.b d0
	lda.b d2
	sta.b mula
	stz.b mulb
	lda.b d1
	sta.b mulb+1
	lda.b d1+2
	sta.b mulb+3
	jsl.l divs						; signed divide
	sta.b d1
	jsl.l wallcoll					; wall collision with the normal
.exit:
	pla								; restore x
	sta.b d2
	pla								; restore y
	sta.b d3
.rtl:								; return
	rtl
