periodicevents:						;Run every game loop; the slower checks once a second
	jsl.l PenaltyManager			; PenaltyManager
	jsl.l updatecrowdf				; updatecrowdf
	jsl.l updatesound				; updatesound
	jsl.l clockcont					; clockcont
	lda.w sfhormode					; horizontal: no screen updates
	bne .rtl
	lda.w lldisp					; countdown to the next slow check
	sec
	sbc.b d7						; minus d7
	sta.w lldisp
	bpl .rtl						; not a second yet: leave
	clc
	adc.w #jps						; +$18 frames
	sta.w lldisp
	jsl.l ChkGoalies				; ChkGoalies
	jsl.l UpdateCwdExcite			; UpdateCwdExcite
	jsl.l CheckLateGameSong			; CheckLateGameSong
	jsl.l RestoreBenchEnergy		; RestoreBenchEnergy
	jsl.l CheckInjury				; CheckInjury
	jmp.w updatepwrplay
.rtl:								; return
	rtl
