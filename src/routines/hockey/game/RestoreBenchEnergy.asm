RestoreBenchEnergy:					;Once a second with line changes on, players on the bench get some energy
									;back
	lda.w OptLine					; line changes on
	bne .x							; off: leave
	stz.b a2						; home team, then the away team
	jsl.l .team
	lda.w #$0002
	sta.b a2
.team:								; last player
	lda.w #(maxros-1)*2				; last player
	sta.b d0
.b0:								; on bench?
	lda.b a2						; team
	beq .away
	lda.w #$0034					; away team offset
.away:								; add the away team offset
	clc
	adc.b d0
	tay								; index
	lda.w tmpdst,y					; on the bench?
	cmp.w #TMPDBENCH				; bench
	bne .next
	lda.w tmpde,y					; energy
	clc
	adc.w #10						; plus 10
	sta.w tmpde,y
	sec								; full is $1000
	sbc.w #$1000
	bmi .neg
	bvc .max
	bra .next
.neg:								; signed compare: overflow flag corrects the sign
	bvc .next
.max:								; clamp the energy to the maximum
	lda.w #$1000					; clamp
	sta.w tmpde,y
.next:								; next roster slot
	dec.b d0						; previous player
	dec.b d0
	bpl .b0
.x:									; return
	rtl
