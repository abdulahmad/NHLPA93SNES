PeriodOver:							;End of a period: the next period, overtime for a tied playoff game, or
									;game over
	jsl.l forceblack				; blank the screen
	inc.w gsp						; next period
	lda.w gmode						; game mode
	eor.w #gmdir					; toggle the direction bit
	sta.w gmode
	lda.w gsp
	cmp.w #$0003					; after overtime (period 4+)
	beq .ot							; exactly period 3: check for overtime
	bcc .next						; before period 3: next period
	lda.w #$0003					; beyond overtime
	sta.w gsp
	lda.w OptPlayMode				; playoffs
	bne .ot							; keep overtime
	lda.w #$0004					; regular season: game over
	sta.w gsp
.ot:
	lda.w tmscore					; tied: overtime
	cmp.w tmscore+2					; scores equal
	beq .next						; not tied: game over
	lda.w #$0004					; game over
	sta.w gsp
.next:
	jsl.l ResetClock				; period length
	jsl.l SetHor					; horizontal rink
	jsl.l setvideo					; update the video
	jsl.l UpdateScores				; ticker scores
	jsl.l Intermission				; intermission screen
	lda.w gsp
	cmp.w #$0004					; period 4 means game over
	bne .per
	jml.l GameOver					; end of the game
.per:
	jmp.w StartPer					; start the next period
