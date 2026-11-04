box:								;Erase the goal box
	jsl.l printz					; set font and position (11,2)
	%StringCp(CC_Font1,$0B,$02)
	lda.w #$0013					; width $13
	sta.b d0
	lda.w #$0009					; height 9
	sta.b d1
	lda.w blankchar					; blank character
	sta.b d2
	jml.l eraser					; erase it
