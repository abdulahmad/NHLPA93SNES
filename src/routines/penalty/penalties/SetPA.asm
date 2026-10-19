SetPA:								;Start the referee animation for penalty d0 and show its message
	lda.b d0						; RefPen = d0, RefStep = 0, prefmes
	sta.w RefPen
	stz.w RefStep
	jsl.l prefmes					; prepare the message
	lda.b d0						; penalty number
	cmp.w #PenGoal					; goal: the goal box
	bne .0
	jsl.l ShowGoalBox
.0:									; show the message for a long time
	lda.w #$7FFF
	sta.w penmsgtimer				; show the message for a long time
	lda.w sfhormode					; horizontal mode
	beq .pa2
	lda.w #$003C					; only $3C frames
	sta.w penmsgtimer
.pa2:								; start the animation
	jml.l SetPA2					; start the animation
