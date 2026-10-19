demoread:							;In the demo, Start pauses and any other button ends it
	lda.w cont1team					; a controller team: not a demo
	ora.w cont2team					; or controller 2
	bne .rtl						; a human plays: nothing to do
	jsl.l ReadJoy1					; read pad 1
	lda.b d1						; new presses
	bit.w #JOYSTART					; Start on pad 1: startpause1
	beq .any1						; not Start
	jml.l startpause1
.any1:
	lda.b d1
	bne .exit						; any other button ends the demo
	jsl.l ReadJoy2					; read pad 2
	lda.b d1						; new presses
	bit.w #JOYSTART					; Start on pad 2: startpause2
	beq .any2
	jml.l startpause2
.any2:
	lda.b d1						; any button ends the demo
	bne .exit						; none: continue
.rtl:
	rtl
.exit:								;end the demo: back to the title screen
	jsl.l sndqreset					; sound queue reset; on to the title screen
	jml.l Opening					; on to the title screen
