TryAddPlayerToList:					;Add roster player d0 to slot d4 of the list of players wanted on the ice,
									;if he is available
	lda.b d0						; roster player
	sta.b d1						; keep the number in d1
	dec.b d0						; zero-based
	asl.b d0						; word offset
	lda.b a2						; team
	beq .idx
	lda.w #$0034					; away team offset $34
.idx:								; index the player
	adc.b d0
	tay								; index
	lda.w tmpdst,y					; state
	sec
	sbc.w #$0000
	beq .chk						; on the ice or bench
	bmi .neg
	bvs .chk
	bra .no
.neg:								; signed compare: overflow flag corrects the sign
	bvs .no
.chk:								; on the ice or bench: not available
	lda.w tmpdst,y					; state
	cmp.w #TMPDOUT					; TMPDOUT: not available
	beq .no
	lda.w #$0005					; six list entries
	sta.b d0
.s2:								; is d1 already in PlList?
	ldy.b d0						; entry
	lda.b [a4],y					; list byte
	and.w #$00FF
	sta.b tmp0
	lda.b d1
	and.w #$00FF
	cmp.b tmp0						; same player
	beq .no							; already in PlList
	dec.b d0						; next entry
	bpl .s2
	ldy.b d4						; slot d4
	sep #$20						; 8-bit A
	lda.b d1						; the player
	sta.b [a4],y					; store him
	rep #$20						; 16-bit A
	lda.b d1
	and.w #$00FF					; number as the result
	rtl
.no:								; not available: Z set, d1 = 0
	lda.w #$0000					; not added
	sta.b d1						; d1 = 0
	rtl
