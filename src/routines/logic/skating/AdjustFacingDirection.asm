AdjustFacingDirection:				;Turn goalie X's facing one step toward d0, not past the sides of the net
	lda.w facedir,x					; facing
	sta.b d1						; d1
	lda.b d0						; wanted direction
	sec
	sbc.b d1						; minus the facing
	sta.b d0						; difference
	bne .turn						; differs
	jmp.w assgoalie_rtl				; same: done
.turn:								; direction of the shortest turn
	eor.w #$FFFF					; negate
	inc a							; direction of the shortest turn
	and.w #$0004					; +4 bit
	lsr a							; /2
	dec a							; -1: +1 or -1
	sta.b d0						; step
	lda.b d1						; facing
	cmp.w #$0001					; 1
	beq .add						; yes
	cmp.w #$0006					; 6
	bne .dn							; no
.add:								; apply the step
	clc								; add the step
	adc.b d0
	sta.b d1						; new facing
	lda.w pfgoal,x					; goal end
	bne .other						; bottom end
	lda.b d1
	cmp.w #$0002					; 0 or 1
	bcc .neg
	cmp.w #$0007					; 7
	beq .neg						; keep out of the 7-1 range
	bra .set						; set
.other:								; turned past the blocked directions
	lda.b d1
	cmp.w #$0003					; 3
	bcc .set
	cmp.w #$0006					; 6
	bcs .set						; outside 3-5
.neg:								; reverse the step
	lda.b d0						; step
	eor.w #$FFFF					; negate
	inc a							; reverse it
	sta.b d0
	clc
	adc.b d1						; add it
	sta.b d1
.dn:								; apply the step
	lda.b d1
	clc								; add the step
	adc.b d0
	sta.b d1
.set:								; wrap to 0-7
	lda.b d1
	and.w #$0007					; 0-7
	sta.b d1
	sta.w facedir,x					; new facing
	rtl
