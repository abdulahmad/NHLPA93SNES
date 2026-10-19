StatsReport:						;Show the game stats until A is pressed or a minute passes
	jsl.l DisplayStats				; draw the stats
	lda.b vcount					; start time
	pha
.wait:								; wait for the pad that paused
	jsl.l setvideo					; update the screen
	jsl.l ReadPads					; read the pads
	jsl.l getpzjoy					; the pad that paused
	lda.b d1
	bit.w #$0080					; A button
	bne .exit						; pressed: done
	lda.b vcount
	sec
	sbc.b $01,s
	cmp.w #$0E10					; a minute = $E10 frames
	bcc .wait						; not yet: wait
.exit:								; drop the start time
	pla								; drop the start time
	rtl
