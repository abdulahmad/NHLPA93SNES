DecompressBytecode:					;Unpack a compressed stream to unpackbuf. Each control byte picks a
									;literal copy, a run of zeros or of one byte,
		;   or a copy from earlier output
	stz.b tmp1+1					; output pointer = $7F0000
	lda.w #unpackbuf>>16			; output bank
	sta.b tmp1+3
.next:								; next command byte of the stream
	lda.b [tmp0]					; next command byte
	inc.b tmp0
	bit.w #$00E0					; top three bits zero: literal copy
	bne .clear
	and.w #$001F					; literal count - 1
	tax
.litloop:							; copy the literal bytes
	lda.b [tmp0]					; copy one literal byte
	inc.b tmp0
	sta.b [tmp1+1]
	inc.b tmp1+1
	dex
	bpl .litloop
	bra .next						; next command
.clear:								; command class
	tay
	and.w #$00F0					; command class in bits 4-7
	cmp.w #$0020					; $2x: run of zeros
	bne .fillop
	tya
	and.w #$000F
	tax								; run length - 1
	lda.w #$0000					; fill with zero
.clrloop:							; zero-fill loop
	sta.b [tmp1+1]
	inc.b tmp1+1
	dex
	bpl .clrloop
	bra .next						; next command
.fillop:							; $3x: write the run of one byte
	cmp.w #$0030					; $3x: run of one byte
	bne .backshort
	tya
	and.w #$000F
	tax								; run length - 1
	inx								; plus 2
	inx
	lda.b [tmp0]					; the byte to repeat
	inc.b tmp0
.fillloop:							; fill loop
	sta.b [tmp1+1]
	inc.b tmp1+1
	dex
	bpl .fillloop
	bra .next						; next command
.backshort:							;$40-$7F: distance bits 3-5 + 1, length bits 0-2 + 2
	and.w #$00C0					; $40-$7F: short copy going up
	cmp.w #$0040
	bne .backmed
	tya
	lsr a
	lsr a
	lsr a
	and.w #$0007					; distance from bits 3-5
	inc a
	sta.b tmp2+2
	tya
	and.w #$0007
	inc a							; length from bits 0-2, plus 2
	inc a
	tay
.backrun:							;copy Y bytes from output - distance, going up
	lda.b tmp1+1					; source = output position - distance
	sec
	sbc.b tmp2+2
	tax
.backloop:							; copy bytes from earlier output, going up
	lda.l unpackbuf,x				; copy a byte from earlier output
	inx
	sta.b [tmp1+1]
	inc.b tmp1+1
	dey
	bne .backloop
	bra .next						; next command
.backmed:							;$8x: length n+3, distance = next byte
	tya
	and.w #$00F0					; $8x: medium copy
	cmp.w #$0080
	bne .backlong
	tya
	and.w #$000F
	inc a
	inc a
	inc a
	tay								; length = n + 3
	lda.b [tmp0]
	inc.b tmp0
	and.w #$00FF
	sta.b tmp2+2					; distance = next byte
	bra .backrun
.backlong:							;$9x: distance 7 bits, length 5 bits
	cmp.w #$0090
	bne .backext1
	lda.b [tmp0]
	inc.b tmp0
	and.w #$007F					; distance 7 bits
	inc a
	sta.b tmp2+2
	tya
	xba
	asl a
	xba
	and.w #$001F					; length 5 bits
	inc a
	inc a
	inc a
	tay
	bra .backrun
.backext1:							;$Ax: distance 6 bits, length 6 bits
	cmp.w #$00A0
	bne .backext2
	lda.b [tmp0]
	inc.b tmp0
	and.w #$003F
	inc a
	sta.b tmp2+2
	tya
	xba
	asl a
	asl a
	xba
	and.w #$003F					; length 6 bits
	inc a
	inc a
	inc a
	tay
	bra .backrun
.backext2:							;$Bx: distance 5 bits, length 7 bits
	cmp.w #$00B0
	bne .revshort
	lda.b [tmp0]
	inc.b tmp0
	and.w #$001F					; distance 5 bits
	inc a
	sta.b tmp2+2
	tya
	xba
	asl a
	asl a
	asl a
	xba
	and.w #$007F					; length 7 bits
	inc a
	inc a
	inc a
	tay
	jmp.w .backrun
.revshort:							;$C0-$DF: going down
	and.w #$00E0					; $C0-$DF: short copy going down
	cmp.w #$00C0
	bne .revmed
	tya
	lsr a
	lsr a
	and.w #$0007
	inc a
	sta.b tmp2+2
	tya
	and.w #$0003					; length from bits 0-1, plus 2
	inc a
	inc a
	tay
.revrun:							;copy Y bytes going down from output - distance
	lda.b tmp1+1					; source = output position - distance
	sec
	sbc.b tmp2+2
	tax
.revloop:							; copy bytes from earlier output, going down
	lda.l unpackbuf,x				; copy a byte from earlier output
	dex								; going down
	sta.b [tmp1+1]
	inc.b tmp1+1
	dey
	bne .revloop
	jmp.w .next						; next command
.revmed:							;$Ex: length n+3, distance = next byte (0 = end)
	tya
	and.w #$00F0
	cmp.w #$00E0
	bne .revlong
	tya
	and.w #$000F
	inc a
	inc a
	inc a
	tay
	lda.b [tmp0]
	inc.b tmp0
	and.w #$00FF
	beq .end						; distance 0: end of stream
	sta.b tmp2+2
	bra .revrun
.revlong:							;$Fx: going down, distance 7 bits, length 5 bits
	lda.b [tmp0]
	inc.b tmp0
	and.w #$007F
	inc a
	sta.b tmp2+2
	tya
	xba
	asl a
	xba
	and.w #$001F					; length 5 bits
	inc a
	inc a
	inc a
	tay
	bra .revrun
.end:								; end of the stream: return
	rtl								; done
