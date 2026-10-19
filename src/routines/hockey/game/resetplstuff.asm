resetplstuff:						;Reset the team variables and the players on both teams
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
.savea:								; save a0 and the words after it (8 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0010
	bne .savea
	ldx.b xsave						; restore X
	stz.b a2
	jsl.l .top
	lda.w #$0002
	sta.b a2
	jsl.l .top
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
	ldx.w #$000A
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	ldx.b a3
	rtl
.top:								;team a2
	ldy.b a2
	lda.w tmflags,y
	and.w #~tmfoside&$FFFF			; clear tmfoside
	sta.w tmflags,y
	lda.w #$0005
	sta.b d2
	ldx.w tmsort,y
	stx.b a3
.loop:								; pf2fight = pf2aip = 0, pflags
	stz.w pf2fight,x				; pf2fight = pf2aip = 0, pflags2 bits cleared
	stz.w pf2aip,x
	lda.w pflags,x
	and.w #~(pf2unav|pf2lcm|pf2pen|pf2npc)&$FFFF
	sta.w pflags,x
	lda.w position,x
	bmi .next
	lda.w #SPAglide
	sta.b d1
	jsl.l SetSPA					; start animation d1
	stz.w impact,x					; impact = 0, nopuck = 0
	stz.w nopuck,x
	lda.w pflags,x
	and.w #~(pfdoff|pfjoycon)&$FFFF	; keep pfteam/pfgoal/pfna: clear pfdoff, pfjoycon
	sta.w pflags,x
	stz.w pfnc,x
	stz.w pfrev,x
	stz.w pfalock,x
.next:								; next object
	inc.b a3
	inc.b a3
	ldx.b a3
	dec.b d2
	bpl .loop
	rtl
