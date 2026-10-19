ClearRosterName:					;Blank the name of the roster player shown in the team block
	jsl.l setoptions_printpos2		; set the print position
	lda.w #$000B					; width 11
	sta.b d0
	lda.w #$0002					; height 2
	sta.b d1
	lda.w blankchar					; blank character
	sta.b d2
	jml.l eraser					; erase the name
