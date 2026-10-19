assstanley:							;Assignment: skate to the side of the screen
									;holding the Stanley Cup overhead
	lda.w pfalock,x					; locked
	bne .rtl						; yes: leave
	lda.w pflags,x					; flags
	bit.w #pfna
	beq .nna						; not new
	and.w #~pfna&$FFFF				; clear the new flag
	sta.w pflags,x
	lda.w #$005A					; target x = $5A
	sta.w temp3,x
	lda.w Hpos						; camera x
	bpl .0							; right half
	lda.w #$FFA6					; left: target -$5A
	sta.w temp3,x
.0:									; temp4 = y from Vpos
	lda.w Vpos						; camera y
	sta.w temp4,x					; target y
	lda.w #SPAstanley				; Stanley Cup animation
	sta.b d1
	jsl.l SetSPA					; start it
.nna:								; face and accelerate toward the target
	lda.w temp3,x					; target x
	sec
	sbc.w Xpos,x					; minus x
	sta.b d0
	lda.w temp4,x					; target y
	sec
	sbc.w Ypos,x					; minus y
	sta.b d1
	jsl.l vtoa						; direction
	lda.b d0
	sec								; minus 7
	sbc.w #$0007
	beq .turn
	bmi .neg
	bvs .turn
	bra .rtl						; far: keep skating
.neg:								; signed compare: overflow flag corrects the sign
	bvs .rtl
.turn:								; close enough: turn
	lda.b d0
	sta.b d2
	sta.w facedir,x					; facing
	jmp.w playeracc					; skate
.rtl:								; return
	rtl
