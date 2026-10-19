checkwallcoll:						;Collision of object X with the corners, the goals and the boards
	lda.w #$012A					; d3 = $12A - wcradiusy, d2 = $88 - wcradiusx; corner centers 64 in
	sec
	sbc.w wcradiusy					; y half length minus the radius
	pha								; keep it
	eor.w #$FFFF					; negate
	inc a
	clc
	adc.w #$0040
	sta.b d5						; d5 = corner circle center y
	lda.w #sideline
	sec
	sbc.w wcradiusx					; x half width minus the radius
	pha								; keep it
	eor.w #$FFFF					; negate
	inc a
	clc
	adc.w #$0040
	sta.b d4						; d4 = corner circle center x
	lda.b d3
	pha								; keep y
	ldy.b d2						; and x
	phy
	sec
	sbc.b d5						; in the -y end zone?
	beq .negy
	bmi .neg
	bvs .negy
	bra .ctc
.neg:								; signed compare: overflow flag corrects the sign
	bvs .ctc
.negy:
	lda.b d2						; goal mouth x range: left edge
	sec
	sbc.b d4
	bmi .neg1
	bvc .gl1
	bra .circle
.neg1:								; signed compare: overflow flag corrects the sign
	bvc .circle
.gl1:
	lda.b d4						; right edge
	eor.w #$FFFF					; negate
	inc a
	sta.b d4
	sec
	sbc.b d2
	bmi .neg2
	bvc .goal13
	bra .circle
.neg2:								; signed compare: overflow flag corrects the sign
	bvc .circle
.goal13:							;goal at the -y end (object 13)
	lda.w #$001A
	sta.b a2
	jsl.l checkgoal					; goal at the -y end
	jmp.w .exit
.ctc:								; other end zone
	lda.b d5						; mirror the center y
	eor.w #$FFFF					; negate
	inc a
	sta.b d5
	sec
	sbc.b d3						; between the end zones: no hit
	beq .c2
	bmi .neg3
	bvs .c2
.exit1:								; far branch to .exit
	jmp.w .exit
.neg3:								; signed compare: overflow flag corrects the sign
	bvs .exit1
.c2:
	lda.b d2						; goal mouth x range: left edge
	sec
	sbc.b d4
	bmi .neg4
	bvc .c3
	bra .circle
.neg4:								; signed compare: overflow flag corrects the sign
	bvc .circle
.c3:
	lda.b d4						; right edge
	eor.w #$FFFF					; negate
	inc a
	sta.b d4
	sec
	sbc.b d2
	bmi .neg5
	bvc .goal12
	bra .circle
.neg5:								; signed compare: overflow flag corrects the sign
	bvc .circle
.goal12:							;goal at the +y end (object 12)
	lda.w #$0018
	sta.b a2
	jsl.l checkgoal					; goal at the +y end
	jmp.w .exit
.circle:							;distance from the corner center (max+min/4)
	lda.b d2						; corner circle: offset from the center
	sec
	sbc.b d4						; d2 = dx
	sta.b d2
	eor.w #$FFFF					; negate
	inc a
	sta.b d1						; d1 = -dx, sin
	bit.w #$8000
	beq .dx
	eor.w #$FFFF					; negate
	inc a
.dx:
	sta.b mula						; absolute dx
	lda.b d3
	sec
	sbc.b d5
	sta.b d0						; d0 = dy, cos
	bit.w #$8000
	beq .dy
	eor.w #$FFFF					; negate
	inc a
.dy:
	sta.b mulb						; absolute dy
	cmp.b mula
	bcc .m2
	lda.b mula
	lsr a
	lsr a
	adc.b mulb						; max + min / 4: distance
	bra .dist
.m2:
	lsr a
	lsr a
	adc.b mula						; max + min / 4: distance
.dist:
	cmp.w #$0041					; inside the radius 64 circle: no hit
	bcc .exit						; inside the radius: no hit
	sta.b d3						; cos = dy*256/r, sin = dx*256/r
	sta.b mula						; distance
	stz.b mulb
	stz.b mulb+2
	lda.b d0						; dy * 256
	sta.b mulb+1
	bpl .cos
	lda.w #$FFFF
	sta.b mulb+3
.cos:
	jsl.l divs						; signed divide
	sta.b d0						; d0 = dy * 256 / distance
	lda.b d3
	sta.b mula
	stz.b mulb
	stz.b mulb+2
	lda.b d1						; dx * 256
	sta.b mulb+1
	bpl .sin
	lda.w #$FFFF
	sta.b mulb+3
.sin:
	jsl.l divs						; signed divide
	sta.b d1						; d1 = dx * 256 / distance
	jsl.l wallcollb					; wall hit at the corner
.exit:								;no corner hit: the side and end boards
	pla								; restore d2-d5
	sta.b d2
	pla
	sta.b d3
	pla
	sta.b d4
	pla
	sta.b d5
	lda.w Wallcos,x					; corner hit: done
	ora.w Wallsin,x
	bne .rtl
	lda.w #$0100					; side walls: cos $100, sin 0
	sta.b d0
	stz.b d1
	lda.b d3						; y against the board limit
	sec
	sbc.b d5
	bmi .neg6
	bvs .s1
.b1:
	jmp.w wallcollb					; wall hit, high y board
.neg6:								; signed compare: overflow flag corrects the sign
	bvs .b1
.s1:
	lda.b d0						; mirror the normal
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	lda.b d5
	eor.w #$FFFF					; negate
	inc a
	sta.b d5						; mirror the board
	sec
	sbc.b d3						; y against the opposite limit
	bmi .neg7
	bvs .s2
.b2:
	jmp.w wallcollb					; wall hit, low y board
.neg7:								; signed compare: overflow flag corrects the sign
	bvs .b2
.s2:
	lda.b d0						; swap cos and sin
	pha
	lda.b d1
	sta.b d0
	pla
	sta.b d1
	lda.b d2						; x against the board limit
	sec
	sbc.b d4
	bmi .neg8
	bvs .s3
.b3:
	jmp.w wallcollb					; wall hit, x board
.neg8:								; signed compare: overflow flag corrects the sign
	bvs .b3
.s3:
	lda.b d1
	eor.w #$FFFF					; negate
	inc a
	sta.b d1
	lda.b d4
	eor.w #$FFFF					; negate
	inc a
	sta.b d4
	sec								; mirror the board
	sbc.b d2
	bmi .neg9
	bvs .rtl
.b4:
	jmp.w wallcollb					; wall hit, opposite x board
.neg9:								; signed compare: overflow flag corrects the sign
	bvs .b4
.rtl:								; return
	rtl
