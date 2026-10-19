UpdateScores:						;Update the ticker scores of the other playoff games
	jsl.l GetShifter				; GetShifter: d1 = games - 1
	lda.b d1						; last game
	sta.w TickerNum					; ticker starts there
	asl a							; times 2
	sta.b a0
.top:								; loop over the games
	lda.b d1
	cmp.w gamenum					; the user game
	beq .next						; skip it
	ldy.b a0						; game offset
	lda.w gsflags,y					; clear gsfhl; game not over: SetScore
	and.w #~gsfhl&$FFFF
	sta.w gsflags,y
	bit.w #gsfso					; game over
	bne .next						; yes: keep the score
	jsl.l SetScore					; compute the score
.next:								; previous game
	dec.b a0						; previous game
	dec.b a0
	dec.b d1						; previous game number
	bpl .top						; until game 0
	rtl
