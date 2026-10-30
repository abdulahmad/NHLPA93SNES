ClearOffsidesIfAllPlayers:			;Clear team a2's offsides flag once none of its
									;skaters is past the blue line
	ldy.b a2						; team offset
	lda.w tmflags,y					; tmfoside
	bit.w #tmfoside
	bne .go							; not flagged
	jmp.w ChkOffsides_rtl			; nothing to do
.go:								; sorted players of the team
	lda.w tmsort,y					; sorted players of the team
	sta.b a0						; a0 = first
	lda.w #$0005					; six skaters
	sta.b d1
.top:								; check each player
	ldy.b a0
	lda.w position,y				; position
	bmi .next						; none
	lda.w Ypos,y					; y
	sta.b d0
	lda.w pfgoal,y					; goal end
	bne .next						; top end
	lda.b d0
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
.next:								; next player
	inc.b a0
	inc.b a0
	lda.b d0						; y
	sec
	sbc.w #Blueline					; minus the blue line
	beq .more
	bmi .neg
	bvs .more						; still past it
.rtl:								; far branch to ChkOffsides_rtl
	jmp.w ChkOffsides_rtl
.neg:								; still past it?
	bvs .rtl						; still past it
.more:								; next skater
	dec.b d1						; next skater
	bpl .top
	ldy.b a2						; none past: clear the flag
	lda.w tmflags,y
	and.w #~tmfoside&$FFFF			; clear tmfoside
	sta.w tmflags,y
	rtl
