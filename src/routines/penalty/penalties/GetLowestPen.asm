GetLowestPen:						;d0 = the power play time left, from the penalty box times. a2 = team on
									;the power play, a3 = the shorthanded team
	stz.b d0						; d0 = 0
	stz.b d3						; d3 = 0
	lda.b a2						; team
	beq .a
	lda.w #$001A					; team 1 list offset
.a:
	sta.b a0						; a0 = list offset
.top:
	ldy.b a0						; penalty box list of the power play team ($80 ends)
	inc.b a0						; next entry
	lda.w tmboxlist,y
	and.w #$00FF					; player
	sta.b d2
	bit.w #$0080					; end marker
	bne .t2							; done with this team
	lda.b a2
	beq .h0							; away team
	lda.w #$0034
.h0:								; index the penalty entry
	clc
	adc.b d2
	tay
	lda.w tmpdst,y					; state
	sta.b d2						; keep it
	bit.w #$4000					; tmpdst bit 14: not timed
	bne .top						; not timed: next
	lda.b d2
	sec								; minus the previous time
	sbc.b d3
	sta.b d2
	clc								; sum
	adc.b d0
	sta.b d0
	lda.b d2
	sta.b d3						; remember it
	bra .top
.t2:
	ldy.b a3						; shorthanded team
	lda.w tmap,y					; shorthanded team players
	cmp.w #6						; all six: no power play
	beq .rtl
	lda.b d0						; total
	sec
	sbc.b d3						; minus the last
	sta.b d0
	lda.b a3
	beq .b
	lda.w #$001A
.b:									; start of the box list
	sta.b a0
.t3:								; walk the box list
	ldy.b a0
	lda.w tmboxlist,y				; next entry
	inc.b a0
	and.w #$00FF
	sta.b d2						; player
	bit.w #$0080					; end marker
	bne .rtl						; done
	lda.b a3
	beq .h1							; away team
	lda.w #$0034
.h1:								; index the penalty entry
	clc
	adc.b d2
	tay
	lda.w tmpdst,y					; state
	bit.w #$4000					; not timed: next
	bne .t3
	lda.b d0
	sec								; total
	sbc.w tmpdst,y					; minus his time
	bmi .neg						; more left
	bvc .add						; no overflow
	bra .rtl						; done
.neg:								; signed compare: overflow flag corrects the sign
	bvc .rtl
.add:								; add the penalty time to the total
	lda.b d0
	clc								; total
	adc.b d3						; plus the last
	sta.b d0
.rtl:								; return
	rtl
