updatepwrplay:						;Show the power play box: the time left and the team on the power play
	stz.b a2						; a2 = home, a3 = away
	lda.w #$0002
	sta.b a3
	lda.w tmap						; difference of the power play times
	sec
	sbc.w tmap+2
	sta.b d0						; d0 = home - away
	bne .diff						; equal: clear the box
	jmp.w updatepwrplay_clr
.diff:
	bpl .t0
	lda.w sflags					; negative: away team on the power play
	bit.w #sf2pwrtm
	bne .upp
	jsl.l updatepwrplay_clr			; clear the box when the team changes
	lda.w #sf2pwrtm					; team flag
	tsb.w sflags
	bra .upp
.t0:
	ldx.b a2						; home on the power play: swap
	ldy.b a3
	stx.b a3
	sty.b a2
	lda.w sflags					; flags
	bit.w #sf2pwrtm
	beq .upp
	jsl.l updatepwrplay_clr			; clear the box when the team changes
	lda.w #sf2pwrtm
	trb.w sflags					; clear the team flag
.upp:
	lda.w #sf2pwrplay				; sf2pwrplay; new: tmPwrPlays + 1
	tsb.w sflags
	bne .uppt
	ldx.b a3						; first time: count the power play
	inc.w tmPwrPlays,x				; new power play for the team
.uppt:
	jsl.l printz					; print the string that follows
	dw $0012						; printz inline string: length (counts itself), then control bytes / text
	db $BF,$01,$19,"   ",$16,$17,$18,$19,$BF,$01,$1A,"   "
	jsl.l GetLowestPen				; penalty time of the box
	jsl.l PushTime					; time as text
	jsl.l print						; print it
	ldx.b a3						; team of the power play
	lda.w tmdata,x					; team name (bank $83)
	sta.b a0
	lda.w #TeamList>>16
	sta.b a0+2
	lda.w #mesarea					; a3 = mesarea, length 2
	sta.b a3
	lda.w #mesarea>>16
	sta.b a3+2
	lda.w #$0002					; length 2
	sta.b [a3]
	jsl.l appendz					; append the name
	%StringCp(CC_Font1Pri,$01,$19)
	lda.b a0						; team name offset
	ldy.w #$0004					; short name offset
	clc
	adc.b [a0],y
	sta.b a0						; add the entry offset
	adc.b [a0]
	sta.b a0
	sta.b a1						; string pointer
	lda.b a0+2
	sta.b a1+2
	jsl.l appstring					; append the string
	lda.b a3
	sta.b a1
	lda.b a3+2
	sta.b a1+2
	jmp.w print						; print it
