setlccords:							;printx / printy and the size of team a2's line change box
	stz.b d0						; d0 = 0
	lda.b a2
	bne .0							; team 1?
	inc.b d0						; team 0: d0 = 1
.0:
	jsl.l printz					; set font and position
	%StringCp(CC_Font1Pri,$13,$01)
	lda.w gmode						; gmdir flips it
	bit.w #gmdir					; direction flipped
	beq .noflip
	lda.b d0						; then flip d0
	eor.w #$0001
	sta.b d0
.noflip:
	lda.w #$0015					; printy += 21 * d0
	sta.b mula						; 21
	lda.b d0
	sta.b mulb						; d0
	jsl.l mulu16					; mulu, A = mula*mulb
	adc.w printy					; plus printy
	sta.w printy					; new y
	lda.w #$0002					; getlchoice 2: no third choice: 2 rows
	sta.b d0
	jsl.l getlchoice				; d0 = possible line, -1 = none
	lda.w #$0006					; 6 rows
	sta.b d1
	lda.b d0
	bpl .ex							; yes
	dec.b d1						; no: one row less
	inc.w printy					; y + 1
.ex:
	lda.w #$000C					; width 12
	sta.b d0
	rtl
