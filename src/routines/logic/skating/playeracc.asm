playeracc:							;Accelerate player X in direction d2 by his weight and leg strength, up to
									;his top speed; uses energy
	asl.b d2						; 4 bytes per direction entry
	asl.b d2
	ldx.b d2
	lda.l dirtab8F+2,x				; y increment of the direction
	sta.b mula
	lda.b d7
	sta.b mulb
	jsl.l muls16					; signed multiply
	lsr a							; scale down by 4
	lsr a
	bit.w #$2000
	beq .sx
	ora.w #$C000
.sx:								; x increment of the direction
	sta.b d1
	lda.l dirtab8F,x				; x increment of the direction
	sta.b mula
	lda.b d7
	sta.b mulb
	jsl.l muls16					; signed multiply
	lsr a
	lsr a
	bit.w #$2000
	beq .sy
	ora.w #$C000
.sy:								; y increment of the direction
	sta.b d0
	ldx.b a3
	lda.w Wallsin,x					; wall normal y: don't push into the wall
	beq .nox
	eor.b d0
	bpl .nox
	stz.b d0						; pushing into the wall in x: cancel x
.nox:								; y axis wall check
	lda.w Wallcos,x					; wall normal x
	beq .noy
	eor.b d1
	bmi .noy
	stz.b d1						; pushing into the wall in y: cancel y
.noy:								; acceleration factor from weight and leg strength
	lda.w weight,x					; weight / 16
	lsr a
	lsr a
	lsr a
	lsr a
	eor.w #$FFFF					; negate
	inc a
	clc
	adc.w #$0020
	clc
	adc.w legstr,x					; plus leg strength
	sta.b d2
	lda.w position,x
	bne .ng							; goalies add leg strength again plus 8
	lda.b d2
	clc
	adc.w legstr,x
	clc
	adc.w #$0008
	sta.b d2
.ng:								; negative acceleration
	lda.b d2
	pha								; keep the acceleration factor
	sta.b mula
	lda.b d0
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lsr.b mulres+2
	ror a
	lsr.b mulres+2
	ror a
	lsr.b mulres+2
	ror a
	lsr.b mulres+2
	ror a
	lsr.b mulres+2
	ror a
	sta.b mula						; increment * factor / 32
	lda.b d7
	sta.b mulb
	jsl.l muls16					; signed multiply
	adc.w Xvel,x					; new velocity = old + increment
	sta.b d0
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b d2
	lda.b mulres+2
	sta.b d2+2
	pla
	sta.b mula
	lda.b d1
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lsr.b mulres+2
	ror a
	lsr.b mulres+2
	ror a
	lsr.b mulres+2
	ror a
	lsr.b mulres+2
	ror a
	lsr.b mulres+2
	ror a
	sta.b mula
	lda.b d7
	sta.b mulb
	jsl.l muls16					; signed multiply
	adc.w Yvel,x					; new y velocity = old + increment
	sta.b d1
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	adc.b d2						; d3 = sum of the squares
	sta.b d3
	lda.b mulres+2
	adc.b d2+2
	sta.b d3+2
	lda.b d1
	pha
	lda.b d0
	pha
	jsl.l getpde					; energy of this player
	lda.w legspd,x					; leg speed
	sta.b mula
	lda.b d0
	lsr a
	clc
	adc.w #$0800
	sta.b mulb
	jsl.l mulu						; mulres = mula * mulb
	asl a
	rol.b mulres+2
	asl a
	rol.b mulres+2
	asl a
	rol.b mulres+2
	asl a
	rol.b mulres+2
	lda.b mulres+2
	asl a
	asl a
	tax
	lda.l MaxSpeed,x				; max speed squared for the rating level
	sta.b d2
	lda.l MaxSpeed+2,x
	sta.b d2+2
	ldx.b a3
	pla
	sta.b d0
	pla
	sta.b d1
	lda.b d2						; max speed check
	cmp.b d3
	lda.b d2+2
	sbc.b d3+2
	bcc .sube						; too fast: keep the old velocity
	lda.b d0
	sta.w Xvel,x					; store the new velocity
	lda.b d1
	sta.w Yvel,x
.sube:								; energy only drains when line changes are on
	lda.w OptLine					; energy only drains when line changes are on
	bne .rtl
	lda.w seed						; random value
	and.w #$003F
	bne .rtl						; only 1 call in 64
	jsl.l getpde
	lda.b d0
	sec
	sbc.w #$0021					; lower the energy by 33
	sta.b d0
	sec
	sbc.w #$0C00
	bmi .neg						; below $C00: just lower it
	bvc .add
.set:								; far branch to setpde
	jmp.w setpde
.neg:								; signed compare: overflow flag corrects the sign
	bvc .set
.add:								; above $C00: also add the endurance
	lda.w endurance,x				; above $C00: also add the endurance byte
	sta.b d2
	clc
	adc.b d0
	sta.b d0
	jmp.w setpde
.rtl:								; return
	rtl
