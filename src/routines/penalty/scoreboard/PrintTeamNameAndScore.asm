PrintTeamNameAndScore:				;Print team a2's name, then its score as two characters
	jsl.l printteamname				; print the name
	lda.w #mesarea					; text buffer
	sta.b a1
	lda.w #$0000
	sta.b a1+2
	lda.w #4						; length 4
	sta.b [a1]
	lda.w #' '						; blank tens
	sta.w mesarea+2					; tens digit
	ldy.b a2						; team
	lda.w tmscore,y					; score
	sta.b mulb
	lda.w #10						; divide by 10
	sta.b mula
	jsl.l divu16					; mulb / mula
	beq .ones						; score below 10
	adc.w #'0'						; tens digit
	sta.w mesarea+2
.ones:								; remainder = ones
	lda.b mulres+2					; remainder = ones
	adc.w #'0'
	sta.w mesarea+3					; ones digit
	jml.l print						; print the score
