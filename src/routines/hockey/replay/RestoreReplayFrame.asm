RestoreReplayFrame:					;Put one recorded replay frame back into the
									;objects, the puck and the screen
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d0 and the words after it (6 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$000C
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0000
.savea:								; save a0 and the words after it (2 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0004
	bne .savea
	ldx.b xsave						; restore X
	lda.b a4						; a0 = a4 (the record)
	sta.b a0
	lda.b a4+2
	sta.b a0+2
	lda.w #$000F					; 16 objects
	sta.b d1
	ldx.w #$0000
.top:								;16 objects
	lda.b [a0]						; x, low 12 bits
	and.w #$0FFF
	bit.w #$0800					; sign extend
	beq .p
	ora.w #$F000
.p:									; Xpos
	sta.w Xpos,x					; Xpos
	inc.b a0
	lda.b [a0]						; y, upper bits
	lsr a
	lsr a
	lsr a
	lsr a
	bit.w #$0800					; sign extend
	beq .p1
	ora.w #$F000
.p1:								; store the sign extended y
	sta.w Ypos,x					; Ypos
	inc.b a0
	inc.b a0
	lda.b [a0]
	and.w #$3FFF					; frame, low 14 bits
	sta.w frame,x
	lda.w attribute,x
	and.w #$E7FF					; clear the flip bits
	sta.w attribute,x
	lda.b [a0]						; attribute bits
	lsr a
	lsr a
	lsr a
	and.w #$1800					; put the flip bits back
	ora.w attribute,x
	sta.w attribute,x
	inc.b a0
	inc.b a0
	inx
	inx
	dec.b d1
	bpl .top
	lda.w #$0005					; 6 pairs
	sta.b d2
	ldx.w #$0000
.pl:								;6 pairs of players
	lda.b [a0]						; roster number of the first
	inc.b a0
	and.w #$00FF
	sta.w rostnum,x					; store it
	lda.b [a0]						; roster number of the second
	inc.b a0
	and.w #$00FF
	sta.w rostnum+2,x
	lda.b [a0]						; position of the first
	and.w #$000F
	cmp.w #$000F					; $F means none
	bne .n0
	lda.w #$FFFF
.n0:								; position of the first player of the pair
	sta.w position,x				; store it
	lda.b [a0]						; position of the second
	lsr a
	lsr a
	lsr a
	lsr a
	and.w #$000F
	cmp.w #$000F
	bne .n1
	lda.w #$FFFF
.n1:								; position of the second player
	sta.w position+2,x				; store it
	inc.b a0
	inx
	inx
	inx
	inx
	dec.b d2
	bpl .pl
	lda.b [a0]						; puck height
	inc.b a0
	and.w #$00FF
	bit.w #$0080
	beq .pz
	ora.w #$FF00
.pz:								; puck shadow height is zero: skip it
	sta.w Zpos+puckobj				; store it
	lda.b [a0]						; puck shadow height
	inc.b a0
	and.w #$00FF
	bit.w #$0080
	beq .sz
	ora.w #$FF00
.sz:								; no sound effect to restore
	sta.w Zpos+puckobj+2			; store it
	lda.b [a0]						; last sound effect
	inc.b a0
	and.w #$00FF
	sta.w lastsfx
	lda.b [a0]
	inc.b a0
	and.w #$00FF
	sta.b d7						; d7 counter
	lda.w PadControlBits			; PadControlBits low 12 bits
	and.w #$F000
	sta.w PadControlBits
	lda.b [a0]						; pad control bits
	inc.b a0
	inc.b a0
	and.w #$0FFF
	ora.w PadControlBits
	sta.w PadControlBits
	lda.b [a0]						; crowd frame
	inc.b a0
	inc.b a0
	sta.b Crowdframe
	lda.b [a0]						; glove coordinates
	inc.b a0
	inc.b a0
	sta.w glovecords
	lda.b [a0]						; player button number
	inc.b a0
	and.w #$00FF
	bit.w #$0080
	beq .pb
	ora.w #$FF00
.pb:								; no puck bounce number to restore
	sta.w PBnum						; store it
	lda.w sflags					; sfscrl: keep Hpos/Vpos
	bit.w #sfscrl
	bne .x
	lda.b [a0]						; horizontal scroll
	inc.b a0
	inc.b a0
	sta.w Hpos
	lda.b [a0]						; vertical scroll
	sta.w Vpos
.x:									; restore registers
	stx.b xsave						; keep X
	ldx.w #$0002
.resta:								; pull a0 and the words after it back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$000A
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	rtl
