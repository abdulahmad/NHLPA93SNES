CompShoot:							;Computer player X shoots
	pla								; pop the caller
	sep #$20						; 8-bit A
	pla
	rep #$30
	lda.w pucky						; puck y
	sta.b d0
	lda.w pfgoal,x					; goal end
	bne .ds0						; top end
	lda.b d0
	eor.w #$FFFF					; negate for the bottom end
	inc a
	sta.b d0
.ds0:
	lda.w #blueline+goalline		; swing time = (blueline+goalline - y)/8, max 20
	sec								; distance to the goal line
	sbc.b d0
	lsr a
	lsr a							; /8
	lsr a
	sta.b d1
	cmp.w #$0014					; capped at 20
	bcc .lt
	lda.w #$0014
	sta.b d1
.lt:
	stz.w temp2,x					; temp2 = 0
	lda.b d1
	sta.w temp2b,x					; swing time
	lda.w #ashoot					; ashoot
	sta.b d0						; new assignment
	jmp.w assreplace
