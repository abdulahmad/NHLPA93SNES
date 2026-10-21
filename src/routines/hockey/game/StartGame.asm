StartGame:							;Reset the game state for a new game, then start the first period
	stz.w gmode						; normal game mode
	lda.w OptPen					; OptPen 1: offsides on
	cmp.w #1
	bne .go
	lda.w #gmoffs
	tsb.w gmode
.go:								; clear the team stats, score sum bytes, period 0
	jsl.l clearTeamStats			; clear the team stats
	stz.w ScoreSumbytes				; score sum bytes
	stz.w gsp						; period 0
	stz.w ChkCnt					; check counter
	jsl.l restoreteams				; restore the teams
	jsl.l InitScores				; scores to 0
	jsl.l UpdateScores				; show them
	jml.l StartPer					; on to the period start
