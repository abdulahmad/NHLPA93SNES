StartSngEOP:						;Start song 7 unless it is already playing. Unused
	lda.w cursong					; current song
	cmp.w #CurSngEOP				; already playing
	beq .rtl
	lda.w sndbank					; sound bank loaded
	cmp.w #SoundBankBoot			; bank 2 is the boot set
	beq .cmd
	jsl.l SPCBootUpload				; else upload it
.cmd:								; APUIO0 = SngEOP: play it
	sep #$20						; 8-bit A
	lda.b #SngEOP
	sta.w APUIO0					; send the command
	rep #$30						; 16-bit registers
	lda.w #CurSngEOP
	sta.w cursong					; remember the song
.rtl:								; return
	rtl
