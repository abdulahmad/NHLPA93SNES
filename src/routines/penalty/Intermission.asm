Intermission:						;Between periods: the pause menu screen with the scores of the other
									;games, then the highlights. Start cuts it short
	jsl.l sndqreset					; stop the sound queue
	jsl.l SetupTeamForIntermission	; set up the two teams for the screen
	lda.w #$0000
	ldy.w #$001E					; clear Xpos of the 16 objects
.0:
	sta.w Xpos,y
	dey
	dey
	bpl .0
.vc:								; wait until the frame counter is stable
	lda.b vcount
	ldy.b vcount+2
	cmp.b vcount
	bne .vc
	sta.w vcountmark				; remember the frame counter
	sty.w vcountmark+2
	lda.w #$0001
	trb.w sflags					; clear the first flag bit of sflags
	lda.w gsp
	cmp.w #$0004
	beq .ss
	bra .ss							; both branches go to .ss
.ss:
	lda.w #$0708					; pause timer = $708 frames
	sta.b pausetimer
	lda.w #$0001
	sta.w demoflag					; demo mode while the screen is up
	lda.b vcount
	sec
	sbc.w #$0150					; ticker clock = frame counter - $150
	sta.w tickervc
	jsl.l InitTicker				; start the score ticker
	lda.w TickerNum
	sta.w tickerstart				; ticker starts from the current game
.top:
	lda.w #$0000
	ldy.w #$001E					; clear Xpos of the 16 objects again
.clr:
	sta.w Xpos,y
	dey
	dey
	bpl .clr
	jsl.l printz					; print the menu text that follows
	%StringCp(CC_Font1Pri,$05,$0C)
	lda.w #$0016					; frame width 22
	sta.b d0
	lda.w #$0007					; frame height 7
	sta.b d1
	jsl.l Framer					; draw the frame
	jsl.l printscores1				; scores of the other games
	lda.w #$0002
	trb.w sflags					; clear the second flag bit of sflags
	jsl.l PauseMenu					; run the pause menu
	bne .top						; nonzero: show the screen again
	stz.w demoflag					; leave demo mode
.rtl:								; return
	rtl
