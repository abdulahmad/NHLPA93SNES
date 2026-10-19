InitScores:							;Playoffs: give the other games of the round random scores so far
	lda.w OptPlayMode				; regular season: none
	beq .rtl
	lda.w gamelevel					; round
	cmp.w #$0002					; only the first two rounds
	bcs .rtl
	jsl.l GetShifter				; number of games
	lda.b d1
	asl a
	sta.b a0
.top:
	lda.b d1						; the user game
	cmp.w gamenum
	beq .next						; skip it
	ldy.b a0						; game offset
	lda.w gsflags,y
	bit.w #gsfso					; game over
	bne .next
	lda.w #$0000					; period 0
	sta.w gsper,y
	lda.w #$0003					; up to 3 goals
	sta.b d0						; d0 = 3
	jsl.l randomd0					; random score count
	bra .1
.0:
	jsl.l SetScore					; add a goal
.1:
	dec.b d0						; count down
	bpl .0
.next:
	dec.b a0						; previous game
	dec.b a0
	dec.b d1
	bpl .top
.rtl:								; return
	rtl
