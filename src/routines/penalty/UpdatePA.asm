UpdatePA:							;Animate the referee, and reprint the penalty message line when its time
									;runs out
	lda.w RefCnt					; RefCnt negative: idle
	bmi .rtl
	sec								; minus the frames of this loop
	sbc.b d7
	sta.w RefCnt					; new count
	bpl .1							; still running
	jsl.l SetPA2					; next animation step
.1:
	lda.w penmsgtimer
	sec								; message timer
	sbc.b d7
	sta.w penmsgtimer				; new timer
	bpl .rtl						; still running
	lda.w #$7FFF					; reload
	sta.w penmsgtimer
	jsl.l ClearPenaltyMessage		; then the player name centered at row $B
	jsl.l printz					; print the name
	%StringCp(CC_Font1Pri,$11,$0B)
	jsl.l GetPlayerName				; a1 = name
	lda.b [a1]						; name length
	lsr a							; half of it
	sta.b d0
	lda.w printx					; printx
	sec
	sbc.b d0						; centered
	sta.w printx
	jmp.w print						; print the name
.rtl:								; return
	rtl
