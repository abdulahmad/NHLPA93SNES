holdcheck:							;a2 holds or hooks X: both slow down, and a holding or hooking penalty may
									;be called
	lda.w pfalock,x
	ora.w pf2fight,x				; already held, or fighting
	beq .nopf2fight
	jmp.w .rtl
.nopf2fight:
	lda.w position,x				; no hold on a goalie
	bne .position
	jmp.w .rtl
.position:
	ldy.b a2
	lda.w Xpos,x
	sec
	sbc.w Xpos,y
	sta.b d0
	lda.w Ypos,x
	sec
	sbc.w Ypos,y
	sta.b d1
	jsl.l vtoa						; direction from a2 to X
	ldy.b a2
	lda.b d0
	sec
	sbc.w facedir,y
	inc a
	and.w #$0007
	cmp.w #$0003
	bcc .close						; X must be within 1 direction of where a2 faces
	jmp.w .rtl
.close:
	lda.w puckc
	asl a
	cmp.b a3
	bne .nopc
	lda.w #$0008
	trb.w sflags					; X has the puck
.nopc:
	ldy.b a2
	lda.w Xvel,x
	clc
	adc.w Xvel,y
	pha
	asl a
	pla
	ror a
	sta.w Xvel,x
	sta.w Xvel,y
	lda.w Yvel,x
	clc
	adc.w Yvel,y
	pha
	asl a
	pla
	ror a
	sta.w Yvel,x
	sta.w Yvel,y
	lda.w #SPAflail
	sta.b d1
	sta.w pfalock,x
	jsl.l SetSPA
	ldx.b a2
	ldy.b a3
	stx.b a3
	sty.b a2
	lda.w #SPAHold2
	sta.b d1
	sta.w pfalock,x
	lda.w SPA,x
	cmp.w #SPAHold
	beq .h2
	lda.w #SPAhook2					; holding anim after SPAhook
	sta.b d1
.h2:
	jsl.l SetSPA
	jsl.l checkagr
	lda.b d0
	cmp.w #$0007
	bcs .ex
	lda.w #$0024					; holding penalty
	sta.b d0
	lda.w SPA,x
	cmp.w #SPAHold2
	beq .pen
	lda.w #$001E					; hooking penalty
	sta.b d0
.pen:
	jsl.l AddPenalty
.ex:
	ldx.b a2
	ldy.b a3
	stx.b a3
	sty.b a2
	lda.w #$FFFF
	sta.b collflag
.rtl:
	rtl
