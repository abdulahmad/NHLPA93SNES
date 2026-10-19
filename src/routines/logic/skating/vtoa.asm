vtoa:								;d0 = the direction (0-7, 8 = none) of the x / y distances d0 / d1
	lda.b d0						; vector
	ora.b d1						; zero
	beq .nodir						; no direction
	stz.b d0+2						; sign bits
	lda.b d0						; dx
	bpl .0							; positive
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	inc.b d0+2						; sign bit 0
.0:
	lda.b d1						; dy
	bpl .1							; positive
	eor.w #$FFFF					; negate
	inc a
	sta.b d1
	inc.b d0+2						; sign bits
	inc.b d0+2
.1:
	lda.b d1						; bit 2: |dx| <= 2|dy|
	asl a							; 2|dy| >= |dx|
	cmp.b d0
	bcc .2
	lda.w #$0004					; set bit 2
	tsb.b d0+2
.2:
	lda.b d0						; bit 3: |dy| <= 2|dx|
	asl a							; 2|dx| >= |dy|
	cmp.b d1
	bcc .3
	lda.w #$0008					; set bit 3
	tsb.b d0+2
.3:
	phx								; keep X
	ldx.b d0+2						; index
	lda.l .dt,x						; direction
	plx								; restore X
	and.w #$00FF
	sta.b d0
	rtl
.nodir:
	lda.w #$0008					; none
	sta.b d0
	rtl
.dt:								;direction for each sign/ratio combination
	db 1,7,3,5,0,0,4,4,2,6,2,6,1,7,3,5
