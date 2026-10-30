InProgress:							;The referee's work after a whistle: send each penalized player to the
									;box, update the scoreboard and stats,
									;then recount the players and go to the face off
	lda.w RefCnt					; animation in progress: exit
	bmi .step
	jmp.w .rtl
.step:								; only act when RefStep is set
	lda.w RefStep
	bmi .go
	jmp.w .rtl
.go:								; save registers
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d0 and the words after it (2 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0004
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
.top:								; walk the penalty buffer from the start
	lda.w #$0000					; walk the penalty buffer from the start
	sta.b a0+2
	lda.w #PenBuf
	sta.b a0
	lda.b [a0]						; empty buffer: leave
	inc.b a0
	inc.b a0
	cmp.w #$0000
	bne .0
	jmp.w .exit
.0:									;find the end of the list
	lda.b [a0]						; scan to the end of the list
	inc.b a0
	inc.b a0
	cmp.w #$0000
	bne .0
	dec.b a0
	dec.b a0
	dec.b a0
	dec.b a0
	lda.b [a0]						; clear bit 15 of the entry (first pass)
	pha
	and.w #$7FFF
	sta.b [a0]
	pla
	bmi .Sa
	lda.b [a0]						; later pass: clear it when the player left the ice
	xba
	and.w #$00FF
	asl a
	sta.b d1
	tay
	lda.w position,y				; player no longer on the ice?
	bmi .clr
	jmp.w .ex
.clr:								; clear the entry
	lda.w #$0000
	sta.b [a0]
	jmp.w .ex
.Sa:								; new penalty entry
	lda.b [a0]						; d2 = penalty minutes; none: no player involved
	and.w #$00FF
	sta.b d0
	tay
	lda.w #Penaltylist				; Penaltylist entry for this penalty
	sta.b a1
	lda.w #Penaltylist>>16
	sta.b a1+2
	lda.b [a1],y
	clc
	adc.b a1
	sta.b a1
	lda.b [a1]						; penalty minutes
	and.w #$00FF
	sta.b d2
	bne .min						; no minutes: no player involved
	jmp.w .sa2
.min:								; save registers
	stx.b xsave						; keep X
	ldx.w #$0000
.save2:								; save d0 and the words after it (4 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0008
	bne .save2
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0000
.savea2:							; save a1 and the words after it (8 words)
	lda.b a1,x
	pha
	inx
	inx
	cpx.w #$0010
	bne .savea2
	ldx.b xsave						; restore X
	jsl.l GetPeriodTimeRemaining	; period time remaining
	lda.b [a0]						; player offset of the penalized player
	xba
	and.w #$00FF
	asl a
	sta.b d1
	tax
	stx.b a3
	stz.b d0
	stz.b a2						; a2 = penalized team, a1 = other; d0 = $8000 for the visitors
	lda.w #$0002
	sta.b a1
	lda.w pfteam,x
	beq .sa1
	lda.w #$8000
	sta.b d0
	stz.b a1
	lda.w #$0002
	sta.b a2
.sa1:								; team penalty count
	ldy.b a2						; tmPenalties +1, tmPenmin += minutes
	lda.w tmPenalties,y
	inc a
	sta.w tmPenalties,y
	lda.w tmPenmin,y
	clc
	adc.b d2
	sta.w tmPenmin,y
	lda.w pnum,x					; TempPlOffset = pnum | visitors
	and.w #$00FF					; team and player number in TempPlOffset
	ora.b d0
	sta.w TempPlOffset
	and.w #$00FF
	bit.w #$0080
	beq .pn
	ora.w #$FF00
.pn:								; player number to a table offset
	asl a
	sta.b d0
	lda.w #$003C					; d2 = minutes*60 | $2000
	sta.b mula
	lda.b d2
	and.w #$00FF
	sta.b mulb
	jsl.l mulu16					; mulu, A = mula*mulb
	ora.w #$2000
	sta.b d2
	lda.b a2
	beq .tm
	lda.w #maxros*2
.tm:								; add the team offset
	clc
	adc.b d0
	tay
	lda.w tmpdst,y					; keep TMPDINJ of an old penalty time
	bmi .st
	and.w #TMPDINJ
	tsb.b d2
.st:								; store the penalty time for the player
	lda.b d2
	sta.w tmpdst,y
	lda.w #TMPDINJ
	trb.b d2
	lda.w #(maxros-1)*2+2			; compare with the other team
	sta.b d1
.ctop:								;same time on the other team: coincidental
	dec.b d1
	dec.b d1
	bmi .nocoin
	lda.b a1
	beq .ct
	lda.w #maxros*2
.ct:								; other team slot of the same time
	clc
	adc.b d1
	tay
	lda.w tmpdst,y
	and.w #~TMPDINJ&$FFFF
	sta.b d3
	cmp.b d2
	bne .ctop
	lda.w tmpdst,y					; coincidental: $4000 on both
	ora.w #$4000
	sta.w tmpdst,y
	lda.b a2
	beq .cg
	lda.w #maxros*2
.cg:								; mark the penalized player as well
	clc
	adc.b d0
	tay
	lda.w tmpdst,y
	ora.w #$4000
	sta.w tmpdst,y
.nocoin:							;add the player to the penalty box list
	lda.b a0+2						; keep a0
	pha
	lda.b a0
	pha
	lda.b a2
	beq .bl
	lda.w #maxros
.bl:								; box list start of the penalized team
	sta.b a0
	lda.w #$0018
	sta.b d1
.pl:								; find a free slot in the box list
	ldy.b a0
	inc.b a0
	lda.w tmboxlist,y
	bit.w #$0080					; free slot?
	bne .put
	dec.b d1
	bpl .pl
.put:								; put the player into the box list
	lda.b d0
	ora.w #$FF00
	sta.w tmboxlist,y
	pla
	sta.b a0
	pla
	sta.b a0+2
	lda.w #apenalty					; penalized player goes to the box
	sta.b d0
	jsl.l assreplace				; replace the assignment with d0
	stx.b xsave						; keep X
	ldx.w #$000E
.resta2:							; pull a1 and the words after it back
	pla
	sta.b a1,x
	dex
	dex
	bpl .resta2
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0006
.restore2:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore2
	ldx.b xsave						; restore X
	ldx.b a3						; SetPA, USBoard
	jsl.l SetPA
	jsl.l USBoard
	bra .ex
.sa2:								; no player involved: drop the entry
	lda.w #$0000					; no minutes: clear it, SetPA
	sta.b [a0]
	lda.w sfhormode
	beq .sa3
	jmp.w .top
.sa3:								; start the animation
	jsl.l SetPA
	bra .ex
.exit:								; PenBuf empty: recount the players on ice for both teams
	stz.b a2						; coinsearch for both teams, clear gmpen, the puck: pfaceoff
	jsl.l coinsearch
	lda.w #$0002
	sta.b a2
	jsl.l coinsearch
	lda.w #gmpen					; penalty mode over
	trb.w gmode
	ldx.w #puckscnum
	stx.b a3
	lda.w #pfaceoff					; puck goes to the faceoff assignment
	sta.b d0
	jsl.l assreplace				; replace the assignment with d0
.ex:								; restore and return
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
	ldx.w #$0002
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
