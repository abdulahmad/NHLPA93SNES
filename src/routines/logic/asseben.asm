asseben:							;Assignment: player X comes onto the ice from the bench
	lda.w pfalock,x					; locked
	bne .rtl						; yes: leave
	lda.w pflags,x					; flags
	bit.w #pfna
	beq .nna						; not new
	and.w #~pfna&$FFFF				; clear the new flag
	sta.w pflags,x
	stz.w Xvel,x					; no speed
	stz.w Yvel,x					; no speed
	txa								; player number
	lsr a
	sec								; minus 6
	sbc.w #$0006
	bmi .0							; home
	inc a							; away: +1
.0:									; scale factor 14
	sta.b mulb
	lda.w #$000E					; 14
	sta.b mula
	jsl.l muls16					; signed multiply
	sta.w Ypos,x					; y
	lda.w #$FF78					; x = -$88
	sta.w Xpos,x
	lda.w #$0002					; facing
	sta.w facedir,x
	sta.w pfalock,x					; lock
	lda.w #SPAwallright				; animation
	sta.b d1
	jml.l SetSPA					; start it
.rtl:								; return
	rtl
.nna:
	lda.w #$0004					; facing
	sta.w facedir,x
	lda.w pflags,x					; flags
	and.w #$6FFF
	sta.w pflags,x
	stz.w pfnc,x					; collision on
	stz.w SPA,x						; no animation
	lda.w #$1000					; speed
	sta.w Xvel,x
	jml.l assexit					; assignment over
