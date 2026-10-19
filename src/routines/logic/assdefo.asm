assdefo:							;Assignment: a defenseman on offense holds the blue line on his side; back
									;to defense when offsides, when
		;   the puck goes back past the line or when the other team has it
	lda.w pfalock,x					; assignment locked?
	beq .clk
	jmp.w .rtl
.clk:
	lda.w gmclock					; clock stopped: do nothing
	beq .bench
	jml.l assnothing
.bench:
	jsl.l check4bench				; check for a bench change
	lda.w pflags,x
	bit.w #pfjoycon					; human controlled player?
	beq .na
	jmp.w .rtl
.na:
	bit.w #pfna						; assignment just started?
	beq .nna
	and.w #~pfna&$FFFF
	sta.w pflags,x
	stz.w temp1,x					; reset the timers
	stz.w temp2,x
	lda.w #$0008					; temp2b = 8
	sta.w temp2b,x
.nna:
	lda.w temp1,x					; countdown timer
	sec
	sbc.b d7						; minus the frame count
	sta.w temp1,x
	bpl .nodec						; still counting
	clc
	adc.w aioff,x					; reload from aioff
	bpl .store
	lda.w #$0000					; not below zero
.store:								; store the re-think timer
	sta.w temp1,x
	lda.w #2						; adefd
	sta.b d0
	ldy.b a2						; team of this player
	lda.w tmflags,y					; offsides: defend
	bit.w #tmfoside
	beq .on
	jml.l assreplace				; replace the assignment with d0
.on:								; puck y becomes the target
	lda.w pucky
	sta.b d1
	lda.w pfgoal,x
	bne .de1
	lda.b d1
	eor.w #$FFFF					; negate
	inc a
	sta.b d1
.de1:
	lda.b d1						; the puck back behind the blue line
	sec
	sbc.w #$5D						; line at $5D
	bmi .neg
	bvc .pc
.def:
	jml.l assreplace				; replace the assignment with d0
.neg:								; signed compare: overflow flag corrects the sign
	bvc .def
.pc:
	lda.w puckc						; the other team has the puck
	bmi .nodec						; negative: nobody has it
	sec
	sbc.w #6						; puck side
	sta.b d1
	txa
	sec
	sbc.w #12
	eor.b d1						; compare with this player's side
	bpl .nodec
	jml.l assreplace				; replace the assignment with d0
.nodec:
	lda.w #EvadePC					; EvadePC avoidance; spot x +-80 by side, y 98 (blue line + 5)
	sta.b a0
	lda.w #EvadePC>>16
	sta.b a0+2
	lda.w #80						; x 80
	sta.b d0
	lda.w position,x				; position 2: right side
	cmp.w #2
	beq .1
	lda.w #-80						; other side: -80
	sta.b d0
.1:
	lda.w #98						; y 98
	sta.b d1
	lda.w pfgoal,x					; which end
	bne .0
	lda.b d0
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	lda.w #-98						; y -98
	sta.b d1
.0:
	lda.w puckx						; puck x
	eor.b d0						; same side as the target?
	bmi .2
	lda.w puckx						; use the puck x
	bra .set
.rtl:								; return
	rtl
.2:									;halfway to the puck
	lda.w puckx						; puck x
	pha
	asl a
	pla
	ror a
	clc								; plus the target x
	adc.b d0
.set:
	sta.b d0						; target x
	jml.l skateto					; skate there
unused008E:							;unused, zero fill to the end of the bank
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00
