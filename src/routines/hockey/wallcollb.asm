wallcollb:							;Object X hits a wall: the puck may go over the glass and out of play (a
									;stoppage), else it bounces
	cpx.w #$001C					; not the puck: wallcoll
	beq .puck
	jmp.w wallcoll
.puck:								; puck above the glass?
	lda.w Zpos+puckobj
	sec
	sbc.w #$0020					; Zpos > 32: over
	beq .z1
	bmi .neg
	bvs .z1
	bra .0
.neg:								; signed compare: overflow flag corrects the sign
	bvs .0
.z1:								; puck low enough to hit the wall
	lda.w Zpos+puckobj
	cmp.w #$0016					; Zpos <= 21: wallcoll
	bcs .y280
	jmp.w wallcoll
.y280:								; puck Y at the end boards
	lda.w pucky
	sec
	sbc.w #$0112					; y >= 274
	bmi .neg1
	bvc .x13
	bra .0
.neg1:								; signed compare: overflow flag corrects the sign
	bvc .0
.x13:								; puck X in the goal mouth range
	lda.w puckx
	sec
	sbc.w #$000D					; x 13-15 (the goal mouth)
	bmi .neg2
	bvc .x15
.wc1:								; far branch to wallcoll
	jmp.w wallcoll
.neg2:								; signed compare: overflow flag corrects the sign
	bvc .wc1
.x15:								; puck X upper limit
	lda.w puckx
	sec
	sbc.w #$000F
	beq .vy
	bmi .neg3
	bvs .vy
	bra wallcoll
.neg3:								; signed compare: overflow flag corrects the sign
	bvs wallcoll
.vy:								; Y velocity check
	lda.w puckvy
	sec
	sbc.w #$0FA0					; Yvel >= $FA0
	bmi .neg4
	bvc .glass
	bra wallcoll
.neg4:								; signed compare: overflow flag corrects the sign
	bvc wallcoll
.glass:								;over the glass at the goal: shadow animation, sound, crowd
	phx
	lda.w puckvy					; halve puckvy
	pha
	asl a
	pla
	ror a
	sta.w puckvy
	inx
	inx
	stx.b a3
	lda.w #SPAbglass				; object 15 (shadow): SPAbglass
	sta.b d1
	jsl.l SetSPA					; start animation d1
	plx
	stx.b a3
	lda.w #SFXbglass				; over the glass sound
	pha
	jsl.l sfx
	lda.b crowdlevel				; crowd +600
	clc
	adc.w #$0258
	sta.b crowdlevel
.0:									;puck out of play
	lda.w #sfslock					; sfslock; puck pfnc
	tsb.w sflags
	sta.w pfnc+puckobj
	lda.w pucky						; bottom: y flip
	bpl .1
	lda.w #$8000
	tsb.w attribute+puckobj
.1:
	stz.w frame+$1E					; shadow frame 0
	lda.w gmclock					; clock stopped
	bne .rtl
	lda.w ltplayer					; penalty 6 for the last touch player
	asl a
	sta.b a3
	tax
	lda.w #PenOOP
	sta.b d0
	jsl.l AddPenalty2
	ldx.w #$001C
	stx.b a3
.rtl:								; return
	rtl
