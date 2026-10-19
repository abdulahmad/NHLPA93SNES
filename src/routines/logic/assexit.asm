assexit:							;End player X's current assignment and go back to the one under it
	lda.w assnum,x					; current assignment number
	inc a							; next assignment
	and.w #$0007					; wrap around the 8 slots
	sta.w assnum,x
	lda.w pflags,x
	ora.w #pfna						; pfna
	sta.w pflags,x					; store the flags
	rtl
