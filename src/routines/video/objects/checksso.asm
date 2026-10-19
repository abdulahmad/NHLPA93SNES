checksso:							;Draw the arrows that show where the two players are when they are off
									;screen
	lda.w #2						; player 1: ffo 1, sso 0, SPFarrow
	sta.b a0						; a0 = pad object, a3 = sso
	stz.b a3						; player 1 uses sso 0
	lda.w #SPFarrow
	sta.b d3						; first arrow frame
	jsl.l .ca						; draw it
	inc.b a0
	inc.b a0
	inc.b a3
	inc.b a3
	lda.w #SPFarrow+3				; player 2: SPFarrow+3
	sta.b d3
	jsl.l .ca						; draw it
.rtl:								; return
	rtl
.ca:								;a0 = pad object (ffo index), a3 = sso, d3 = first arrow frame
	ldy.b a0
	lda.w ffoz,y					; pad object height
	bmi .rtl						; hidden: no arrow
	ldx.b a3
	lda.w #$FFFF					; frame -1: no arrow
	sta.w ssoframe,x				; clear the arrow
	lda.w ffox,y					; pad x
	sta.b d0						; d0 = x
	lda.w ffoy,y					; pad y
	sta.b d1						; d1 = y
	lda.w sfhormode					; horizontal rink?
	beq .nhor
	lda.b d1						; horizontal rink: x = -y, y = x - $C5
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	lda.w ffox,y
	sec
	sbc.w #$C5
	sta.b d1
	bra .hord
.nhor:								; subtract the horizontal scroll
	lda.b d0
	sec								; x minus the scroll x
	sbc.w Hpos
	sta.b d0
	lda.b d1
	sec								; y minus the scroll y
	sbc.w Vpos
	sta.b d1
.hord:								;d2 = off-screen directions as joystick bits
	stz.b d2
	lda.b d0						; screen x
	sec
	sbc.w #116						; right of the screen
	bmi .r0
	bvc .rb
	bra .0
.r0:								; signed compare: overflow flag corrects the sign
	bvc .0
.rb:
	lda.w #8						; right bit
	sta.b d2
.0:									; left edge
	lda.b d0
	sec								; screen x
	sbc.w #-116						; left
	beq .lb
	bmi .neg
	bvs .lb
	bra .1
.neg:								; signed compare: overflow flag corrects the sign
	bvs .1
.lb:
	lda.w #4						; left bit
	tsb.b d2
.1:									; top edge
	lda.b d1
	sec								; screen y
	sbc.w #100						; above
	bmi .u0
	bvc .ub
	bra .2
.u0:								; signed compare: overflow flag corrects the sign
	bvc .2
.ub:
	inc.b d2						; up bit
.2:									; bottom edge
	lda.b d1
	sec
	sbc.w #-100						; below
	beq .db
	bmi .d0
	bvs .db
	bra .3
.d0:								; signed compare: overflow flag corrects the sign
	bvs .3
.db:
	inc.b d2						; down bit
	inc.b d2
.3:
	ldx.b d2						; on screen: no arrow
	bne .off
	jmp.w .rtl
.off:
	lda.l jdtab8F,x					; direction 0-7
	and.w #$00FF
	asl a							; times 8 bytes
	asl a
	asl a
	tax
	lda.l .tab,x					; .tab: x spot (0 = keep), y spot, frame add, flip bits
	beq .4
	sta.b d0						; spot x
.4:
	lda.b d0						; x spot
	clc
	adc.w #$0100
	ldy.b a3
	sta.w ssox,y					; store x
	lda.l .tab+2,x					; table y
	beq .5
	sta.b d1						; spot y
.5:
	lda.b d1						; y spot
	eor.w #$FFFF					; negate
	inc a
	clc
	adc.w #$00F0					; screen y
	sta.w ssoy,y
	lda.b d3						; first frame
	clc
	adc.l .tab+4,x					; plus the table frame
	sta.w ssoframe,y				; store frame
	lda.l .tab+6,x					; flip bits
	sta.w ssoattr,y					; store the attribute
	ldx.b a3
	lda.w ssox,x					; sso x
	sec
	sbc.w #$0080					; minus 128
	sta.b sprx						; sprite x
	lda.w ssoy,x
	sec								; sso y
	sbc.w #$0080
	sta.b spry						; sprite y
	lda.w ssoframe,x
	sta.b sprframe					; sprite frame
	lda.w ssoattr,x
	and.w #attrxflip				; flip bits
	sta.b sprhflip					; horizontal flip
	lda.w ssoattr,x
	and.w #$1000					; vertical flip
	sta.b sprvflip
	jml.l addframe					; draw it
.tab:								;x spot, y spot, frame add, flip bits per
									;direction (.xspot 116, .yspot 100)
	dw 0,100,0,$0000
	dw 116,100,1,$0000
	dw 116,0,2,$0000
	dw 116,-100,1,$1000
	dw 0,-100,0,$1000
	dw -116,-100,1,$1800
	dw -116,0,2,$0800
	dw -116,100,1,$0800
