AttribStatus:						;Roster column: where the player is (ice, bench, injured) or his penalty
									;time
	asl.b d0						; player number * 2
	lda.b a2						; team
	beq .team
	lda.w #$0034					; away team offset $34
.team:								; team offset
	adc.b d0
	tay								; index
	lda.w tmpdst,y					; tmpdst: negative = not of the status
	sta.b d0						; state
	bpl .pen						; on the ice/bench
	eor.w #$FFFF					; invert
	sta.b d0
	cmp.w #$0003					; status 0-2
	bcc .st
	lda.w #$0001					; else 1
	sta.b d0
	bra .st
.inj:
	lda.w #$0003					; injured
	sta.b d0
.st:								; status text list
	lda.w #StatusTextTbl>>16
	sta.b a1+2						; text list
	lda.w #StatusTextTbl
	sta.b a1
	jml.l Fprint_list				; d0 = index, [a1] = list
.pen:								; penalty
	lda.b d0						; state
	bit.w #TMPDINJ
	bne .inj						; injured
	dec.w printx					; one column left
	lda.b d0
	sta.b d1						; d1 = state
	and.w #$0FFF					; time bits
	sta.b d0
	jsl.l PushTime					; d0 = time
	jsl.l print						; print it
	lda.w #$0004
	sta.b d0						; text 4
	lda.w #$4000					; bit $4000
	trb.b d1						; clear it
	beq .t							; clear
	lda.w #$0005					; text 5
	sta.b d0
.t:									; status text list for the goalie
	lda.w #StatusTextTbl>>16
	sta.b a1+2
	lda.w #StatusTextTbl
	sta.b a1
	jml.l Fprint_list				; d0 = index, [a1] = list
