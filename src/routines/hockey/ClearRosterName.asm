ClearRosterName:					;Blank the name of the roster player shown in the team block
	jsl.l setoptions_printpos2
	lda.w #$000B
	sta.b d0
	lda.w #$0002
	sta.b d1
	lda.w blankchar
	sta.b d2
	jml.l eraser
