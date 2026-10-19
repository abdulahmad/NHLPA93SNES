changeplayer:						;Switch controller d4 to the teammate nearest the puck, or sweep check if
									;that is already the player
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d0 and the words after it (14 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$001C
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0000
.savea:								; save a0 and the words after it (4 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0008
	bne .savea
	ldx.b xsave						; restore X
	lda.w puckvy					; puck + velocity/256 (lead the puck)
	xba
	and.w #$00FF					; sign extend
	bit.w #$0080
	beq .ly
	ora.w #$FF00
.ly:								; candidate y relative to the puck
	clc
	adc.w pucky						; plus the puck y
	pha								; keep it
	lda.w puckvx					; puck x velocity high byte
	xba
	and.w #$00FF
	bit.w #$0080
	beq .lx
	ora.w #$FF00
.lx:								; candidate x relative to the puck
	clc
	adc.w puckx						; plus the puck x
	pha
	lda.w #$0005					; 6 players
	sta.b d2
	lda.b d4						; controller number
	tay
	eor.w #$0002					; d3 = the other controller
	sta.b d3
	lda.w #$FFFF					; d5 = best distance^2
	sta.b d5+2
;search the 6 teammates of controller d4 (d3 = the other controller) for the one nearest the lead point
	ldx.w #$0000
	lda.w cont1team,y				; controller on the home team: players 0-5, else 6-11
	cmp.w #$0001
	beq .t1
	ldx.w #$000C					; second team starts at $0C
.t1:
	ldy.b d3						; other controller
.top:
	lda.w position,x				; position
	bmi .next						; skip empty slots
	beq .next						; skip goalies
	lda.w pflags,x					; pf2unav or pfalock: skip
	and.w #pf2unav
	ora.w pfalock,x
	bne .next
	lda.b $01,s						; target x
	sec
	sbc.w Xpos,x					; minus the player x
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	sta.b d0
	lda.b mulres+2
	sta.b d0+2
	lda.b $03,s						; target y
	sec
	sbc.w Ypos,x					; minus the player y
	sta.b mula
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	adc.b d0						; sum
	sta.b d0
	lda.b mulres+2
	adc.b d0+2
	sta.b d0+2
	lda.b d5						; best distance
	cmp.b d0
	lda.b d5+2
	sbc.b d0+2
	bcc .next
	txa
	lsr a
	cmp.w c1playernum,y				; the other controller has him
	beq .next
	sta.b d6						; best player so far
	lda.b d0
	sta.b d5
	lda.b d0+2
	sta.b d5+2
.next:								; next candidate
	inx
	inx
	dec.b d2
	bpl .top
	ldx.b a3						; restore X
	pla								; drop the target
	pla
	ldy.b d4						; controller number
	lda.b d6
	cmp.w c1playernum,y				; same player: Sweepcheck
	bne .set
	jsl.l Sweepcheck				; sweep check
	bra .ex
.set:
	sta.b d0						; new player in d0
	lda.b d4
	bne .c2
	jsl.l setc1player				; controller 1 gets the player
	bra .ex
.c2:
	jsl.l setc2player				; controller 2 gets the player
.ex:
	stx.b xsave						; keep X
	ldx.w #$0006
.resta:								; pull a0 and the words after it back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$001A
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
