NewTicker3_tn:						;Print one ticker line: team d0's name and score d1
	lda.b $04,s						; x from the caller
	sta.w printx
	inc.w printy					; next row
	lda.w #TeamList					; team list
	sta.b a1
	lda.w #TeamList>>16
	sta.b a1+2
	asl.b d0						; team * 4
	asl.b d0
	ldy.b d0
	lda.b [a1],y					; team data
	sta.b a1
	lda.w #TeamList>>16
	sta.b a1+2
	ldy.w #Teamname					; team name offset
	lda.b [a1],y					; name pointer
	adc.b a1
	sta.b a1
	jsl.l print						; print the name
	lda.b $04,s						; x again
	clc
	adc.w #$0017					; plus $17
	sta.w printx
	lda.b d1						; score
	sta.b d0
	jsl.l PushNumber				; number to text
	jml.l print						; print it
