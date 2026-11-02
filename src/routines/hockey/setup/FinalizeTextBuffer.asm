FinalizeTextBuffer:					;End a string built in mesarea and set a1 to it
	lda.b a1						; end of the text
	sec
	sbc.w #mesarea					; minus the start: length
	sta.w mesarea					; length word first
	lda.w #mesarea
	sta.b a1						; a1 = the string
	rtl
