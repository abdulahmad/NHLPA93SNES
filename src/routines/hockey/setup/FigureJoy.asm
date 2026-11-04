FigureJoy:							;Set which team each controller plays
	stz.w cont1team					; no controller teams yet
	stz.w cont2team
	lda.w notdemo					; after the demo: no controller teams
	beq .rtl
	lda.w OptPlayMode				; play mode
	bne .po
	jmp.w .fjnpo
.po:								; d1 = games - 1; d2 = the po team
	jsl.l GetShifter				; d1 = games - 1
	lda.w #potree					; d2 = the po team
	sta.b a0						; po team table
	lda.w #$0000
	sta.b a0+2
	ldy.w potreeteam				; po team index
	lda.b [a0],y
	and.w #$00FF
	sta.b d2						; the po team
	lda.b d1
	asl a
	sta.b a1						; series index offset
	lda.w #$FFFF					; gamenum -1: po team not playing
	sta.w gamenum					; no game yet
	stz.b d0
.f0:								; search the series: first team
	lda.b d2						; search the series
	ldy.b a1
	cmp.w gst1,y					; first team of the series
	beq .it1
	cmp.w gst2,y					; second team of the series
	beq .it2
	dec.b a1
	dec.b a1
	dec.b d1
	bpl .f0
.rtl:								;po team not in the playoffs
	rtl
.it2:								; the po team is team 2: opponent
	lda.w #4						; po team is team 2
	sta.b d0
	lda.w gst1,y					; opponent
	sta.w Opt2team					; Opt2team
	bra .itx
.it1:								; the po team is team 1: opponent
	stz.b d0						; po team is team 1
	lda.w gst2,y					; opponent
	sta.w Opt2team					; Opt2team
.itx:								; add the joystick offset
	lda.b d0
	clc
	adc.w pojoy						; plus pojoy
	sta.b d0
	lda.b d1
	sta.w gamenum					; game number
	lda.w gst1,y
	sta.w HomeTeam					; home team
	lda.w gst2,y
	sta.w VisTeam					; visitor team
	asl.b d0						; times 4
	asl.b d0
	lda.w #.pojoylist				; .pojoylist entry (pojoy + 4 if the po team is team 2)
	sta.b a0
	lda.w #.pojoylist>>16
	sta.b a0+2
	ldy.b d0
	lda.b [a0],y					; cont1team
	sta.w cont1team
	iny
	iny
	lda.b [a0],y
	sta.w cont2team					; cont2team
	rtl
.fjnpo:								; regular season: pads from the table by OptNOP
	lda.w OptNOP				; regular season: .noplist by OptNOP
	asl a							; times 4
	asl a
	sta.b d0
	tay
	lda.w #.noplist
	sta.b a0
	lda.w #.noplist>>16
	sta.b a0+2
	lda.b [a0],y					; cont1team
	sta.w cont1team
	iny
	iny
	lda.b [a0],y
	sta.w cont2team					; cont2team
	rtl
.pojoylist:							;cont1team, cont2team by pojoy 0-3 (the po team as team 1), then as team 2
	dw 1,0
	dw 1,1
	dw 1,2
	dw 2,1
	dw 2,0
	dw 2,2
	dw 2,1
	dw 1,2
.noplist:							;cont1team, cont2team by OptNOP
	dw 0,0
	dw 1,0
	dw 2,0
	dw 1,1
	dw 1,2
