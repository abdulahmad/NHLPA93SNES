ProcessInputWithRepeat:				;Read pads 1 and 2 with key repeat: a held button repeats after a delay.
									;Used by the pause menu and menus
	jsl.l nullrtl85					; read the pads
	lda.b d3						; buttons held
	beq .rtl						; none: leave
	lda.b d2						; d2 = changed buttons
	bne .chg						; a change: restart the delay
	dec.w repeatdelay				; count down
	bpl .rtl						; not yet: leave
	lda.w #4						; repeat every 4 frames
	sta.w repeatdelay
	lda.b d3						; held buttons count as new presses
	sta.b d1
.rtl:								; return
	rtl
.chg:
	lda.w #15						; first repeat after 15 frames
	sta.w repeatdelay
	rtl
