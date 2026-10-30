lineinput:							;Pad input while the line change box is open: choose a line, or skate
	lda.b d1						; keep the presses
	pha
;a2 = own team struct (0 or 2)
	stz.b a2						; team 0
	lda.w pfteam,x					; a2 = the team of player X
	beq .0							; team 0
	inc.b a2						; team 1: a2 = 2
	inc.b a2
.0:									; flag to start line change mode
	ldy.b a2						; team offset
	lda.w tmflags,y					; tmflags bit 0: start line change mode
	bit.w #tmflcc					; mode start requested
	beq .1
	and.w #~tmflcc&$FFFF			; clear the request
	sta.w tmflags,y
	jsl.l lcfound2					; close the box
	jsl.l SetLCmode2				; reopen it
.1:									; new presses
	pla								; presses back
	sta.b d1
	stz.b d2
	bit.w #abut						; Y: choice 0
	beq .b							; not pressed
	jml.l lcfound					; d2 = choice
.b:									; B pressed: choice 1
	inc.b d2
	bit.w #bbut						; B: choice 1
	beq .a							; not pressed
	jml.l lcfound					; d2 = choice
.a:									; choice 2
	inc.b d2						; choice 2
	bit.w #cbut						; A (cbut): choice 2
	beq .dpad						; not pressed
	jml.l lcfound					; d2 = choice
.dpad:								; joystick controlled, not locked?
	lda.w pflags,x					; joystick controlled, not locked or fighting: skate
	bit.w #pfjoycon					; joystick controlled
	beq .x
	lda.w pfalock,x					; locked
	bne .x
	lda.w pf2fight,x				; fighting
	bne .x
	jml.l doplayeracc				; skate
.x:									; return
	rtl
