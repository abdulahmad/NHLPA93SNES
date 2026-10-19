burst:								;Check button: a speed burst in the facing direction, which costs energy
	jsl.l getpde					; player energy
	lda.w OptLine					; line changes off: no energy cost
	bne .0
	lda.b d0						; energy
	sec
	sbc.w #$00CC					; $1000/20
	sta.b d0
	jsl.l setpde					; store it
.0:									;speed = energy*$233/$10000
	lda.b d0						; energy
	sta.b mula
	lda.w #$0233					; $233
	sta.b mulb
	jsl.l mulu						; mulres = mula*mulb
	lda.b mulres+2					; speed
	sta.b mulb						; keep it
	pha								; and on the stack
	lda.w facedir,x					; facing
	asl a							; times 4: dirtab entry
	asl a
	tay
	lda.w #dirtab					; direction table
	sta.b a0
	lda.w #dirtab>>16
	sta.b a0+2
	lda.b [a0],y					; x component
	iny
	iny
	sta.b mula						; times the speed
	jsl.l muls16					; signed multiply
	adc.w Xvel,x					; plus Xvel
	sta.w Xvel,x
	lda.b [a0],y					; y component
	sta.b mula
	pla								; speed
	sta.b mulb
	jsl.l muls16					; signed multiply
	adc.w Yvel,x					; plus Yvel
	sta.w Yvel,x
	bit.w #$8000					; absolute value
	beq .yabs
	eor.w #$FFFF					; negate
	inc a
.yabs:
	sta.b tmp0						; |Yvel|
	lda.w Xvel,x					; x speed
	bit.w #$8000
	beq .xabs						; absolute value
	eor.w #$FFFF					; negate
	inc a
.xabs:
	clc								; plus |Yvel|
	adc.b tmp0
	sta.w pspeed,x					; |Xvel|+|Yvel|
;burst animation locks the controls until done
	lda.w #SPAburst					; SPAburst $C7E, pfalock
	sta.b d1
	sta.w pfalock,x					; lock the animation
	jmp.w SetSPA					; start it
