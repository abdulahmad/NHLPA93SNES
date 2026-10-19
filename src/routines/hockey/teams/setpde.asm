setpde:								;Set the energy of player d1 of team a2 to d0
	lda.b a2						; team
	beq .home						; home
	lda.w #$0034					; away team offset $34
.home:								; index the energy table
	clc
	adc.b d1						; plus the player
	tay
	lda.b d0						; energy
	bpl .store						; negative: 0
	lda.w #$0000
	sta.b d0
.store:
	sta.w tmpde,y					; store it
	rtl
