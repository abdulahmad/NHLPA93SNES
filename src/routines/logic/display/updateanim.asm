updateanim:							;Step object X's sprite animation, looping or ending it
	lda.w SPA,x						; no animation: clear pfalock, pf2aip
	bne .ia							; no animation
	stz.w pf2aip,x
	stz.w pfalock,x
	rtl
.ia:								; a0 = SPAlist + SPA; d1 = attribute
	clc								; a0 = SPAlist + SPA; d1 = attributes
	adc.w #SPAlist&$FFFF			; SPAlist base
	sta.b a0
	lda.w #SPAlist>>16
	sta.b a0+2
	ldy.w #$0010					; attribute offset
	lda.b [a0],y					; attributes
	sta.b d1
	lda.w facedir,x					; facing
	sta.b d0
	lda.w sfhormode					; horizontal rink: players turn 90 degrees
	beq .nhor
	cpx.w #$0018					; players only
	bcs .nhor
	lda.b d0
	dec a
	dec a
	and.w #$0007					; turn 90 degrees
	sta.b d0
.nhor:								; x flip: mirror the direction
	lda.w attribute,x				; x flip: mirror the direction
	bit.w #attrxflip
	beq .nox
	lda.b d0						; mirror
	eor.w #$FFFF					; negate
	inc a
	and.w #$0007					; 0-7
	sta.b d0
.nox:								; a0 += the direction table entry
	lda.b d0						; a0 += direction table entry; d2 = new frame
	asl a
	tay
	lda.b [a0],y					; direction entry
	adc.b a0						; plus the list base
	sta.b a0
	ldy.w SPAnum,x					; frame position
	sty.b d0
	lda.b [a0],y					; frame entry
	sta.b d2						; d2 = new frame
	lda.w SPAcnt,x					; SPAcnt negative: hold the frame
	bmi .1							; hold the frame
	sec
	sbc.b d7						; minus the frame count
	sta.w SPAcnt,x
	bpl .cframe						; still counting
	lda.w SPAnum,x					; next frame (4 bytes); a negative frame ends the list
	clc
	adc.w #$0004					; next frame, 4 bytes
	sta.w SPAnum,x
	iny
	iny
	iny
	iny								; new position
	sty.b d0
	dey
	dey
	lda.b [a0],y					; frame entry
	bpl .1							; negative: end of the list
	stz.b d0						; end: restart, clear pfalock/pf2aip; d1 bit 0 = looper, else SPA = 0
	stz.w SPAnum,x
	stz.w pf2aip,x
	stz.w pfalock,x
	lda.b d1						; looper?
	lsr a
	bcs .1
	stz.w SPA,x						; not a looper: SPA = 0
.1:									;SPAcnt = |delay|
	ldy.b d0						; frame delay
	iny
	iny
	lda.b [a0],y
	bit.w #$8000					; negative?
	beq .0
	eor.w #$FFFF					; negate
	inc a
.0:									; SPAcnt = the delay; frame = the new frame
	sta.w SPAcnt,x					; SPAcnt = delay
.cframe:							;frame = new frame
	lda.b d2						; frame
	sta.w frame,x					; store it
	rtl
