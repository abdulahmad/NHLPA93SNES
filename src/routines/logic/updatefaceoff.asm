updatefaceoff:						;Step the puck drop animation; at its end erase the face off box
	lda.w temp1,x					; animation timer
	beq .erase						; zero: erase the box
	clc								; (temp1+6)/8 <= 2: drop frame 10-d0
	adc.w #$0006					; (timer + 6) / 8
	lsr a
	lsr a
	lsr a
	sta.b d0
	sec
	sbc.w #$0002					; frames 10-d0 while <= 2
	beq .set
	bmi .neg
	bvs .set
	bra .rtl
.neg:
	bvs .rtl
.set:
	lda.b d0						; d0 = 10 - d0
	eor.w #$FFFF					; negate
	inc a
	clc
	adc.w #$000A
	sta.b d0
	sta.w fofdata					; drop animation frame
.rtl:
	rtl
.erase:
	jsl.l printz					; erase the faceoff box
	%StringCp(CC_Font1Pri,$00,$00)
	lda.w fodropx					; drop x
	sec
	sbc.w #$002E					; minus the box x origin
	lsr a							; divide by 8
	lsr a
	lsr a
	bit.w #$1000					; sign extend
	beq .x
	ora.w #$E000
.x:
	sta.w printx					; print x
	lda.w fodropy					; drop y
	sec
	sbc.w #$0044					; minus the box y origin
	lsr a
	lsr a
	lsr a
	bit.w #$1000
	beq .y
	ora.w #$E000
.y:
	sta.w printy					; print y
	lda.w #$000C					; box 12 wide
	sta.b d0
	inc a							; and 13 high
	sta.b d1
	lda.w blankchar					; blank tile
	sta.b d2
	jml.l eraser					; d0/d1 size, d2 tile
