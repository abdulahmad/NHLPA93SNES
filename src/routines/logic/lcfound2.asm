lcfound2:							;Close the line change box and redraw the scoreboard
	jsl.l setlccords				; line change box coordinates
	lda.w printy					; print y
	sec
	sbc.w #15						; minus 15
	bmi .neg						; signed compare
	bvc .low
	bra .nollcm
.neg:								; signed compare: overflow flag corrects the sign
	bvc .nollcm
.low:
	lda.w #sf3llcs					; clear the line change box flag
	trb.w sflags3
.nollcm:
	inc.b d1						; d1 + 1
	lda.w blankchar					; blank character
	sta.b d2
	lda.b fobox						; box active?
	bne .print
	jsl.l eraser					; erase it
.print:
	jml.l printscores1				; redraw the scores
