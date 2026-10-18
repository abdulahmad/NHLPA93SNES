assstanley:							;Assignment: skate to the side of the screen
									;holding the Stanley Cup overhead
	lda.w pfalock,x
	bne .rtl
	lda.w pflags,x
	bit.w #pfna
	beq .nna
	and.w #~pfna&$FFFF
	sta.w pflags,x
	lda.w #$005A
	sta.w temp3,x
	lda.w Hpos
	bpl .0
	lda.w #$FFA6
	sta.w temp3,x
.0:
	lda.w Vpos
	sta.w temp4,x
	lda.w #SPAstanley
	sta.b d1
	jsl.l SetSPA
.nna:
	lda.w temp3,x
	sec
	sbc.w Xpos,x
	sta.b d0
	lda.w temp4,x
	sec
	sbc.w Ypos,x
	sta.b d1
	jsl.l vtoa
	lda.b d0
	sec
	sbc.w #$0007
	beq .turn
	bmi .neg
	bvs .turn
	bra .rtl
.neg:
	bvs .rtl
.turn:
	lda.b d0
	sta.b d2
	sta.w facedir,x
	jmp.w playeracc
.rtl:
	rtl
