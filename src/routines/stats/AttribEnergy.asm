AttribEnergy:						;Roster column: the player's energy, scaled to at most 100
	asl.b d0						; player number * 2
	lda.b a2						; team
	beq .team
	lda.w #$0034					; away team offset $34
.team:								; team offset
	adc.b d0
	tay								; index into the energy table
	lda.w tmpde,y					; divu16 by 40
	sta.b mulb						; energy
	lda.w #$0028
	sta.b mula
	jsl.l divu16					; mulb / mula
	cmp.w #$0065					; capped at 100
	bcc .cap
	lda.w #$0064					; 100
.cap:								; cap at the maximum
	sta.b d0
	bra AttribPrintPct				; print as a percentage
