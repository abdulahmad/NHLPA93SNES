GetGoalieCount:						;d0 = the number of goalies on team a2
	lda.b a2						; team offset
	tay
	and.w #$FFFD					; must be 0 or 2
.hang:
	bne .hang						; (hangs otherwise)
	lda.w #TeamList>>16				; team list bank
	sta.b tmp1
	lda.w tmdata,y					; team data pointer
	sta.b tmp0
	ldy.w #GoalieOdds				; goalie odds offset
	clc
	adc.b [tmp0],y
	sta.b tmp0
	stz.b d0						; count = 0
	lda.b [tmp0]					; goalie odds bits
	xba
.cnt:
	inc.b d0						; count the used nibbles
	asl a
	asl a
	asl a
	asl a
	bne .cnt
	rtl
