checkfight:							;Look for the start of a fight between a2 and X after a hard hit; if it
									;starts, both get fighting
		;   penalties and the other players stop to watch
	ldy.b a2						; the other player
	lda.w impact,x					; impact of X
	sec
	sbc.w #$000A					; minus 10
	bmi .neg
	bvc .i2
.ex1:
	jmp.w .rtl
.neg:								; signed compare: overflow flag corrects the sign
	bvc .ex1
.i2:
	lda.w impact,y					; impact of the other
	sec
	sbc.w #$000A					; minus 10
	bmi .neg1
	bvc .lock
.ex2:
	jmp.w .rtl
.neg1:								; signed compare: overflow flag corrects the sign
	bvc .ex2
.lock:
	lda.w pfalock,y					; animation locked?
	ora.w pfalock,x
	beq .pen
	jmp.w .rtl
.pen:
	lda.w pflags,x					; player flags
	ora.w pflags,y
	bit.w #pf2pen					; already penalised?
	beq .pos1
	jmp.w .rtl
.pos1:
	lda.w position,x				; position
	bne .pos2
	jmp.w .rtl
.pos2:
	lda.w position,y				; position of the other
	bne .clk
	jmp.w .rtl
.clk:
	lda.w gmode						; highlight, clock stopped, the puck fighting
	and.w #gmhl						; highlight bit
	ora.w gmclock					; or the clock stopped
	ora.w pf2fight+puckobj			; or the puck fighting
	beq .go
	jmp.w .rtl
.go:
	stx.b xsave						; keep X
	ldx.w #$0000					; keep X
.save:								; save d0 and the words after it (10 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0014
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0000
.savea:								; save a0 and the words after it (8 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0010
	bne .savea
	ldx.b xsave						; restore X
	ldy.w assnum+puckobj			; puck assignment pfaceoff: no fight
	lda.w asslist+puckobj*4,y		; assignment of the puck
	and.w #$00FF
	cmp.w #pfaceoff					; face off?
	bne .nofo
	jmp.w .ex
.nofo:
	lda.w #$0028					; d0 = 10 + max(0, 40 - ChkCnt)/4
	sec
	sbc.w ChkCnt					; 40 minus the check count
	bpl .pos
	lda.w #$0000					; at least 0
.pos:
	lsr a
	lsr a
	clc
	adc.w #$000A					; plus 10
	sta.b d0						; d0 = fight chance
	jsl.l SetInst					; a2 starts the fight check
	ldx.b a2
	ldy.b a3
	stx.b a3
	sty.b a2
	jsl.l SetInst					; and X
	ldx.b a2
	ldy.b a3
	stx.b a3
	sty.b a2
	lda.w pf2fight,x				; X fighting?
	bne .fight
	jmp.w .ex
.fight:								;clear ChkCnt and the check counts of both teams
	stz.w ChkCnt					; clear the check count
	lda.w #$0000					; and the player check counts
	ldy.w #maxros*2-2
.clr:
	sta.w pchecks,y					; clear
	dey
	dey
	bpl .clr
	lda.b crowdlevel				; crowd +1000; no pass/shot dir; puckc = X; yc1 = middle; sfslock
	clc
	adc.w #$03E8					; plus 1000
	sta.b crowdlevel
	lda.w #sfspdir|sfssdir			; no pass or shot direction
	trb.w sflags
	ldy.b a2						; a2
	txa								; X's player number
	lsr a
	sta.w puckc						; puck carrier is X
	lda.w Ypos,x					; y of X
	clc
	adc.w Ypos,y					; plus y of a2
	pha
	asl a
	pla
	ror a
	sta.w yc1						; yc1 = the middle
	lda.w #sfslock					; lock the scroll
	tsb.w sflags
	lda.w #$0002					; facing 2
	sta.b d1
	lda.w Xpos,x					; x of X
	sta.b d0
	sec
	sbc.w Xpos,y					; minus x of a2
	bmi .neg2
	bvc .flip
	bra .1
.neg2:								; signed compare: overflow flag corrects the sign
	bvc .1
.flip:
	lda.b d1						; flip the facing
	eor.w #$0007
	sta.b d1
.1:									;face each other
	lda.b d1
	sta.w facedir,x					; X faces a2
	eor.w #$0007
	sta.b d1
	sta.w facedir,y					; and a2 faces X
	jsl.l .sf						; start X's fight
	ldx.b a2						; swap a2 and a3
	ldy.b a3
	stx.b a3
	sty.b a2
	jsl.l .sf						; start the other's fight
	ldx.w #$0000					; others: afwatch (not unavailable, not fighting, not goalies)
	lda.w #afwatch
	sta.b d0
	lda.w #$000B					; 12 players
	sta.b d1
.0:									;the others watch the fight
	lda.w pflags,x					; player flags
	and.w #pf2unav
	ora.w pf2fight,x
	bne .next						; skip unavailable and fighting
	lda.w position,x
	beq .next						; skip goalies
	jsl.l assinsert					; insert assignment d0
.next:
	inx								; next player
	inx
	dec.b d1
	bpl .0
	ldx.w #puckobj					; the puck: pf2fight, pnothing
	lda.w #$0001
	sta.w pf2fight+puckobj			; puck fighting
	lda.w #pnothing
	sta.b d0						; puck does nothing
	jsl.l assinsert					; insert assignment d0
	lda.w #$FFFF
	sta.b collflag					; no transfer
.ex:
	stx.b xsave						; keep X
	ldx.w #$000E
.resta:								; pull a0 and the words after it back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0012
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	ldx.b a3
.rtl:								; return
	rtl
.sf:								;start the fight for X against a2
	ldy.b a2						; impactp = a2
	tya
	lsr a
	sta.w impactp,x
	lda.w #PenFighting				; fighting penalty
	sta.b d0
	jsl.l AddPenalty2				; add it
	txa								; setd0player
	lsr a
	sta.b d0
	jsl.l setd0player				; set up the player
	lda.w #afight					; fight assignment
	sta.b d0
	jsl.l assinsert					; insert assignment d0
	lda.w attribute,x				; Xvel -$400 facing 2, else flipped and +$400
	and.w #~attrxflip&$FFFF
	sta.w attribute,x
	lda.w #$FC00					; -$400
	sta.b d1
	lda.w facedir,x					; facing 2?
	cmp.w #$0002
	beq .sf2
	lda.w attribute,x
	ora.w #attrxflip
	sta.w attribute,x
	lda.w #$0400					; $400
	sta.b d1
.sf2:
	lda.b d1
	sta.w Xvel,x					; x velocity
	lda.w pflags,x					; unavailable, no player coll; pf2aip; SPAfight
	ora.w #pf2npc|pf2unav
	sta.w pflags,x
	stz.w pfalock,x					; clear the lock
	lda.w #SPAfight					; fight animation
	sta.b d1
	sta.w pf2aip,x					; animation in progress
	jmp.w SetSPA					; start the animation
