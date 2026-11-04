checkcheck:							;Two players are in contact: check what happens each way
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d0 and the words after it (10 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0014
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0000
.savea:								; save a0 and the words after it (8 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0010
	bne .savea
	ldx.b xsave						; restore X
	jsl.l .cc
	ldx.b a2
	ldy.b a3
	stx.b a3
	sty.b a2
	jsl.l .cc
	stx.b xsave						; keep X
	ldx.w #$000E
.resta:								; pull a0 and the words after it back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0012
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	ldx.b a3
.rtl:								; return
	rtl
.cc:								;X is checking a2
	ldy.b a2						; a2 holding: holdcheck
	lda.w SPA,y
	cmp.w #SPAHold
	bne .h2
	jml.l holdcheck
.h2:								; hook check: hand over to holdcheck
	cmp.w #SPAhook
	bne .b
	jml.l holdcheck
.b:									; sweep check: hand over to Bcheck
	cmp.w #SPAsweepchk
	bne .burst
	jml.l Bcheck
.burst:								;X must be in the burst anim
	lda.w SPA,x
	cmp.w #SPAburst
	bne .rtl
	lda.w gmclock					; clock stopped: fight chance up
	beq .nofight
	lda.w #$0100
	sta.w impact,x
	sta.w impact,y
.nofight:							; no fight: compare positions
	lda.w Xpos,y
	sec
	sbc.w Xpos,x
	sta.b d0
	lda.w Ypos,y
	sec
	sbc.w Ypos,x
	sta.b d1
	jsl.l vtoa						; vector to direction
	lda.b d0
	sec
	sbc.w facedir,x
	and.w #$0007
	sta.b d0
	lda.w attribute,x				; xflip: mirror the direction
	bit.w #attrxflip
	beq .0
	lda.b d0
	eor.w #$FFFF					; negate
	inc a
	and.w #$0007
	sta.b d0
.0:									;check anim from .list by the direction to a2
	asl.b d0
	lda.w #.list
	sta.b a0
	sta.w pfalock,x					; pfalock
	lda.w #.list>>16
	sta.b a0+2
	ldy.b d0
	lda.b [a0],y
	sta.b d1
	jsl.l SetSPA					; start animation d1
	ldy.b a2
	lda.w position,y
	bne .pos
	jmp.w .rtl
.pos:								;goalie does not fall
	lda.b d4						; impact under 20: no fall
	sec
	sbc.w #$0014
	bmi .neg
	bvc .fall
.ex1:								; far branch to .rtl
	jmp.w .rtl
.neg:								; signed compare: overflow flag corrects the sign
	bvc .ex1
.fall:								;d0 = (120 (*2 joystick) - weight + weight of a2) / 2 - impact of a2
	lda.w #$0078
	sta.b d0
	lda.w pflags,x
	bit.w #pfjoycon
	beq .00
	asl.b d0
.00:								; weight difference
	lda.b d0
	sec
	sbc.w weight,x
	clc
	adc.w weight,y
	lsr a
	sec
	sbc.w impact,y
	sta.b d0
	beq .down
	bmi .down
	jsl.l randomd0					; random < checking: down
	lda.b d0
	sec
	sbc.w checking,x
	beq .down
	bmi .neg1
	bvc .pen
	bra .down
.neg1:								; signed compare: overflow flag corrects the sign
	bvc .down
.pen:								; penalty roll (checkagr <= 4)
	jsl.l checkagr					;checkagr <= 4 and no highlight: PenCharging or PenSlashing (d0 = penalty
									;roll)
	lda.b d0
	cmp.w #$0005
	bcc .nohl
	jmp.w .rtl
.nohl:								; not a highlight: roll
	lda.w gmode
	bit.w #gmhl
	beq .roll
	jmp.w .rtl
.roll:								; random roll
	lda.w seed+1
	and.w #$0002
	clc
	adc.w #PenCharging
	sta.b d0
	jmp.w AddPenalty
.down:								; roll a penalty, then a2 falls
	jsl.l checkagr					;checkagr <= 3 and no highlight: PenRoughing or PenCrossChk (d0 = penalty
									;roll)
	lda.b d0
	cmp.w #$0004
	bcs .dn2
	lda.w gmode
	bit.w #gmhl
	bne .dn2
	lda.w seed+3
	and.w #$0002
	clc
	adc.w #PenRoughing
	sta.b d0
	jsl.l AddPenalty
.dn2:								; far branch to FallDown
	jmp.w FallDown
.list:								;check anim by direction
	dw SPAshoulderchkl,SPAshoulderchkr,SPAhipchkr,SPAhipchkr,SPAhipchkr,SPAhipchkl,SPAhipchkl,SPAshoulderchkl
