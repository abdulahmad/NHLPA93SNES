DoHiLights:							;Playoffs: play the highlight of each game of the round that has one
	lda.w OptPlayMode
	beq .rtl
	jsl.l GetShifter
	lda.b d1
	asl a
	sta.b a0
.top:
	ldy.b a0
	lda.w gsflags,y
	bit.w #gsfso
	bne .next
	bit.w #gsfhl
	beq .next
	and.w #~gsfhl&$FFFF
	sta.w gsflags,y
	jsl.l SaveRegsStartHL2
.next:
	dec.b a0
	dec.b a0
	dec.b d1
	bpl .top
.rtl:
	rtl
