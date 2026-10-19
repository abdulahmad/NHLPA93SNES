PauseReadJoy:						;Wait for a new button press; in the demo the pause ends by itself
	jsl.l IntermissionTick			; ticker and highlights
	bne .force						; done: force Start
	jsl.l setvideo					; update the video
	lda.b vcount					; frame counter
.vb:								; wait for the next frame
	cmp.b vcount					; wait for the next frame
	beq .vb
	jsl.l ReadPads					; ReadPads; ignore L/R
	lda.w joypad1					; pad 1
	ora.w joypad2					; or pad 2
	bit.w #JOYR|JOYL				; L or R
	bne PauseReadJoy				; ignore them
	jsl.l getpzjoy					; menu sounds and ticker
	jsl.l nullrtl85
	lda.w demoflag					; demo with no controller teams: count down pausetimer
	beq .chk						; human team
	lda.w cont1team
	ora.w cont2team
	bne .chk						; no demo timer
	dec.b pausetimer				; demo timer counts down
	bne .chk
.force:								; force Start
	lda.w #JOYSTART					; force Start
	tsb.b d1
.chk:								; any new presses?
	lda.b d1						; new presses
	beq PauseReadJoy				; none: wait
	lda.w #60000					; reset the demo timer
	sta.b pausetimer
	rtl
