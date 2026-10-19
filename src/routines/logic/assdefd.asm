assdefd:							;Assignment: a defenseman on defense stays between the furthest attacker
									;and his goal, and joins the attack
		;   when the puck is past the line
	lda.w pfalock,x					; assignment locked?
	beq .go
	jmp.w .rtl
.go:
	lda.w gmclock					; clock stopped: do nothing
	beq .gm
	jml.l assnothing
.gm:
	jsl.l check4bench				; check for a bench change
	lda.w pflags,x
	bit.w #pfjoycon					; human controlled player?
	beq .chk
	jmp.w .rtl
.chk:
	bit.w #pfna						; assignment just started?
	beq .nna
	and.w #~pfna&$FFFF
	sta.w pflags,x
	stz.w temp1,x					; reset the timers
	stz.w temp2,x
	lda.w #8						; temp2b = 8
	sta.w temp2b,x
.nna:
	lda.w temp1,x					; countdown timer
	sec
	sbc.b d7						; minus the frame count
	sta.w temp1,x
	bmi .new						; expired: reevaluate
	jmp.w .de3						; still counting: skate on
.new:								; new assignment: reload the timer from aidef
	clc
	adc.w aidef,x					; reload from aidef
	bpl .t1
	lda.w #$0000					; not below zero
.t1:								; store the re-think timer
	sta.w temp1,x
	lda.w pucky						; puck y
	sta.b d1
	lda.w puckvy					; puck y velocity
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	bit.w #$0200					; sign extend
	beq .sx
	ora.w #$FC00
.sx:
	sta.b d3						; d3 = puck y lead
	lda.w pfgoal,x					; team direction
	bne .de00
	lda.b d1						; mirror for the bottom goal
	eor.w #$FFFF					; negate
	inc a
	sta.b d1
	lda.b d3
	eor.w #$FFFF					; negate
	inc a
	sta.b d3
.de00:								;only lead when moving up ice
	lda.b d3
	bpl .v
	stz.b d3
.v:									; puck y plus the lead
	lda.b d3
	clc
	adc.b d1
	sta.b d3						; d3 = puck y plus lead
	sec
	sbc.w #$58						; compare with the line at $58
	bmi .neg
	bvc .pastline
	bra .de0
.neg:								; signed compare: overflow flag corrects the sign
	bvc .de0
.pastline:
	ldy.b a2						; team of this player
	lda.w tmflags,y
	bit.w #tmfoside					; team offsides: stay back
	bne .de0
	lda.w puckc						; puck control
	sta.b d1
	bmi .de0
	jsl.l chkpk						; check the puck
	beq .de0
	lda.w #1						; assignment 1 in d0
	sta.b d0
	lda.b d1
	sec
	sbc.w #6
	sta.b d1
	txa								; player index
	lsr a
	sec
	sbc.w #6
	sta.b d2
	eor.b d1
	sta.b d1
	bmi .de0
	jml.l assreplace				; replace the assignment with d0
.de0:
	lda.w #65						; target x 65
	sta.w temp3,x
	lda.w position,x				; position 2 is the right defenseman
	cmp.w #$0002
	beq .de1
	lda.w #-65						; left defenseman: x -65
	sta.w temp3,x
.de1:
	stz.b a0						; a0 = first opposing player
	cpx.w #12						; X in the second team?
	bcs .de2
	lda.w #12						; a0 = 12
	sta.b a0
.de2:								;find the furthest-up attacker
	lda.w #5						; check 6 players
	sta.b d2
	lda.w #-1000					; start from -1000
	sta.b d0
	lda.w pfgoal,x
	beq .gdwn
	lda.w #1000						; bottom goal: start from 1000
	sta.b d0
.gup:								; each attacker: skip unavailable players
	ldy.b a0
	lda.w pflags,y					; player flags
	bit.w #pf2unav					; skip unavailable players
	bne .gu0
	lda.w position,y				; skip empty positions
	bmi .gu0
	lda.w Yvel,y					; y velocity
	bmi .gu2
	lda.w #$0000
.gu2:
	lsr a							; y velocity / 16
	lsr a
	lsr a
	lsr a
	bit.w #$0800					; sign extend
	beq .gu2s
	ora.w #$F000
.gu2s:								; attacker's projected y (guarding the near attacker)
	clc
	adc.w Ypos,y					; projected y of the attacker
	sta.b d1
	sec
	sbc.b d0
	beq .gu3						; further up than the best so far?
	bmi .neg1
	bvs .gu3
	bra .gu0
.neg1:								; signed compare: overflow flag corrects the sign
	bvs .gu0
.gu3:
	lda.b d1						; new best y
	sta.b d0
.gu0:
	inc.b a0						; next player
	inc.b a0
	dec.b d2						; count down
	bpl .gup
	lda.b d0
	sec
	sbc.w #50						; 50 behind the furthest attacker
	sta.b d0
	sec
	sbc.w #-190						; clamp at -190
	beq .cl1
	bmi .neg2
	bvs .cl1
	bra .gu1
.neg2:								; signed compare: overflow flag corrects the sign
	bvs .gu1
.cl1:
	lda.w #-220						; limit -220
	sta.b d0
.gu1:								; store the target y and continue
	lda.b d0
	sta.w temp4,x					; target y
	lda.w puckx						; puck x
	sta.b d0
	lda.w temp3,x					; temp3 xor puck x
	eor.b d0
	sta.b d1
	bpl .de3
	stz.w temp3,x					; opposite sign to puck x: clear temp3
	bra .de3
.rtl:								; return
	rtl
.gdwn:
	ldy.b a0						; player flags
	lda.w pflags,y
	bit.w #pf2unav					; skip unavailable players
	bne .gd0
	lda.w position,y				; skip empty positions
	bmi .gd0
	lda.w Yvel,y					; y velocity
	bpl .gd2
	lda.w #$0000
.gd2:
	lsr a							; y velocity / 16
	lsr a
	lsr a
	lsr a
	bit.w #$0800					; sign extend
	beq .gd2s
	ora.w #$F000
.gd2s:								; attacker's projected y (guarding the far attacker)
	clc
	adc.w Ypos,y					; projected y of the attacker
	sta.b d1
	sec
	sbc.b d0						; further down than the best so far?
	bmi .neg3
	bvc .gd3
	bra .gd0
.neg3:								; signed compare: overflow flag corrects the sign
	bvc .gd0
.gd3:
	lda.b d1						; new best y
	sta.b d0
.gd0:
	inc.b a0						; next player
	inc.b a0
	dec.b d2						; count down
	bpl .gdwn
	lda.b d0
	clc
	adc.w #50						; 50 behind the furthest attacker
	sta.b d0
	sec
	sbc.w #190						; clamp at 190
	bmi .neg4
	bvc .cl2
	bra .gd1
.neg4:								; signed compare: overflow flag corrects the sign
	bvc .gd1
.cl2:
	lda.w #220						; limit 220
	sta.b d0
.gd1:								; store the target y and continue
	lda.b d0
	sta.w temp4,x					; target y
	lda.w temp3,x
	eor.w #$FFFF					; negate
	inc a
	sta.w temp3,x
	lda.w puckx						; puck x
	sta.b d0
	lda.w temp3,x
	eor.b d0						; temp3 xor puck x
	sta.b d1
	bpl .de3
	stz.w temp3,x					; opposite sign to puck x: clear temp3
.de3:
	lda.w temp3,x					; target x
	sta.b d0
	lda.w temp4,x					; target y
	sta.b d1
	lda.w #EvadePC					; a0 = EvadePC
	sta.b a0
	lda.w #EvadePC>>16
	sta.b a0+2
	jsl.l skateto					; skate to d0, d1
	jml.l check4check				; then check for a check
