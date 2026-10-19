setffo:								;Update the pads, then draw the objects tied to rink scrolling (the pad
									;labels and gloves)
	jsl.l uppads					; update the pad objects
	ldx.w #$0000					; object offset
.top:
	cpx.w #$0006					; pad 3 and up?
	bne .obj
	jmp.w .next						; pad 3: not drawn
.obj:
	lda.w ffox,x					; x
	sta.b d0
	lda.w ffoy,x					; y
	sta.b d1
	lda.w ffoz,x					; hidden
	bpl .shown
	jmp.w .next
.shown:
	sta.b d2						; z
	jsl.l find3d					; 3d to screen position
	cmp.w #OFFSCREEN				; off screen?
	bne .add
	jmp.w .next
.add:
	sta.b spry						; screen y
	lda.b d0						; screen x
	sta.b sprx						; x
	lda.w ffoframe,x				; frame, flip bits from ffoattr
	sta.b sprframe					; ffo frame
	lda.b ffoattr,x					; sprite frame
	and.w #$0800					; attribute flip bits
	sta.b sprhflip					; horizontal flip
	lda.b ffoattr,x
	and.w #$1000					; vertical flip
	sta.b sprvflip
	phx								; keep the object offset
	jsl.l addframe					; sprframe at sprx/spry
	plx								; restore the offset
	cpx.w #$0006					; gloves: no label
	bcc .label
	jmp.w .next
.label:								;label: two digits (rostnum, $A+ = blank) and a position letter
	ldy.w #$0000					; mesarea+2 = label tiles, mesarea = count; d0 moves left 4 per digit
	lda.w padcont,x					; pad label code
	lsr a
	lsr a
	lsr a
	lsr a
	and.w #$000F					; high digit
	beq .lo							; zero: skip it
	cmp.w #$000A					; digits above 9: skip the label
	bcc .hi
	jmp.w .next
.hi:
	sta.w mesarea+2,y				; store the digit
	iny								; next character
	dec.b d0						; move the label left
	dec.b d0
	dec.b d0
	dec.b d0
.lo:
	lda.w padcont,x					; pad label code
	and.w #$000F					; low digit
	cmp.w #$000A					; above 9: skip the label
	bcs .next
	sta.w mesarea+2,y				; store the digit
	iny								; next character
	dec.b d0						; move the label left
	dec.b d0
	dec.b d0
	dec.b d0
	lda.w padcont+1,x				; position letter from ButtonLabelCharTable, after a blank
	and.w #$0007					; position letter
	beq .draw
	adc.w #ButtonLabelCharTable-1	; letter table entry
	sta.b a4
	lda.w #ButtonLabelCharTable>>16
	sta.b a4+2
	lda.b d0						; left 6 more
	sec
	sbc.w #$0006
	sta.b d0
	lda.w #$FFFF
	sta.w mesarea+2,y				; blank first
	iny
	lda.b [a4]
	sta.w mesarea+2,y				; then the letter
	iny
.draw:
	sty.w mesarea					; number of characters
	stz.b d0+2						; character counter
.ch:								; check whether all are drawn
	ldy.b d0+2
	cpy.w mesarea					; all drawn?
	beq .next
	lda.w mesarea+2,y				; character
	and.w #$00FF
	cmp.w #$00FF					; blank?
	beq .sp
	adc.w #SPFsmallfont				; glyph index plus the label sprites
	sta.b sprframe					; sprite frame
	lda.b d0						; x
	sta.b sprx
	lda.b d1						; y plus 10
	clc
	adc.w #$000A
	sta.b spry
	phx
	jsl.l addframe					; sprframe at sprx/spry
	plx
	inc.b d0						; advance 4 pixels
	inc.b d0
	inc.b d0
	inc.b d0
.sp:								;blank: 4 pixels
	inc.b d0						; blank advances 4 pixels
	inc.b d0
	inc.b d0
	inc.b d0
	inc.b d0+2						; next character
	bra .ch
.next:
	inx								; next object
	inx
	cpx.w #$000A					; all objects done?
	beq .rtl
	jmp.w .top
.rtl:								; return
	rtl
