getpde:								;d0 = the energy of player X
	lda.w pfteam,x					; player team
	beq .0							; team 0
	lda.w #$0002					; a2 = 2: away team
.0:
	sta.b a2						; a2 = team offset
	lda.w pnum,x					; player number
	and.w #$00FF					; pnum low byte
	asl a
	sta.b d1						; d1 = number * 2
	lda.b a2
	beq .idx						; team 0: no offset
	lda.w #$0034					; away team entries start $34 bytes in
.idx:								; index the energy table
	adc.b d1
	tay								; index into the table
	lda.w tmpde,y					; energy
	sta.b d0						; d0 = energy
rtss:								;the rtl that ends getpde, also used as a do-nothing callback (lda #rtss
									;for skateto)
	rtl
