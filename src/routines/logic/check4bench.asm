check4bench:						;If a line change wants player X off, send him to the bench (or just
									;change his position when he stays on)
	lda.w pflags,x					; flags
	bit.w #pfjoycon|pf2pen			; joystick controlled, or penalty
	bne .rts						; human or penalty: leave
	lda.w newpos,x					; new position
	bpl .b							; newpos negative: only a new roster player counts
	lda.w newpnum,x					; new roster player
	bmi .rts						; none: leave
.b:									;newpos or newpnum requested
	lda.w newpnum,x					; new roster player
	cmp.w pnum,x					; same roster player: just a position change
	beq .samepl						; same player
	txa								; current assignment: asslist+X*4+assnum
	asl a
	asl a
	adc.w assnum,x
	tay
	lda.w asslist,y					; current assignment
	and.w #$00FF					; byte
	cmp.w #abench					; already going to the bench
	beq .rts						; going to the bench: leave
	txa
	lsr a
	cmp.w puckc						; puck carrier stays
	beq .rts						; puck carrier stays
	sep #$20						; pop the jsl return address
	pla								; pop the jsl return address
	rep #$30						; 16-bit registers
	pla
	lda.w pflags,x					; flags
	ora.w #pf2unav					; pf2unav
	sta.w pflags,x					; store
	stz.w temp1,x					; clear temp1
	lda.w #abench					; abench
	sta.b d0						; d0 = bench assignment
	jmp.w assreplace				; replace the assignment
.rts:								; return
	rtl
.samepl:							;same roster player: just change position
	sep #$20						; pop the jsl return address
	pla								; pop the jsl return address
	rep #$30						; 16-bit registers
	pla
	lda.w pflags,x					; flags
	and.w #~pf2unav&$FFFF			; clear pf2unav
	sta.w pflags,x					; store
	stz.w pfnc,x					; clear pfnc
	lda.w #$FFFF					; none requested
	sta.w newpnum,x					; newpnum
	sta.w newpos,x					; newpos
	lda.w position,x				; d0 = position (newpos is negative here)
	sta.b d0						; d0 = position
	jmp.w Setplass					; new assignment from the position
