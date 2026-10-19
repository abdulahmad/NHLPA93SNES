Acheck:								;Player X holds or hooks player a0
	ldy.b a0						; the other player
	lda.w #SPAhook					; hook animation
	sta.b d1
	sta.w pfalock,x					; lock it
	lda.w impact,x					; hit by someone
	beq .set						; no: hook
	lda.w Ypos,x
	sec								; dy to the other player
	sbc.w Ypos,y
	sta.b d0
	lda.w pfgoal,x					; goal end
	beq .0							; no: skip the flip
	lda.b d0
	eor.w #$FFFF					; negate for the other end
	inc a
	sta.b d0
.0:									; a0 is ahead (toward the goal being attacked)
	bmi .set						; negative: keep the hook
	lda.w #SPAHold					; else hold
	sta.b d1
.set:								; start hook/hold animation
	jml.l SetSPA					; start animation d1
