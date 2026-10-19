CompLine:							;The computer team picks a line by the man advantage, the score late in
									;the game and the line energies
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
	lda.w #$0003					; default line 3
	sta.b d0
	ldy.b a2						; power play times of both teams
	lda.w tmap,y
	ldy.b a1
	cmp.w tmap,y					; compare with the other team
	beq .nopwr						; equal: no power play
	bpl .0							; sign of the difference
	inc.b d0						; line 5 on the other side
	inc.b d0
.0:
	lda.b d0
	pha								; keep the line
	jsl.l getlinee					; energy of that line
	lda.b d0
	sta.b d1						; d1 = its energy
	lda.b $01,s						; the next line
	inc a
	sta.b d0
	jsl.l getlinee					; energy of the next line
	lda.b d1
	sec
	sbc.b d0
	bmi .d1neg						; compare the two energies
	bvs .vs
	bra .1
.d1neg:
	bvs .1
.vs:
	pla
	inc a							; line + 1
	pha
.1:
	pla
	ldy.b a2
	sta.w tmline,y					; store the chosen line
.ex:
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
.nopwr:
	ldy.b a2						; team a2 is the home team?
	bne .away
	lda.w #$0002					; three lines to try
	sta.b d1
	lda.w #.hl1						; home line tables
	sta.b a0
	lda.w #.hl1>>16
	sta.b a0+2
	lda.w gsp						; third period?
	cmp.w #$0002
	bne .h0
	lda.w tmscore,y					; score
	ldy.b a1
	cmp.w tmscore,y					; against the other score
	beq .h0							; tied: use the tied table
	php
	lda.w #.ahead					; ahead table
	sta.b a0
	plp
	bpl .h0
	lda.w #.behind					; behind table
	sta.b a0
.h0:
	ldy.b a1
	lda.w tmline,y					; current line
	asl a							; table index
	sta.b d1
	tay
	lda.b [a0],y					; table entry: next line
	sta.b d0
	jsl.l getlinee					; energy of that line
	lda.b d0
	cmp.w #$0C01					; enough energy?
	bcc .away
	ldy.b d1
	lda.b [a0],y					; take the table entry
	ldy.b a2
	sta.w tmline,y					; store it as the line
	bra .ex
.hl1:								;CompLine tables: next line by tmline, score tied (7 words)
	dw 0,1,2,0,1,0,1
.ahead:								;ahead in the third period
	dw 2,0,1,2,0,2,0
.behind:							;behind in the third period
	dw 0,1,0,0,1,0,1
.away:
	lda.w #$0002					; three lines to try
	sta.b d1
	lda.w #.al1						; away line table
	sta.b a0
	lda.w #.al1>>16
	sta.b a0+2
	lda.w gsp						; third period?
	cmp.w #$0002
	bne .a0
	ldy.b a2
	lda.w tmscore,y					; score
	ldy.b a1
	cmp.w tmscore,y					; against the other score
	beq .a0							; tied: use the tied table
	php
	lda.w #.ahead2					; ahead table
	sta.b a0
	plp
	bpl .a0
	lda.w #.behind2					; behind table
	sta.b a0
.a0:
	lda.b [a0]						; next line to try
	inc.b a0
	inc.b a0
	sta.b d0
	jsl.l getlinee					; energy of that line
	lda.b d0
	cmp.w #$0F34					; enough energy?
	bcs .got
	dec.b d1						; else try the next line
	bpl .a0
.got:
	dec.b a0
	dec.b a0
	ldy.b a2
	lda.b [a0]						; chosen line
	sta.w tmline,y					; store it
	jmp.w .ex
.al1:								;the lines tried on a power play / penalty kill (3 words each)
	dw 0,1,2
.ahead2:
	dw 0,2,1
.behind2:
	dw 0,1,0
