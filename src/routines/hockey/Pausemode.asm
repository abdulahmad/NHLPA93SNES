Pausemode:							;Pause mode: save the screen, stop the sound, show the pause menu until it
									;is left, then restore
	phx
	ldx.w #$07FE					; 2KB of text map
.save:								;textsave = textmap
	lda.l textmap,x
	sta.l textsave,x				; copy it
	dex
	dex
	bpl .save
	plx
	jsl.l sndqreset					; sound off; keep sfhormode and sflags
	lda.w sfhormode					; keep horizontal mode
	pha
	lda.w sflags					; and the flags
	pha
	jsl.l forceblack				; blank the screen
	lda.w #999						; Oldrow = 999, SetHor, setvideo
	sta.w Oldrow
	jsl.l SetHor					; switch to the horizontal rink
	jsl.l setvideo					; update the video
	jsl.l KillCrowd					; crowd off
.top:								;draw the pause screen
	jsl.l printbigz					; big PAUSE title and the menu frame (22 x 7)
	%StringCt(CC_Font1Pri,$0B,$02,"PAUSE")
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1Pri,$05,$0C)
	lda.w #$0016
	sta.b d0
	lda.w #$0007
	sta.b d1
	jsl.l Framer					; d0 x d1
	jsl.l printscores1
	jsl.l PauseMenu					; nonzero: draw again
	bne .top
	jml.l PauseExit					; resume
