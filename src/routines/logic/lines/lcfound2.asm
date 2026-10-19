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
.low:								; clear the line change box flag
	lda.w #sf3llcs					; clear the line change box flag
	trb.w sflags3
.nollcm:							; d1 = 1 and d2 = $7FF tile: erase the box area
	inc.b d1						; d1 + 1
	lda.w blankchar					; blank character
	sta.b d2
	lda.b fobox						; box active?
	bne .print
	jsl.l eraser					; erase it
.print:								; redraw the scores
	jml.l printscores1				; redraw the scores
