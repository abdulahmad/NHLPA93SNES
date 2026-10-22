checkfornewpen:						;Look for a new penalty call. Stops play at once when the penalty has no
									;minutes or the guilty team has
									;the puck; otherwise it is a delayed call
	lda.w sfhormode					; not in horizontal mode
	beq .go
	jmp.w .rtl
.go:								; penalty buffer
	lda.w #PenBuf					; penalty buffer
	sta.b a0
.next:								; next PenBuf entry (0 = end)
	lda.b (a0)						; next buffered penalty
	inc.b a0
	inc.b a0
	tay								; zero: end of the buffer
	bne .notcalled
	jmp.w .rtl
.notcalled:							; penalty already stopped play?
	lda.w gmode						; already called: mark it
	bit.w #gmpen					; penalty already stopped play?
	bne .iscalled
	dec.b a0						; type byte
	dec.b a0
	lda.b (a0)
	inc.b a0
	inc.b a0
	and.w #$00FF					; penalty type
	sta.b d0
	tay
	lda.w #Penaltylist				; a1 = Penaltylist entry; minutes?
	sta.b a1
	lda.w #Penaltylist>>16
	sta.b a1+2
	lda.b [a1],y					; offset of the entry
	clc
	adc.b a1
	sta.b a1
	lda.b [a1]						; minutes
	and.w #$00FF
	beq .callit						; none: call it now
	lda.w puckc						; no carrier, or the guilty team has the puck... else delayed call
	bmi .dc
	sec
	sbc.w #$0006
	sta.b d0
	dec.b a0
	lda.b (a0)
	inc.b a0
	and.w #$00FF
	bit.w #$0080
	beq .pl
	ora.w #$FF00
.pl:								; player offset
	sec
	sbc.w #$0006
	eor.b d0
	bmi .dc
.callit:							; stop the clock and blow the whistle
	jsl.l Stop4Pen					; stop play
.iscalled:							;mark it called (bit 7 of the player byte)
	dec.b a0						; player byte
	lda.b (a0)
	tay
	ora.w #$0080					; set the called bit
	sta.b (a0)
	inc.b a0
	tya
	bit.w #$0080					; already called before?
	bne .next
	dec.b a0
	dec.b a0
	lda.b (a0)						; penalty type
	inc.b a0
	inc.b a0
	and.w #$00FF
	sta.b d0
	tay
	lda.w #Penaltylist				; delay byte (+1) * 32
	sta.b a1
	lda.w #Penaltylist>>16
	sta.b a1+2
	lda.b [a1],y					; offset of the entry
	clc
	adc.b a1
	sta.b a1
	ldy.w #$0001
	lda.b [a1],y					; delay byte
	and.w #$00FF
	asl a							; times 32
	asl a
	asl a
	asl a
	asl a
	sta.b d1						; d1 = delay * 32
	sec
	sbc.w Pencntdwn					; compare with the countdown
	beq .nx
	bmi .neg
	bvc .longer
.nx:								; far branch to .next
	jmp.w .next
.neg:								; signed compare: overflow flag corrects the sign
	bvc .nx
.longer:							;Pencntdwn = delay*32 if longer
	lda.b d1						; longer: take it
	sta.w Pencntdwn					; countdown
	jmp.w .next
.rtl:								; return
	rtl
.dc:								;delayed call: PenDelay ref once
	lda.w #gmpendel					; first delayed call: SetPA PenDelay
	tsb.w gmode
	beq .dc2
	jmp.w .next
.dc2:								; set the penalty delay
	lda.w #PenDelay
	sta.b d0
	jsl.l SetPA						; PenDelay announcement
	jmp.w .next
