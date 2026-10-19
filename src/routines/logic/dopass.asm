dopass:								;Pass the puck in the pass direction, to the best teammate there if any
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
	stx.b xsave						; keep X
	ldx.w #$0000
.savea:								; save a0 and the words after it (4 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0008
	bne .savea
	ldx.b xsave						; restore X
	lda.w seed+2					; random sound variant 0-3
	and.w #$0003
	clc
	adc.w #$0098					; pass sound $98 + variant
	pha
	jsl.l sfx						; play the sound
	lda.w #$0004					; sflags bit $0004
	trb.w sflags					; cleared
	lda.w #$FFFF					; puckc = -1: puck not held
	sta.w puckc
	lda.w #$0010
	sta.w nopuck,x					; brief pickup lockout
	txa
	lsr a
	sta.w lastplayer				; remember the last player
	lda.w #$0007					; goalie: speed value 7
	sta.b d0
	lda.w position,x				; goalie?
	beq .pa
	lda.w passacc,x					; skater: passacc
	sta.b d0
.pa:
	lda.b d0
	asl a
	asl a
	adc.w #$0090					; passspeed = passacc * 4 + $90
	sta.w passspeed
	lda.w #$FFFF					; no candidate yet
	sta.b d4+2
	lda.w #$0005					; 6 players
	sta.b d3
	stz.b a1						; a1 = first player of the team
	cpx.w #$000C					; second team?
	bcc .0
	lda.w #$000C					; second team starts at $0C
	sta.b a1
.0:
	cpx.b a1						; don't pass to yourself
	bne .1
	jmp.w .next
.1:
	ldy.b a1
	lda.w position,y				; don't pass to the goalie
	bne .2
	jmp.w .next
.2:
	lda.w pflags,y
	bit.w #pf2unav					; player is unavailable
	beq .3
	jmp.w .next
.3:
	lda.w Ypos,y					; candidate y minus puck y
	sec
	sbc.w pucky
	sta.b d1
	pha
	lda.w Xpos,y					; candidate x minus puck x
	sec
	sbc.w puckx
	sta.b d0
	pha
	jsl.l vtoa						; vector to direction
	pla
	sta.b d1
	pla
	sta.b d2
	lda.b d0
	sec
	sbc.w passdir
	and.w #$0007					; difference from passdir, 0-7
	asl a
	asl a
	asl a
	asl a
	asl a
	and.w #$00FF
	bit.w #$0080
	beq .sx
	ora.w #$FF00
.sx:
	asl a							; angle error scaled
	asl a
	asl a
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b d0
	cmp.w #$0001
	lda.b mulres+2
	sta.b d0+2
	sbc.w #$0001
	bcs .next						; more than one step off passdir: skip
	lda.b d1
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b d1
	lda.b mulres+2
	sta.b d1+2
	lda.b d2
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	adc.b d1						; d2 = dx squared + dy squared
	sta.b d2
	lda.b mulres+2
	adc.b d1+2
	sta.b d2+2
	lda.b d2
	clc
	adc.b d0						; plus the angle error squared
	sta.b d2
	lda.b d2+2
	adc.b d0+2
	sta.b d2+2
	lda.b d4
	cmp.b d2						; better than the best so far?
	lda.b d4+2
	sbc.b d2+2
	bcc .next						; no: skip
	lda.b d2
	sta.b d4
	lda.b d2+2
	sta.b d4+2
	lda.b a1						; best teammate so far
	sta.b a0
.next:
	inc.b a1						; next teammate
	inc.b a1
	dec.b d3
	bmi .done						; all six checked
	jmp.w .0
.done:
	lda.b d4+2						; a player found?
	bmi .nopp
	jsl.l passtoa0					; pass to a0
	jmp.w .exit
.nopp:
	lda.w passdir
	asl a
	asl a
	adc.w #dirtab+2					; y increment of the pass direction
	sta.b a0
	lda.w #dirtab>>16
	sta.b a0+2
	lda.b [a0]
	sta.b mulb
	lda.w passspeed
	sta.b mula
	jsl.l muls32					; signed 32-bit multiply
	stz.b mulb
	lda.b mulres
	sta.b mulb+1
	lda.b mulres+2
	sta.b mulb+3
	asl.b mulb
	rol.b mulb+2
	asl.b mulb
	rol.b mulb+2
	lda.w #runspeed*15				; divide by runspeed * 15
	sta.b mula
	jsl.l divs						; signed divide
	adc.w Yvel,x					; plus the passer's y velocity
	sta.w puckvy					; puck y velocity
	dec.b a0
	dec.b a0
	lda.b [a0]						; x increment of the pass direction
	sta.b mulb
	lda.w passspeed
	sta.b mula
	jsl.l muls32					; signed 32-bit multiply
	stz.b mulb
	lda.b mulres
	sta.b mulb+1
	lda.b mulres+2
	sta.b mulb+3
	asl.b mulb
	rol.b mulb+2
	asl.b mulb
	rol.b mulb+2
	lda.w #runspeed*15
	sta.b mula
	jsl.l divs						; signed divide
	adc.w Xvel,x					; plus the passer's x velocity
	sta.w puckvx					; puck x velocity
	lda.w #$1000					; random vertical velocity up to $1000
	jsl.l randoma					; random number 0 to A-1
	sta.w puckvz					; puck z velocity
.exit:
	lda.w position,x				; goalie?
	bne .notgoalie
	lda.w pfgoal,x					; which end he defends
	beq .g0
	lda.w puckvy					; goalie pass always goes up ice
	bmi .nvy
	bra .notgoalie
.g0:
	lda.w puckvy
	bmi .notgoalie
.nvy:
	eor.w #$FFFF					; negate
	inc a
	sta.w puckvy
.notgoalie:
	lda.w puckvx					; puck velocity to direction
	sta.b d0
	lda.w puckvy
	sta.b d1
	jsl.l vtoa						; vector to direction
	lda.w #SPAgswing				; goalie swing animation
	sta.b d1
	lda.w position,x
	beq .e1
	lda.w #SPApassf					; pass animation forehand
	sta.b d1
	jsl.l Findhittype				; backhand?
	beq .e1
	lda.w #SPApassb					; pass animation backhand
	sta.b d1
.e1:
	jsl.l SetSPA					; start animation d1
	lda.w #$0001					; lock the assignment
	sta.w pfalock,x
	stx.b xsave						; keep X
	ldx.w #$0006
.resta:								; pull a0 and the words after it back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0016					; restore d0 and the words after it
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
