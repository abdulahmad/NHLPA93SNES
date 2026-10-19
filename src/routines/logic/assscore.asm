assscore:							;Assignment: celebrating a goal; the scorer pumps his arm
	lda.w Xvel,x					; Xvel, Yvel *= $C0/256
	sta.b mula						; X velocity
	lda.w #$00C0					; times $C0
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lda.b mulres+1					; divide by 256
	sta.w Xvel,x
	lda.w Yvel,x					; Y velocity
	sta.b mula
	lda.w #$00C0					; times $C0
	sta.b mulb
	jsl.l muls32					; signed 32-bit multiply
	lda.b mulres+1					; divide by 256
	sta.w Yvel,x
	txa								; the carrier drops the puck
	lsr a
	cmp.w puckc						; the carrier?
	bne .al
	lda.w #$FFFF					; drops the puck
	sta.w puckc
	lda.w #1800						; lockout 1800
	sta.w nopuck,x
.al:
	lda.w pfalock,x					; animation locked?
	bne .rtl
	lda.w pflags,x					; player flags
	bit.w #pfna						; new assignment: spot (+-90, Vpos)
	beq .nna
	and.w #~pfna&$FFFF
	sta.w pflags,x
	jsl.l .1
	stz.w temp2,x
	lda.w #$0008
	sta.w temp2b,x
	lda.w #90						; x target 90
	sta.w temp3,x
	lda.w Hpos						; scroll side
	bpl .0
	lda.w #-90						; left side: -90
	sta.w temp3,x
.0:
	lda.w Vpos						; y target is the scroll y
	sta.w temp4,x
.nna:
	lda.w #rtss						; avoidance routine
	sta.b a0
	lda.w #rtss>>16
	sta.b a0+2
	lda.w temp3,x					; target x
	sta.b d0
	lda.w temp4,x					; target y
	sta.b d1
	lda.w temp1,x					; temp1 runs out: celebrate (SPApump for the scorer)
	sec
	sbc.b d7						; minus the frame count
	sta.w temp1,x
	bpl .chkcon						; still counting
	sta.w pfalock,x					; lock the assignment
	lda.w #SPAcelebrate				; celebrate animation
	sta.b d1
	txa								; shot player?
	lsr a
	cmp.w shotplayer
	bne .nopump
	lda.w #SPApump					; pump animation
	sta.b d1
.nopump:
	jsl.l SetSPA					; start animation d1
.1:									;temp1 = random 120
	lda.w #120
	jsl.l randoma					; random number 0 to A-1
	sta.w temp1,x					; store it
.rtl:
	rtl
.chkcon:							;joystick controlled: stand, else skateto
	lda.w pflags,x					; player flags
	bit.w #pfjoycon					; joystick controlled?
	bne .rtl2						; yes: stand
	jml.l skateto					; else skate to the target
.rtl2:
	rtl
unusedFF86:							;unused, $FF fill to the end of the bank
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
