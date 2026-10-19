doshot:								;The stick is at the puck: launch it toward the goal
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								;movem d0-d7/a0-a3 to the stack
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0020
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
	jsl.l shotdiradj
	lda.w seed						; sound: wiff (one of 4)
	and.w #$0003
	clc
	adc.w #SFXshotwiff
	pha
	lda.w #sfssdir
	trb.w sflags					; sfssdir off, pfalock on
	sta.w pfalock,x
	txa
	lsr a
	sta.w shotplayer
;did the shooter still have the puck?
	cmp.w puckc						; wiffed shot
	beq .hit
	jmp.w .ex
.hit:								;player has the puck: shot taken
	lda.w #SFXshotfh				; forehand shot sound
	sta.b $01,s
	lda.w #sf2shot					; sf2shot
	tsb.w sflags
	lda.w SPA,x
	cmp.w #SPAshotb
	bne .nbh
	lda.w #SFXshotbh				; backhand: sound, 25% less speed
	sta.b $01,s
	lda.w passspeed
	lsr a
	lsr a
	eor.w #$FFFF					; negate
	inc a
	clc
	adc.w passspeed
	sta.w passspeed
.nbh:								; normal shot: check the pass speed
	lda.w passspeed
	cmp.w #$0032					; hard shot sound
	bcc .speed
	lda.w #SFXshothard
	sta.b $01,s
.speed:								;passspeed = passspeed*(makepde(shotspd)+$14)*$2570/$10000
	lda.w shotspd,x
	sta.b d0
	stx.b a0
	jsl.l makepde
	adc.w #$0014
	sta.b mulb
	lda.w passspeed
	sta.b mula
	jsl.l mulu16					; mulu, mulres = mula*mulb
	lda.w #$2570
	sta.b mula
	jsl.l mulu						; mulres = mula*mulb
	lda.b mulres+2
	sta.w passspeed
	lda.w #$FFFF					; puck loose
	sta.w puckc
	lda.w #$0010					; no puck pickup for 16 frames
	sta.w nopuck,x
	txa
	lsr a
	sta.w lastplayer
;d1 = target goal y; (d0,d2) = x and z offsets for this direction from shotsets
	lda.w #blueline+goalline
	sta.b d1
	lda.w pfgoal,x
	bne .0
	lda.w #-(blueline+goalline)
	sta.b d1
.0:									;d0/d1 = shotsets[passdir] - puck, d2 = height; d3 = distance to the goal
	lda.w passdir
	asl a
	asl a
	tay
	lda.w #shotsets
	sta.b a0
	lda.w #shotsets>>16
	sta.b a0+2
	lda.b [a0],y
	sec
	sbc.w puckx
	sta.b d0
	iny
	iny
	lda.b [a0],y
	sta.b d2
	pha
	lda.b d1
	sec
	sbc.w pucky
	sta.b d1
	pha
;d3 = distance to the target point
	lda.b d0
	pha
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b d0
	lda.b mulres+2
	sta.b d0+2
	lda.b d1
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	adc.b d0
	sta.b d0
	lda.b mulres+2
	adc.b d0+2
	sta.b d0+2
	jsl.l sroot
	bne .1
	inc a
.1:									; keep the shot distance
	sta.b d3
	lda.w gmode
	bit.w #gmhl						; gmhl: highlights are always perfect
	beq .chkperf
	jmp.w .perf
.chkperf:							; perfect shot distance check
	lda.b d3
	cmp.w #$00C9					; too far away for a perfect shot
	bcs .notperf
	lda.w #$0010
	adc.w shotacc,x
	jsl.l randoma					; random number 0 to A-1
	cmp.w #$000F					; chance of a perfect shot
	bcs .perf
.notperf:							;aim error from passspeed, shotacc and distance
	lda.w passspeed
	lsr a
	lsr a
	lsr a
	sec
	sbc.w shotacc,x
	clc
	adc.w #$0010
	sta.b mulb
	lda.b d3
	sta.b mula
	jsl.l mulu16					; mulu, mulres = mula*mulb
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	sta.b d0
	lda.b d3
	cmp.w #$00FB					; closer than 251: half the error
	bcs .cp
	lsr.b d0
.cp:								; clamp the aim X to the sideline
	lda.b d0
	cmp.w #sideline					; clamp $88
	bcc .ar
	lda.w #sideline
	sta.b d0
.ar:								; random aim error
	lda.b d0
	pha
	jsl.l randomas					; random number -A to A-1
	adc.b $03,s
	sta.b $03,s
	lda.b $01,s
	sta.b d0
	cmp.w #$003D					; max 60
	bcc .ay
	lda.w #$003C
	sta.b d0
	sta.b $01,s
.ay:								; scale the aim error in Y
	lda.b $05,s
	bpl .am
	lsr.b d0
.am:								; y dist += random error
	jsl.l randomd0s					; randomas on d0
	lda.b $05,s
	adc.b d0
	sta.b $05,s
	pla
	lsr a
	jsl.l randoma					; random number 0 to A-1
	adc.b $05,s
	sta.b $05,s
.perf:								;puckvx/puckvy = passspeed*$44*dx/d3 and dy/d3; puckvz from the height
	lda.w passspeed
	sta.b mulb
	lda.w #$0044					; 1024/15
	sta.b mula
	jsl.l muls16					; signed multiply
	pla
	sta.b mula
	jsl.l muls32					; signed 32-bit multiply
	lda.b d3
	sta.b mula
	jsl.l divs						; signed divide
	asl a
	sta.w puckvx
	lda.w passspeed
	sta.b mulb
	lda.w #$0044
	sta.b mula
	jsl.l muls16					; signed multiply
	pla
	sta.b mula
	jsl.l muls32					; signed 32-bit multiply
	lda.b d3
	sta.b mula
	jsl.l divs						; signed divide
	asl a
	sta.w puckvy
	pla
	beq .ex
	sta.b mulb
	lda.w passspeed
	sta.b mula
	jsl.l mulu16					; mulu, mulres = mula*mulb
	lda.w #$0044
	sta.b mula
	jsl.l mulu						; mulres = mula*mulb
	lda.b d3
	sta.b mula
	jsl.l divu
	asl a
	sta.b d1
	lda.w #$0B33
	sta.b mula
	lda.b d3
	sta.b mulb
	jsl.l mulu						; mulres = mula*mulb
	lda.w passspeed
	sta.b mula
	jsl.l divu
	lsr a
	adc.b d1
	cmp.w #$1801
	bcc .noup
	lda.w #$1800					; max $1800
.noup:								; store the Z velocity
	sta.w puckvz
.ex:								;play the sound, movem the registers back
	jsl.l sfx
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
	ldx.w #$001E
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	ldx.b a3
	lda.w #blueline+goalline		; puckvy sign toward the shooting goal
	sta.b tmp0
	lda.w pfgoal,x
	bne .side
	lda.w #-(blueline+goalline)
	sta.b tmp0
.side:								; side of the net the puck is on
	lda.b tmp0
	sec
	sbc.w pucky
	eor.w puckvy
	bpl .rtl
	lda.w puckvy
	eor.w #$FFFF					; negate
	inc a
	sta.w puckvy
.rtl:								; return
	rtl
