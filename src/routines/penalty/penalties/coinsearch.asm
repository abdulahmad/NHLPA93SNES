coinsearch:							;Count team a2's players kept off the ice by penalties (not coincidental
									;ones) to set how many it has on the ice
	lda.w #$0006					; d1 = 6 players, d0 = last roster word
	sta.b d1						; six players
	lda.w #$0032					; last roster word
	sta.b d0
.top:								; loop over the players
	lda.b a2
	beq .tm							; team
	lda.w #$0034					; away team offset
.tm:								; team offset
	clc
	adc.b d0
	tay								; index
	lda.w tmpdst,y					; player state
	bmi .nap						; empty
	beq .nap
	and.w #$DFFF					; clear bit $2000; coincidental or injured: does not count
	sta.w tmpdst,y					; state back
	bit.w #TMPDINJ|$4000			; injured
	bne .nap
	lda.b d1
	cmp.w #$0004					; four minimum
	beq .nap						; keep it
	dec.b d1						; one less
.nap:								; next player
	dec.b d0						; previous player
	dec.b d0
	bpl .top
	ldy.b a2						; team offset
	lda.b d1
	sta.w tmap,y					; players on the ice
	rtl
