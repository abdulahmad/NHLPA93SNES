p_music_vblank:						;Vblank sound handler: every other frame, send the next queued sound
									;command to the sound driver.
		;   Waits a little after a sample upload
	lda.w sndsettle					; wait after the sample upload
	bne .settle
	sep #$30						; 8-bit registers
	lda.b sndlock					; queue locked
	bne .done						; yes: skip
	lda.b vcount					; every other frame
	lsr a
	bcc .done
	ldx.b sndqout					; queue out
	cpx.b sndqin					; equals queue in
	beq .done						; queue empty
	lda.b sndqueue,x				; next command
	sta.w APUIO0					; send it
	inc.b sndptr					; sndptr (low byte) doubles as the command counter here
	lda.b sndptr
	sta.w APUIO1					; counter to port 1
	txa								; queue out advances
	inc a
	inc a
	and.b #$0F
	sta.b sndqout					; wrap at 16
.done:
	rep #$30						; 16-bit registers
	rtl
.settle:
	dec.w sndsettle					; count down
	rtl
