checkplcoll:						;Check object X against the objects near it in y
	lda.w pflags,x					; player flags
	bit.w #pf2npc					; object doesn't collide with players?
	beq .pl
	jmp.w .ex
.pl:
	cpx.w #$0018					; only the first 12 objects (players)
	bcc .go
	jmp.w .ex
.go:
	lda.w OOlistpos,x				; d1 = position of X in OOlist
	sta.b d1						; X's index in the sorted list
.0:									;objects higher in the list
	ldy.b d1						; next object up the list
	cpy.w #$000F					; top of the list
	beq .cl
	lda.w OOlist+1,y				; its object number
	and.w #$00FF
	sta.b d4
	tay
	lda.w Ylist,y					; its y
	sec
	sbc.b d3						; minus the y of X
	sta.b d5
	sec
	sbc.w #$000E					; more than 14 away in y?
	beq .uy
	bmi .neg
	bvs .uy
	bra .cl
.neg:
	bvs .cl
.uy:
	lda.w Xpos,y					; its x
	sec
	sbc.b d2						; minus the x of X
	bit.w #$8000
	beq .ux
	eor.w #$FFFF					; negate
	inc a
.ux:
	cmp.w #$000F					; within 15 in x?
	bcs .unext
	lda.w pflags,y					; not npc, nc, players only
	and.w #pf2npc
	ora.w pfnc,y
	bne .unext
	cpy.w #$0018
	bcs .unext
	jsl.l checkcx					; check the pair
.unext:
	inc.b d1						; next up
	bra .0
.cl:								;objects lower in the list
	lda.w OOlistpos,x				; X's index in the sorted list
	beq .ex							; at the bottom: done
	sta.b d1
.1:
	ldy.b d1
	lda.w OOlist-1,y				; next object down the list
	and.w #$00FF
	sta.b d4
	tay
	lda.b d3
	sec
	sbc.w Ylist,y					; y of X minus its y
	sta.b d5
	sec
	sbc.w #$000E					; more than 14 away in y?
	beq .dy
	bmi .neg1
	bvs .dy
	bra .ex
.neg1:
	bvs .ex
.dy:
	lda.w Xpos,y					; its x
	sec
	sbc.b d2						; minus the x of X
	bit.w #$8000
	beq .dx
	eor.w #$FFFF					; negate
	inc a
.dx:
	cmp.w #$000F					; within 15 in x?
	bcs .dnext
	lda.w pflags,y
	and.w #pf2npc
	ora.w pfnc,y
	bne .dnext
	cpy.w #$0018					; players only
	bcs .dnext
	jsl.l checkcx					; check the pair
.dnext:
	dec.b d1						; next down
	bne .1
.ex:
	rtl
