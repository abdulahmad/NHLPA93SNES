StartSong6:							;Start the title screen music unless it is already playing
	lda.w cursong					; current song
	cmp.w #6						; already playing
	beq .rtl
	lda.w sndbank					; sound bank loaded
	cmp.w #2						; bank 2 is the game bank
	beq .cmd
	jsl.l SPCBootUpload				; else upload it
.cmd:
	sep #$20						; APUIO0 = 3: play song 6
	lda.b #$03
	sta.w APUIO0
	rep #$30						; 16-bit registers
	lda.w #6
	sta.w cursong					; remember the song
.rtl:								; return
	rtl
