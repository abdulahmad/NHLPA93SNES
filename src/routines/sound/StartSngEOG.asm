StartSngEOG:						;Start song 8 unless it is already playing. Unused
	lda.w cursong					; current song
	cmp.w #CurSngEOG				; already playing
	beq .rtl
	lda.w sndbank					; sound bank loaded
	cmp.w #SoundBankBoot			; bank 2 is the boot set
	beq .cmd
	jsl.l SPCBootUpload				; else upload it
.cmd:								; APUIO0 = SngEOG: play it
	sep #$20						; 8-bit A
	lda.b #SngEOG
	sta.w APUIO0					; send the command
	rep #$30						; 16-bit registers
	lda.w #CurSngEOG
	sta.w cursong					; remember the song
.rtl:								; return
	rtl
