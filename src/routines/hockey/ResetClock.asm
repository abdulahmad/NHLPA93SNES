ResetClock:							;Set the period length and stop the clock; regular season overtime is ten
									;minutes
	jsl.l GetPeriodTime				; period length in d0
	lda.w gsp						; gsp >= 3 (overtime) and OptPlayMode 0: 600 seconds
	sec
	sbc.w #$0003
	bmi .neg						; below 3: normal length
	bvc .overtime
	bra .set
.neg:
	bvc .set
.overtime:
	lda.w OptPlayMode				; playoff mode
	bne .set						; yes: normal
	lda.w #600						; regular season overtime: 600 seconds
	sta.b d0
.set:
	lda.b d0						; gameclock = PerTimeTotal = d0, gmclock
	sta.w gameclock
	sta.w PerTimeTotal
	sta.w gmclock
	rtl
unusedFF85:							;unused, $FF fill to the end of the bank
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
