SetShotMode:						;Start a shot by player X: shot mode, aim at the goal, shot animation
	lda.w #$0008					; default shot direction: none
	sta.w passdir					; no direction
	lda.w #sfssdir
	tsb.w sflags					; shot mode
;aim at the goal being attacked: (d0,d1) = vector from player to goal (28 beyond center)
	stz.b d0						; x of the goal
	lda.w #$0128					; $128: goal y + 40
	sta.b d1						; goal y
	lda.w pfgoal,x					; goal end
	bne .ck0						; bottom end
	lda.w #$FED8					; top end y
	sta.b d1
.ck0:								; (d0,d1) = vector to the goal -> direction
	lda.b d0						; dx
	sec
	sbc.w Xpos,x
	sta.b d0						; dx
	lda.b d1
	sec								; dy
	sbc.w Ypos,x
	sta.b d1
	jsl.l vtoa						; angle to the goal
	lda.w #$000F					; minimum shot speed
	sta.w passspeed					; speed
	lda.w #SPAshotf					; SPAshotf $81C
	sta.b d1						; forehand animation
	jsl.l Findhittype				; Z = forehand
	beq .ck1						; forehand
	lda.w #SPAshotb					; SPAshotb $94E
	sta.b d1						; backhand animation
.ck1:								; far branch to SetSPA
	jmp.w SetSPA
