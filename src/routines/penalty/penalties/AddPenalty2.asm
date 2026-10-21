AddPenalty2:						;Call penalty d0 on player X without the checks; used for forced calls
									;like face offs and game over
	lda.w sfhormode					; horizontal rink: none
	beq .go
	jmp.w .rtl
.go:								; save registers
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d1 and the words after it (2 words)
	lda.b d1,x
	pha
	inx
	inx
	cpx.w #$0004
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
	lda.b d0
	sec
	sbc.w #$000E					; goal and up
	bmi .neg
	bvc .snd
	bra .nosnd
.neg:								; signed compare: overflow flag corrects the sign
	bvc .nosnd
.snd:								;goal and up: crowd and a sound
	lda.b Crowdlevel				; crowd +200
	clc
	adc.w #$00C8
	sta.b Crowdlevel
	lda.w #SFXcrowdboo				; home penalized: boo; visitors: cheer
	pha
	lda.w pfteam,x
	beq .sfx
	lda.w #SFXcrowdcheer
	sta.b $01,s
.sfx:								; play the penalty sound
	jsl.l sfx
.nosnd:								; a1 = PenBuf: 2 bytes per entry (penalty, player)
	lda.w #PenBuf					; a1 = PenBuf, 32 slots
	sta.b a1
	lda.w #PenBuf>>16
	sta.b a1+2
	lda.w #$001F
	sta.b d1
.find:								;find a free PenBuf slot
	lda.b [a1]
	inc.b a1
	inc.b a1
	tay
	beq .put
	dec.b d1
	bpl .find
	bra .noplayer
.put:								; put the penalty in the list
	dec.b a1
	dec.b a1
	txa								; store (SCnum << 8) | penalty
	lsr a
	xba
	and.w #$FF00
	ora.b d0
	sta.b [a1]
	lda.w #Penaltylist>>16			; a0 = Penaltylist + [d0]
	sta.b a0+2
	lda.w #Penaltylist
	sta.b a0
	ldy.b d0
	clc
	adc.b [a0],y
	sta.b a0
	lda.b [a0]						; penalty minutes
	and.w #$00FF
	beq .noplayer
	lda.w pflags,x
	pha
	ora.w #pf2pen					; pf2pen; already set: drop this one
	sta.w pflags,x
	pla
	bit.w #pf2pen
	beq .noplayer
	lda.w #$0000
	sta.b [a1]
.noplayer:							; buffer full or done: restore and return
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
	ldx.w #$0002
.restore:							; pull d1 and the words after it back
	pla
	sta.b d1,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
.rtl:								; return
	rtl
