pplpen:								;Print one penalty box line: player number and time left
	lda.w printy					; print y
	cmp.w #$000B					; row 11 or beyond
	bcs USBoard_rtl					; no room
	lda.b a2						; team
	beq .noa2
	lda.w #$0034					; away team offset
.noa2:								; index the penalty state
	adc.b d0
	tay								; index
	lda.w tmpdst,y					; state
	and.w #$07FF					; time bits
	sta.b d2						; time
	lda.w #TeamList>>16
	sta.b a1+2
	ldy.b a2
	lda.w tmdata,y					; team data
	sta.b a1
	ldy.w #Playerdata				; player data offset
	adc.b [a1],y					; start of the players
	sta.b a1
	lsr.b d0						; player index
.find:
	lda.b [a1]						; record length
	clc
	adc.b a1
	adc.w #$0008					; plus 8
	sta.b a1
	dec.b d0						; next record
	bpl .find
	lda.b a1						; back to the one found
	sec
	sbc.w #$0008
	sta.b a1
	lda.b [a1]						; player number
	and.w #$00FF
	sta.b d0
	lda.w printx					; print x
	pha
	lda.w #mesarea+2				; text buffer
	sta.b a1
	lda.w #mesarea>>16
	sta.b a1+2
	jsl.l ConvertByteToDigits		; number to digits
	lda.w #mesarea					; print buffer
	sta.b a1
	lda.w #mesarea>>16
	sta.b a1+2
	lda.w #$0004					; length 4
	sta.b [a1]
	jsl.l print						; print it
	lda.b d2						; time
	sta.b d0
	jsl.l PushTime					; time to text
	inc.w printx					; next column
	jsl.l print						; print it
	pla								; restore print x
	sta.w printx
	inc.w printy					; next row
	rtl
