AttribHanded:						;Roster column: shooting hand
	lda.b d0
	and.w #$0001					; 0 or 1
	sta.b d0
	lda.w #HandedTextTbl>>16		; text list for the hand
	sta.b a1+2
	lda.w #HandedTextTbl
	sta.b a1
	jml.l Fprint_list				; d0 = index, [a1] = list
