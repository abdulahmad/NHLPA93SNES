printbig:							;print with the big font (2 by 2 tiles per character)
	phx								; save X
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
	ldy.w #$0002					; y = 2: after the length word
.top:								; end of the string?
	tya								; end of the string?
	cmp.b [a1]
	bne .ch
	jmp.w .done						; done
.ch:								; d1 = textmap offset (printy * 32 + printx) * 2
	lda.w printy					; d1 = textmap offset (printy * 32 + printx) * 2
	asl a
	asl a
	asl a
	asl a
	asl a
	adc.w printx
	asl a
	sta.b d1
	lda.b [a1],y					; next character
	bit.w #$0080					; bit 7: control code
	beq .dochar
	jmp.w .code
.dochar:							; no special case for space
	and.w #$00FF					; character code
	bne .lc
	jmp.w .nextch					; zero: skip it
.lc:								; lower case to upper case
	cmp.w #'a'						; lower case to upper case
	bcc .uc
	cmp.w #'z'+1
	bcs .uc
	adc.w #-32						; subtract 32 for the big font
.uc:								; space: blank
	sec								; space: blank
	sbc.w #' '
	bne .wide
	jmp.w .blank
.wide:								; d2 = 1: two columns wide
	stz.b d2						; d2 = 1: two columns wide
	inc.b d2
	tax								; index
	lda.l BigFontIndex,x			; character width/tile table (BigFontIndex): negative = 1 column
	and.w #$00FF
	bit.w #$0080
	beq .w0
	ora.w #$FF00
.w0:								; negative: one column wide
	cmp.w #$0000					; negative: one column wide
	bpl .w1
	eor.w #$FFFF					; negate
	inc a
	stz.b d2						; d2 = 0
.w1:								; word offset
	asl a							; word offset
	sta.b d0						; keep it
	tax
	lda.l BigFontMap,x				; big font map (BigFontMap): top left
	clc
	adc.w BigFontChars				; plus the big font tile base
	adc.w printfontset				; plus the font set
	ora.w printa					; plus the palette and priority
	ldx.b d1
	sta.l textmap,x					; top left tile
	txa
	lsr a
	cmp.b textdirtylo				; update the dirty range low
	bcs .lo
	sta.b textdirtylo
.lo:								; low end of the dirty range
	clc
	adc.w #$0021
	cmp.b textdirtyhi				; and the high end
	bcc .bot
	sta.b textdirtyhi
.bot:								; bottom row of the big char
	ldx.b d0
	lda.l BigFontMap+(76*2),x		; bottom left
	clc
	adc.w BigFontChars
	adc.w printfontset
	ora.w printa
	ldx.b d1
	sta.l textmap+(1*$40)+(0*2),x	; bottom left tile
	lda.b d2						; two columns wide?
	beq .next
	ldx.b d0
	lda.l BigFontMap+2,x			; top right
	clc
	adc.w BigFontChars
	adc.w printfontset
	ora.w printa
	ldx.b d1
	sta.l textmap+2,x				; top right tile
	ldx.b d0
	lda.l BigFontMap+(76*2)+2,x		; bottom right
	clc
	adc.w BigFontChars
	adc.w printfontset
	ora.w printa
	ldx.b d1
	sta.l textmap+(1*$40)+(1*2),x	; bottom right tile
	inc.w printx					; extra column
.next:								; next column
	inc.w printx					; next column
.nextch:							; next character
	iny								; next character
	jmp.w .top
.blank:								; blank: big font entry $2C
	lda.l BigFontMap+$2C			; blank: big font entry $2C on both rows
	clc
	adc.w BigFontChars
	adc.w printfontset
	ora.w printa
	ldx.b d1
	sta.l textmap,x					; top blank tile
	sta.l textmap+(1*$40)+(0*2),x	; bottom blank tile
	txa
	lsr a
	cmp.b textdirtylo				; dirty range low
	bcs .bl1
	sta.b textdirtylo
.bl1:								; bottom row high end
	clc
	adc.w #$0020					; and the high end
	cmp.b textdirtyhi
	bcc .next
	sta.b textdirtyhi
	bra .next
.code:								;control byte -$ab, x, y: attribute b, map a
	eor.w #$FFFF					; negate
	inc a
	pha								; $01,s = the control record value, negated
	and.w #$0030					; palette bits
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a
	sta.w printa					; printa palette
	lda.b $01,s
	and.w #$0040					; priority bit
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a
	tsb.w printa					; printa priority
	pla
	and.w #$0003					; font number: printfontset from the table at printfontset+2*n
	sta.w printfont					; printfont
	pha
	asl a
	tax
	lda.w printfontset,x
	sta.w printfontset
	pla								; printm = (map - 1) * $800
	dec a
	xba
	and.w #$FF00
	asl a
	asl a
	asl a
	sta.b printm					; printm offset
	iny
	lda.b [a1],y					; x
	and.w #$001F
	sta.w printx					; printx
	iny
	lda.b [a1],y					; y
	and.w #$001F
	sta.w printy					; printy
	iny
	jmp.w .top						; continue
.done:								; restore registers
	stx.b xsave						; keep X
	ldx.w #$000A
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	plx
	rtl
