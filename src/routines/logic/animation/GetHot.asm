GetHot:								;d0 / d1 = the hot spot x / y of object A's current frame
	phx								; keep X
	tay								; object
	stz.b d0						; d0 = 0
	stz.b d1						; d1 = 0
	lda.w frame,y					; frame
	cmp.w #SPFPen					; the hotspot list skips the injury frames
	bcc .remap						; before the injury frames
	sbc.w #SPFPen-SPFfinjury		; skip them
.remap:								; frames past the hotspot list
	cmp.w #(HotListEnd-HotList)/2+1	; frames past the hotspot list
	bcs .ex							; past the list
	dec a							; frame - 1
	bmi .ex							; none
	asl a							; times 2
	tax
	lda.l HotList,x					; HotList x
	and.w #$00FF					; byte
	bit.w #$0080					; signed
	beq .hx
	ora.w #$FF00					; sign extend
.hx:								; hot x done: get hot y
	sta.b d0						; hot x
	lda.l HotList+1,x				; HotList y
	and.w #$00FF					; byte
	bit.w #$0080					; signed
	beq .hy
	ora.w #$FF00					; sign extend
.hy:								; hot y done: check the x flip
	sta.b d1						; hot y
	lda.w attribute,y				; attribute
	bit.w #attrxflip				; x flip
	beq .nox						; no x flip
	lda.b d0
	eor.w #$FFFF					; negate x
	inc a
	sta.b d0
.nox:								; attribute bit 4 clear: negate hot y
	lda.w attribute,y				; attribute
	bit.w #attryflip				; y flip (clear = negate)
	bne .noy						; y flip
	lda.b d1						; negate y
	eor.w #$FFFF					; negate
	inc a
	sta.b d1						; hot y
.noy:								; horizontal screen: swap the axes
	lda.w sfhormode					; horizontal mode: rotate
	beq .ex							; vertical mode
	lda.b d0						; rotate by 90 degrees
	ldy.b d1
	eor.w #$FFFF					; negate
	inc a
	sta.b d1
	sty.b d0						; swap x and y
.ex:								; restore registers, drop the argument
	plx								; restore X
	rtl
