updatereplay:						;Save this frame into the replay buffer
	lda.w gmode						; game mode
	bit.w #gmhl						; gmhl: no recording
	beq .rec
	jmp.w .rtl
.rec:								; record the objects (92 record)
	lda.w sflags					; state flags
	bit.w #sf2drec					; sf2drec: keep overwriting the same frame
	bne .frame
	lda.w recbpr			; next record
	clc								; step the pointer by one record
	adc.w #replaysize
	sta.w recbpr
	bcc .wrap
	inc.w recbpr+2
.wrap:								; wrap the buffer pointer if at the end
	cmp.w #replayend&$FFFF	; end of the buffer reached?
	bne .frame
	lda.w recbpr+2
	cmp.w #replayend>>16
	bne .frame
	lda.w #sfwrap					; wrapped: sfwrap, back to the start
	tsb.w sflags
	lda.w #replaystart&$FFFF
	sta.w recbpr
	lda.w #replaystart>>16
	sta.w recbpr+2
.frame:								; a0 = current record
	lda.w recbpr			; a0 = current record
	sta.b a0
	lda.w recbpr+2
	sta.b a0+2
	lda.w #$000F					; 16 sort objects
	sta.b d2
	ldx.w #$0000
	ldy.w #$0001					; y = 1: second byte of a word
.top:								;16 objects: x (12 bits) and y (12 bits), frame and flip bits
	lda.w #$0000					; clear the packed word
	sta.b [a0]
	sta.b [a0],y
	lda.w Xpos,x					; x position, low 12 bits
	and.w #$0FFF
	sta.b [a0]
	inc.b a0
	lda.w Ypos,x					; y position shifted into the upper bits
	asl a
	asl a
	asl a
	asl a
	ora.b [a0]
	sta.b [a0]
	inc.b a0
	inc.b a0
	lda.w frame,x					; frame, low 14 bits
	and.w #$3FFF
	sta.b [a0]
	lda.w attribute,x				; attribute flip bits
	and.w #$1800
	asl a
	asl a
	asl a
	ora.b [a0]
	sta.b [a0]
	inc.b a0
	inc.b a0
	inx								; next object
	inx
	dec.b d2
	bpl .top
	lda.w #$0005					; 6 skaters
	sta.b d2
	ldx.w #$0000
.pl:								;6 pairs: rostnum, positions
	lda.w rostnum,x					; roster numbers of the pair
	sta.b [a0]
	inc.b a0
	lda.w rostnum+2,x
	sta.b [a0]
	inc.b a0
	lda.w position,x				; position of the first, low nibble
	bpl .n0
	lda.w #$FFFF
.n0:								; low nibble of the byte
	and.w #$000F
	sta.b [a0]
	lda.w position+2,x				; position of the second, high nibble
	bpl .n1
	lda.w #$FFFF
.n1:								; scale the entry
	asl a
	asl a
	asl a
	asl a
	ora.b [a0]
	sta.b [a0]
	inc.b a0
	inx								; next pair
	inx
	inx
	inx
	dec.b d2
	bpl .pl
	lda.w Zpos+puckscnum				;puck and shadow height, lastsfx, d7, PadControlBits, Crowdframe,
									;glovecords, PBnum, Hpos, Vpos
	sta.b [a0]						; puck height
	inc.b a0
	lda.w Zpos+puckscnum+2			; puck shadow height
	sta.b [a0]
	inc.b a0
	lda.w lastsfx					; last sound effect
	sta.b [a0]
	inc.b a0
	stz.w lastsfx					; clear it after recording
	lda.b d7						; d7 counter
	sta.b [a0]
	inc.b a0
	lda.w PadControlBits			; pad control bits
	sta.b [a0]
	inc.b a0
	inc.b a0
	lda.b Crowdframe				; crowd animation frame
	sta.b [a0]
	inc.b a0
	inc.b a0
	lda.w glovecords				; glove coordinates
	sta.b [a0]
	inc.b a0
	inc.b a0
	lda.w PBnum						; player button number
	sta.b [a0]
	inc.b a0
	lda.w Hpos						; horizontal scroll
	sta.b [a0]
	inc.b a0
	inc.b a0
	lda.w Vpos						; vertical scroll
	sta.b [a0]
.rtl:								; return
	rtl
