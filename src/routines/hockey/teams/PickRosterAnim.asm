PickRosterAnim:						;Pick the roster animation of a player's best qualifying rating
	lda.b [a1]						; minimum
	and.w #$00FF
	sta.b tmp0						; tmp0
	inc.b a1
	lda.b [a1]						; animation number
	and.w #$00FF
	sta.b tmp1						; tmp1
	inc.b a1
	lda.b d1						; best so far
	sec
	sbc.b tmp0						; minus the minimum
	bmi .neg						; below it
	bvc .best
.ex1:								; not eligible: leave
	jmp.w SlideOutRosterPlayer_rtl	; not eligible
.neg:								; signed compare: overflow flag corrects the sign
	bvc .ex1
.best:								; better than the best so far
	lda.b d1						; best so far
	sec
	sbc.b d2						; minus the previous best
	bmi .neg1						; worse
	bvc .z
.ex2:								; not eligible: leave
	jmp.w SlideOutRosterPlayer_rtl	; not eligible
.neg1:								; signed compare: overflow flag corrects the sign
	bvc .ex2
.z:									; is there a previous best?
	lda.b d2						; previous best
	beq .take						; none
	lda.b tmp0
	bne .take						; minimum zero
	jmp.w SlideOutRosterPlayer_rtl	; skip it
.take:								; take it as the best
	lda.b d1						; take it
	sta.b d2
	ldy.b a2						; team
	lda.b tmp1
	sta.w tmPenmin,y				; store the animation
	rtl
