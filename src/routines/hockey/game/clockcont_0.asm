clockcont_0:						;End of a period: in the third period the winners celebrate (with the
									;Stanley Cup after the final), and the clock stops
	ldx.w #$001C					; object 14
	stx.b a3
	lda.w #$18						; assignment $18
	sta.b d0
	jsl.l assinsert					; insert it
	lda.w gsp						; period
	cmp.w #$0002					; third period or later
	bcs .p3							; yes
	jmp.w .notp3					; no
.p3:								; assignment 7 for team 0
	lda.w #$0007					; assignment 7
	sta.b d0
	ldx.w #$0000					; team 0
	stx.b a3
	lda.w gamelevel					; round
	cmp.w #$0003					; not the final
	bne .winners
	lda.b bosgames					; series?
	cmp.w #$0007					; single games: cup
	beq .cup
	lda.w gamenum					; game
	asl a							; times 2
	sta.b a0
	tay								; offset
	stz.b d3						; d3 = 0
	lda.w gsflags,y
	bit.w #gsftf					; team flag
	beq .nf
	lda.w #gspobwins-gspotwins		; offset to the other wins
	sta.b d3
.nf:								; d1 = home score - away score
	lda.w tmscore					; home score
	cmp.w tmscore+2					; home won?
	bpl .ns1
	lda.b d3						; swap
	eor.w #gspobwins-gspotwins
	sta.b d3
.ns1:								; series offset plus the side
	lda.b a0						; game offset
	clc
	adc.b d3						; plus the side
	tay
	lda.w gspotwins,y				; series wins
	cmp.w #$0003					; three: the cup
	bne .winners
.cup:								; assignment 8: 12 players
	lda.w #$0008					; assignment 8
	sta.b d0
	lda.w #$000B					; 12 players
	sta.b d2
.cpu:								; release the controllers
	lda.w pflags,x
	and.w #~pfjoycon&$FFFF			; clear the joystick flag
	sta.w pflags,x
	inx
	inx
	dec.b d2						; next player
	bpl .cpu
	ldx.w #$0000					; team 0
	stx.b a3
.winners:							; celebrate: 6 players
	lda.w #$0005					; celebrate: 6 players
	sta.b d2
	lda.w tmscore					; scores
	cmp.w tmscore+2					; equal
	beq .notp3						; tied: no winners
	bpl .celeb						; home won
	ldx.w #$000C					; else team 1
	stx.b a3
.celeb:								; position of the player: none stops
	lda.w position,x				; position
	beq .next						; none
	jsl.l assinsert					; assignment
	lda.w #$0007					; 7
	sta.b d0
.next:								; next player
	inx
	inx
	stx.b a3
	dec.b d2						; count down
	bpl .celeb
.gameover:							; clear the penalties, crowd
	jsl.l ClearPenaltyBuffer		; clear the penalties
	lda.b crowdlevel				; crowd
	clc
	adc.w #$03E8					; +1000
	sta.b crowdlevel
	lda.w #$0040					; clock stopped
	sta.w gmclock
	tsb.w gmode						; game mode
	lda.w tmscore					; scores
	cmp.w tmscore+2
	bmi .awaywon					; away won
	stz.b crowdlevel				; crowd quiet
	lda.w #$0003					; cheer 3 times
	sta.w cheercnt
	lda.b vcount					; frame
	sec
	sbc.w #$0096					; minus 150
	sta.w cheervc
.awaywon:							; game over penalty
	lda.w #PenEOG					; game over penalty
	sta.b d0
	jml.l AddPenalty2				; call it
.notp3:								; overtime?
	lda.w gsp						; period
	cmp.w #$0003					; overtime
	bne .perover
	lda.w OptPlayMode				; play mode
	beq .gameover					; regular season: game over
.perover:							; period over penalty
	lda.w #PenEOP					; period over penalty
	sta.b d0
	jml.l AddPenalty2				; call it
