GetHot:		;d0 / d1 = the hot spot x / y of object A's current frame
	phx
	tay
	stz.b d0
	stz.b d1
	lda.w frame,y
	cmp.w #SPFPen		; the hotspot list skips the injury frames
	bcc .remap
	sbc.w #SPFPen-SPFfinjury
.remap:
	cmp.w #(HotListEnd-HotList)/2+1		; frames past the hotspot list
	bcs .ex
	dec a
	bmi .ex
	asl a
	tax
	lda.l HotList,x		; HotList x
	and.w #$00FF
	bit.w #$0080
	beq .hx
	ora.w #$FF00
.hx:
	sta.b d0
	lda.l HotList+1,x		; HotList y
	and.w #$00FF
	bit.w #$0080
	beq .hy
	ora.w #$FF00
.hy:
	sta.b d1
	lda.w attribute,y
	bit.w #attrxflip		; x flip
	beq .nox
	lda.b d0
	eor.w #$FFFF
	inc a
	sta.b d0
.nox:
	lda.w attribute,y
	bit.w #attryflip		; y flip (clear = negate)
	bne .noy
	lda.b d1
	eor.w #$FFFF
	inc a
	sta.b d1
.noy:
	lda.w sfhormode		; horizontal mode: rotate
	beq .ex
	lda.b d0
	ldy.b d1
	eor.w #$FFFF
	inc a
	sta.b d1
	sty.b d0
.ex:
	plx
	rtl
