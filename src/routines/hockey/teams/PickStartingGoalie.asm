PickStartingGoalie:					;Pick team a2's starting goalie; computer teams in the later playoff
									;rounds pick one at random by the
		;   scouting report weights
	stx.b xsave						; keep X
	ldx.w #$0000					; save d0 and a0
.save:								; save d0 and the words after it (2 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0004
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0000
.savea:								; save a0 and the words after it (2 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0004
	bne .savea
	ldx.b xsave						; restore X
	ldy.b a2						; team index
	lda.w #$0000					; default: first goalie
	sta.w tmgoalie,y
	jsl.l FigureJoy					; set up the joystick assignment
	lda.b a2
	tay
	lsr a
	inc a
	sta.b d0						; d0 = controller team number
	cmp.w cont1team					; a controller team: keep goalie 0
	beq .x							; human team: keep the choice
	cmp.w cont2team
	beq .x
	stz.b d0
	lda.w gamelevel					; game level: playoffs?
	sec
	sbc.w #$0002
	beq .po
	bmi .neg
	bvs .po
	bra .set
.neg:								; signed compare: overflow flag corrects the sign
	bvs .set
.po:								; playoff mode: pick from the team list
	lda.w OptLine
	bne .set
	lda.w #TeamList					; team data for the pick
	sta.b a0
	lda.w #TeamList>>16
	sta.b a0+2
	lda.w tmshots,y
	asl a
	asl a
	tay
	lda.b [a0],y
	sta.b a0
	ldy.w #GoalieOdds
	adc.b [a0],y
	sta.b a0
	lda.w #$0004
	sta.b d0
	jsl.l UnpackNibbles
	jsl.l WeightedRandomSelect
.set:								; store the starting goalie
	ldy.b a2
	lda.b d0
	sta.w tmgoalie,y
.x:									; restore registers
	stx.b xsave						; keep X
	ldx.w #$0002
.resta:								; pull a0 and the words after it back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0002
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
