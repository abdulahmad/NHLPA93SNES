SetInst:							;Start a fight between X and a2 when both are aggressive enough; if X was
									;shoulder checking, an
		;   instigator penalty goes to one of his teammates
	lda.w fighting,x
	cmp.b d0						; fighting rating threshold in d0
	bcc checkfight_rtl
	ldy.b a2						; tmp0 = fighting of a2 >= 2
	lda.w fighting,y				; fighting of the opponent
	sta.b tmp0
	sec
	sbc.w #$0002
	bmi .neg						; both need fighting >= 2
	bvc .r2
.ex1:								; far branch to checkfight_rtl
	jmp.w checkfight_rtl
.neg:								; signed compare: overflow flag corrects the sign
	bvc .ex1
.r2:								; d1 = $10 - 2 * the checks of a2
	lda.w pnum,y					; d1 = $10 - 2 * a2 checks
	sta.b d1
	lda.w pfteam,y
	beq .tm
	lda.w #$001A
.tm:								; team offset of the player
	clc
	adc.w pnum,y
	tay
	lda.w pchecks,y					; checks counter of the opponent
	and.w #$00FF
	bit.w #$0080
	beq .cnt
	ora.w #$FF00
.cnt:								; times 2 (sign-extended)
	asl a							; sign-extended, times 2
	eor.w #$FFFF					; negate
	inc a
	clc
	adc.w #$0010					; d1 = $10 - 2 * checks
	sta.b d1
	ldy.b a2
	sec
	sbc.b tmp0						; compare with the first player's fighting rating
	beq .set
	bmi .neg1
	bvs .set
.ex2:								; far branch to checkfight_rtl
	jmp.w checkfight_rtl
.neg1:								; signed compare: overflow flag corrects the sign
	bvs .ex2
.set:								; flag both players as fighting
	lda.w #$0001					; flag both players as fighting
	sta.w pf2fight,x				; pf2fight of X
	sta.w pf2fight,y				; pf2fight of the opponent
	jmp.w .inst
.inst:								;X in a shoulder check: PenInst for the first teammate on the ice without
									;a penalty
	jsl.l sndqreset					; sound reset
	lda.w SPA,x						; SPA of X
	cmp.w #SPAshoulderchkl			; only while shoulder checking
	beq .chk
	cmp.w #SPAshoulderchkr
	bne .rtl
.chk:								; check the 6 teammates
	stx.b a4						; keep X
	lda.w #$0005					; check 6 teammates
	sta.b d0
	stz.b a3						; a3 = first player of the team
	lda.w pfteam,x
	beq .1
	lda.w #$000C					; other team: first slot at $0C
	sta.b a3
.1:									; skip the player himself
	ldx.b a3
	cpx.b a4						; skip X himself
	beq .next
	lda.w position,x				; skip position 0 and negative
	bmi .next
	beq .next
	lda.w pflags,x
	bit.w #pf2pen|pf2unav			; skip players already penalised or unavailable
	bne .next
	lda.w #PenInst					; instigator penalty
	sta.b d0
	jsl.l AddPenalty2				; add it to the first eligible teammate
	ldx.b a4						; restore X
	stx.b a3
.rtl:								; return
	rtl
.next:								; next object
	inc.b a3
	inc.b a3
	dec.b d0
	bpl .1
	ldx.b a4
	stx.b a3
	rtl
