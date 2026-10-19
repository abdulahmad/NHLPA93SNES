holdcheck:							;a2 holds or hooks X: both slow down, and a holding or hooking penalty may
									;be called
	lda.w pfalock,x					; animation locked?
	ora.w pf2fight,x				; already held, or fighting
	beq .nopf2fight
	jmp.w .rtl
.nopf2fight:
	lda.w position,x				; no hold on a goalie
	bne .position
	jmp.w .rtl
.position:
	ldy.b a2						; a2 is the holder
	lda.w Xpos,x					; x of X
	sec
	sbc.w Xpos,y					; minus the holder's x
	sta.b d0
	lda.w Ypos,x					; y of X
	sec
	sbc.w Ypos,y					; minus the holder's y
	sta.b d1
	jsl.l vtoa						; direction from a2 to X
	ldy.b a2						; holder
	lda.b d0
	sec
	sbc.w facedir,y
	inc a							; direction difference
	and.w #$0007
	cmp.w #$0003
	bcc .close						; X must be within 1 direction of where a2 faces
	jmp.w .rtl
.close:
	lda.w puckc						; puck carrier
	asl a
	cmp.b a3						; X?
	bne .nopc
	lda.w #$0008					; puck not held anymore
	trb.w sflags					; X has the puck
.nopc:
	ldy.b a2
	lda.w Xvel,x					; x velocities
	clc
	adc.w Xvel,y					; added
	pha
	asl a
	pla
	ror a							; halved
	sta.w Xvel,x					; both take it
	sta.w Xvel,y
	lda.w Yvel,x					; y velocities
	clc
	adc.w Yvel,y					; added
	pha
	asl a
	pla
	ror a							; halved
	sta.w Yvel,x					; both take it
	sta.w Yvel,y
	lda.w #SPAflail					; X flails
	sta.b d1
	sta.w pfalock,x					; locked
	jsl.l SetSPA					; start animation d1
	ldx.b a2						; swap a2 and a3
	ldy.b a3
	stx.b a3
	sty.b a2
	lda.w #SPAHold2					; holder animation
	sta.b d1
	sta.w pfalock,x					; locked
	lda.w SPA,x						; current animation
	cmp.w #SPAHold					; hold animation?
	beq .h2
	lda.w #SPAhook2					; holding anim after SPAhook
	sta.b d1
.h2:
	jsl.l SetSPA					; start animation d1
	jsl.l checkagr					; aggression check
	lda.b d0
	cmp.w #$0007					; aggression under 7?
	bcs .ex
	lda.w #PenHolding				; holding penalty
	sta.b d0
	lda.w SPA,x						; holding or hooking by the animation
	cmp.w #SPAHold2					; hold?
	beq .pen
	lda.w #PenHooking				; hooking penalty
	sta.b d0
.pen:
	jsl.l AddPenalty				; call it
.ex:
	ldx.b a2						; swap back
	ldy.b a3
	stx.b a3
	sty.b a2
	lda.w #$FFFF					; set collflag
	sta.b collflag
.rtl:
	rtl
