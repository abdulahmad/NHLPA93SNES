StartSong9:							;Start the playoff screen music unless it is already playing
	lda.w cursong					; current song
	cmp.w #9						; already playing
	beq .rtl
	lda.w sndbank					; sound bank loaded
	cmp.w #2						; bank 2 is the game bank
	beq .cmd
	jsl.l SPCBootUpload				; else upload it
.cmd:								; APUIO0 = 1: play song 9
	sep #$20						; 8-bit A
	lda.b #$01
	sta.w APUIO0					; send the command
	rep #$30						; 16-bit registers
	lda.w #9
	sta.w cursong					; remember the song
.rtl:								; return
	rtl
