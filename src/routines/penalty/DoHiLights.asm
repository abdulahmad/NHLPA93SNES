DoHiLights:							;Playoffs: play the highlight of each game of the round that has one
	lda.w OptPlayMode
	beq .rtl						; regular season: none
	jsl.l GetShifter				; number of games
	lda.b d1
	asl a							; offset
	sta.b a0
.top:
	ldy.b a0
	lda.w gsflags,y					; game flags
	bit.w #gsfso					; game over
	bne .next
	bit.w #gsfhl					; has a highlight
	beq .next
	and.w #~gsfhl&$FFFF				; clear the flag
	sta.w gsflags,y
	jsl.l SaveRegsStartHL2			; play the highlight
.next:
	dec.b a0						; previous game
	dec.b a0
	dec.b d1						; until game 0
	bpl .top
.rtl:								; return
	rtl
