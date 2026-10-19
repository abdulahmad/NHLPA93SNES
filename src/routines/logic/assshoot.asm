assshoot:							;Assignment: computer shooting: wind up, then shoot when the swing time
									;runs out
	lda.w pflags,x
	bit.w #pfna						; pfna
	beq .nna						; no: .nna
	and.w #~pfna&$FFFF
	sta.w pflags,x
	bra SetShotMode					; set the shot mode
.nna:								; new assignment: check the shot direction flag
	lda.w sflags
	bit.w #sfssdir					; sfssdir
	bne .swing
	jmp.w assexit					; no: assignment over
.swing:								;count down the swing time; then press the shot button (d2 = cbut)
	lda.w temp1,x
	sta.b d0						; d0 = shot direction
	stz.b d2						; no buttons
	lda.w temp2b,x
	sec
	sbc.b d7						; minus d7
	sta.w temp2b,x
	bpl ShotMode					; swing not over: no button
	lda.w #cbut						; swing over: press the shot button
	tsb.b d2
	bra ShotMode					; continue
