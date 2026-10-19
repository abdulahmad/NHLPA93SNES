PrintScoutRatings:					;Print the scouting ratings of team [a0], marking where it has the edge
									;over [a2]
	ldy.w #$0004					; ratings of the team
	lda.b [a0],y					; word
	xba								; swap bytes
	sta.b d5+2						; d5 = ratings (high word)
	iny
	iny
	lda.b [a0],y					; next word
	xba
	sta.b d5
	lda.w #$0007					; 8 ratings
	sta.b d6
.rating:
	ldy.w #$0004					; 4 bits per rating
.shift:
	asl.b d5						; rotate d5 left
	rol.b d5+2
	lda.b d5
	adc.w #$0000
	sta.b d5
	dey
	bne .shift
	lda.b d5						; rating
	and.w #$000F					; 4 bits
	sta.b d0
	jsl.l .printrating				; print it
	lda.b d6						; rating number
	cmp.w #$0001					; after the 7th
	bne .next
	jsl.l .advantages				; print the advantages
.next:
	dec.b d6						; next rating
	bpl .rating
	rtl
.advantages:
	lda.b [a0]						; ratings of team a0
	xba
	and.w #$000F
	sta.b d0						; first rating
	lda.b [a2]						; team a2
	xba
	lsr a
	lsr a
	lsr a
	lsr a
	and.w #$000F
	clc								; sum of both
	adc.b d0
	sta.b d0
	jsl.l .printrating
	lda.w printx					; x
	cmp.w #$0010					; beyond the column
	bcc .nexty
	ldy.w #$0002					; next word
	lda.b [a0],y
	lsr a							; four bits
	lsr a
	lsr a
	lsr a
	and.w #$000F
	sta.b d0
	lda.b [a2],y					; team a2
	and.w #$000F
	clc								; sum
	adc.b d0
	sta.b d0
.printrating:
	lda.w #$0002					; width 2
	sta.b d1
	jsl.l PushNumberWidth			; number to text
	lda.w printx					; keep x
	pha
	jsl.l print						; print it
	pla								; restore x
	sta.w printx
.nexty:
	inc.w printy					; next row
	rtl
