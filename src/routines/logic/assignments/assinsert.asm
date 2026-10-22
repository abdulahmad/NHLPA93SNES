assinsert:							;Give player X assignment d0 on top of the current one
	lda.w assnum,x					; assnum - 1
	dec a							; one slot back
	and.w #$0007					; wrap around the 8 slots
	sta.w assnum,x
assreplace:							;replace current assignment on player a3. d0 = assignment
									;replace the current assignment of player X with d0
	lda.w pflags,x
	ora.w #pfna						; pfna
	sta.w pflags,x
	txa								; asslist+X*4+assnum = d0 (byte)
	asl a
	asl a
	adc.w assnum,x
	tay
	sep #$20						; 8-bit A
	lda.b d0						; the assignment
	sta.w asslist,y					; store it
	rep #$30						; 16-bit registers
	rtl
