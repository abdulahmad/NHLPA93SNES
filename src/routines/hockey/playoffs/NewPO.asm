NewPO:								;Start new playoffs with the same team 1 and build the tree
	lda.w #32						; d0 = random 0-31
	sta.b d0
	jsl.l randomd0					; random seat
.top:								; next tree number (wraps at 32)
	lda.b d0						; next seat
	inc a
	and.w #$001F					; 0-31
	sta.b d0
	asl a							; times 16
	asl a
	asl a
	asl a
	adc.w #playoffseats				; a0 = playoffseats + 16 * d0
	sta.b a0						; bank
	lda.w #playoffseats>>16
	sta.b a0+2
	lda.w #15						; 16 teams
	sta.b d1						; d1 = 15
	lda.w OptTeam1					; team 1
	sta.b d2						; team
	cmp.w #24						; all-star teams (24+): team 23
	bcc .loop
	lda.w #23
	sta.b d2
.loop:								; find team 1 in this tree
	lda.b [a0]						; seat team
	inc.b a0						; next seat
	and.w #$00FF					; byte
	cmp.b d2						; our team
	beq .found						; found
	dec.b d1						; next
	bpl .loop						; more
	bra .top						; not in the seat: next seat
.found:								; potree team = slot of OptTeam1
	lda.b d1						; potreeteam = slot of OptTeam1
	eor.w #$000F					; slot
	sta.b d1						; reverse
	sta.w potreeteam				; playoff tree team
	lda.b d0
	sta.w postarts					; seat
	stz.w gamelevel					; first round
	lda.w #7						; bosgames 7: single games (OptPlayMode 2)
	sta.b bosgames
	lda.w OptPlayMode				; play mode
	cmp.w #2						; single games
	beq .tree						; yes
	stz.b bosgames					; best of seven: clear the series
	lda.w #7						; 8 series
	sta.b d0
	ldx.w #$0000					; X = 0
.cg:								; clear the series wins of the game
	stz.w gspotwins,x				; home wins
	stz.w gspobwins,x				; visitor wins
	inx								; next series
	inx
	dec.b d0						; count down
	bpl .cg
.tree:								; build the tree
	jml.l maketree					; build the tree
