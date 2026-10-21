print:								;Print string [a1] into the text map at printx / printy. The string starts
									;with its length word and may hold
		;   control codes for position and color
	lda.b [a1]						; string length
	cmp.w #$0100
.hang:								;string longer than 255: hang
	bcs .hang
	phx								; keep X
	ldy.w #$0002					; Y = 2: skip the length word
.pos:								; X = (printy*32+printx)*2 + printmap
	lda.w printy					; X = (printy*32+printx)*2 + printm
	asl a
	asl a
	asl a
	asl a
	asl a
	adc.w printx
	asl a							; plus the character offset
	adc.b printm					; plus the map offset
	tax
.char:								; end of the string?
	tya								; end of the string?
	cmp.b [a1]
	bne .ctl
	jmp.w .done						; done
.ctl:								; bit 7: control code
	lda.b [a1],y					; character
	bit.w #$0080					; bit 7: control code
	bne .code
	and.w #$00FF					; character code
	cmp.w #$0040					; "@" = blank tile
	bne .font						; "@" is a blank tile
	jmp.w .blank
.font:								; index the font character
	phx
	asl a							; character index
	tax
	lda.l SmallFontMap,x			; char -> tile + font + printa
	adc.w smallfontchars			; plus the font tile base
	adc.w printfontset				; plus the font set
	ora.w printa					; plus the palette and priority
	plx
.put:								; store the tile unless it is already there
	cmp.l textmap,x					; already there?
	beq .nextc
	sta.l textmap,x					; store the tile
	txa
	lsr a
	cmp.b textdirtylo				; textdirtylo/hi
	bcs .hi
	sta.b textdirtylo
.hi:								; update the high end of the dirty range
	cmp.b textdirtyhi
	bcc .nextc						; new high
	sta.b textdirtyhi
.nextc:								; next column
	inc.w printx					; next column
	inx								; next text map position
	inx
	iny								; next character
	bra .char
.code:								;control code -n: palette/priority bits, font number, map; then x, y
	eor.w #$FFFF					; negate
	inc a
	pha								; $01,s = the control record value, negated
	and.w #$0030					; bits 4-5: palette (printa bits 10-12)
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a
	sta.w printa					; printa palette
	lda.b $01,s
	and.w #$0040					; bit 6: priority
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a
	tsb.w printa					; printa priority
	pla
	and.w #$0003					; bits 0-1: font, printfontset = font table entry
	sta.w printfont					; printfont
	pha
	asl a
	tax
	lda.w printfontset,x			; font set entry
	sta.w printfontset				; current font set
	pla
	dec a							; map (font-1) * $800 bytes
	xba
	and.w #$FF00
	asl a
	asl a
	asl a
	sta.b printm					; printm offset
	iny
	lda.b [a1],y					; x
	and.w #$007F
	sta.w printx					; printx
	iny
	lda.b [a1],y					; y
	and.w #$007F
	sta.w printy					; printy
	iny
	jmp.w .pos						; continue
.done:								; a1 = end of the string
	clc								; string length
	adc.b a1						; plus the string start
	sta.b a1						; a1 = end of the string
	plx								; restore X
	rtl
.blank:								; blank tile plus the font set
	lda.w blankchar					; blank tile
	clc
	adc.w printfontset				; plus the font set
	jmp.w .put
