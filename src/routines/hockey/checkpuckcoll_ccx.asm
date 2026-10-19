checkpuckcoll_ccx:					;Puck contact with a player's stick, body or the goalie
	stx.b xsave						; keep the caller's X
	ldx.w #$0000
.save:								; save d0 through a3 (14 words) on the stack
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$001C
	bne .save
	ldx.b xsave						; restore X
	lda.b d4						; a2 = object
	sta.b a2
	tay								; Y = object index
	lsr a							; object number
	cmp.w puckc						; the puck carrier never collides
	bne .pl
	jmp.w .exit
.pl:								; only objects 0-11 are players
	cmp.w #$000C					; not a player
	bcc .nc
	jmp.w .exit
.nc:								; a player
	lda.w pfnc,y					; no collision or nopuck
	ora.w nopuck,y
	beq .unav						; collision allowed: go on
	jmp.w .exit
.unav:								; available?
	lda.w pflags,y					; player flags
	bit.w #pf2unav					; pf2unav: body only
	beq .z
	jmp.w .chkbody
.z:									; available player: the stick needs a low, slow puck
	lda.w Zpos+puckobj
	sec
	sbc.w #$0005					; puck above 5
	beq .zv							; Zpos = 5: low enough
	bmi .neg						; negative result: .neg checks the overflow
	bvs .zv							; positive with overflow: really below 5
.body1:								; puck too high for the stick: test the body
	jmp.w .chkbody
.neg:								; negative result
	bvs .body1						; overflow: really above 5
.zv:								; puck is low
	lda.w puckvz					; puck's vertical speed
	sec
	sbc.w #$0100					; puckvz > $100
	beq .stick						; = $100: slow enough
	bmi .neg1						; negative result: .neg1 checks the overflow
	bvs .stick						; positive with overflow: really below $100
.body2:								; puck rising too fast for the stick: test the body
	jmp.w .chkbody
.neg1:								; negative result
	bvs .body2						; overflow: really above $100
.stick:								; test the stick: its hot spot against the puck
	tya								; object offset
	jsl.l GetHot					; d0 / d1 = stick hot spot of the object's current frame
	ldy.b a2						; Y = the object again
	lda.b d0						; stick x offset
	clc
	adc.w Xpos,y					; plus the player's x
	sec
	sbc.w puckx						; minus the puck's x: dx
	sta.b d0
	bit.w #$8000
	beq .sx
	eor.w #$FFFF
	inc a
.sx:
	cmp.w #$000F					; stick: within 14
	bcs .chkbody					; more than 14 away in x: stick missed
	lda.b d1						; stick y offset
	clc
	adc.w Ypos,y					; plus the player's y
	sec
	sbc.w pucky						; minus the puck's y: dy
	sta.b d1
	bit.w #$8000
	beq .sy
	eor.w #$FFFF
	inc a
.sy:
	cmp.w #$000F
	bcs .chkbody
	lda.b d0						; square dx (signed 32-bit result in mulres)
	sta.b mula
	sta.b mulb
	jsl.l muls32
	sta.b d0
	lda.b mulres+2
	sta.b d0+2
	lda.b d1						; square dy
	sta.b mula
	sta.b mulb
	jsl.l muls32
	adc.b d0
	sta.b d0
	lda.b d0+2
	adc.b mulres+2
	sta.b d0+2
	lda.w #$00C4					; cstick^2 ($C4), /4 if the puck is not ready to be caught
	sta.b d1
	lda.w nopuck+puckobj
	bmi .lo
	beq .lo
	lsr.b d1
	lsr.b d1
.lo:								; stick radius squared in d1 against dist squared
	lda.b d1
	cmp.b d0
	lda.w #$0000
	sbc.b d0+2
	bcc .chkbody					; dist^2 is larger: stick missed, test the body
	jsl.l puckstick					; stick contact
	bra .exit
.chkbody:							; stick missed: test the body
	lda.w position,y				; position 0 is the goalie
	beq .chkgoalie					; goalie: its own test
	lda.w Xpos,y					; player body x
	sec
	sbc.w puckx
	sta.b d0
	bit.w #$8000
	beq .bx
	eor.w #$FFFF
	inc a
.bx:
	cmp.w #$0009					; body: within 8
	bcs .exit						; more than 8 away in x: no contact
	lda.w Ypos,y					; body y
	sec
	sbc.w pucky
	sta.b d1
	bit.w #$8000
	beq .by
	eor.w #$FFFF
	inc a
.by:
	cmp.w #$0009
	bcs .exit						; more than 8 away in y: no contact
	lda.b d0						; dist squared of the body
	sta.b mula
	sta.b mulb
	jsl.l muls32
	sta.b d0
	lda.b mulres+2
	sta.b d0+2
	lda.b d1
	sta.b mula
	sta.b mulb
	jsl.l muls32
	adc.b d0
	sta.b d0
	lda.b d0+2
	adc.b mulres+2
	sta.b d0+2
	lda.b d0						; body radius squared against dist squared
	cmp.w #$0041					; cbody^2
	lda.b d0+2
	sbc.w #$0000
	bcs .exit						; dist^2 greater than 64: no contact
	jsl.l puckbody
.exit:								; restore the registers and return
	stx.b xsave
	ldx.w #$001A
.restore:							; pull d0 through a3 back from the stack
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave
	rtl
.chkgoalie:							; goalie: test a box around the puck
	lda.w Xpos,y					; goalie x
	sec
	sbc.w puckx
	sta.b d0
	bit.w #$8000
	beq .gx
	eor.w #$FFFF
	inc a
.gx:
	cmp.w #$000D					; goalie: within 12
	bcs .exit						; more than 12 away in x: no contact
	lda.w Ypos,y					; goalie y
	sec
	sbc.w pucky
	sta.b d1
	bit.w #$8000
	beq .gy
	eor.w #$FFFF
	inc a
.gy:
	cmp.w #$000D
	bcs .exit						; more than 12 away in y: no contact
	jsl.l puckgoalie				; within the box: the goalie handles the puck
	bra .exit
