StartSngEOG:						;Start song 8 unless it is already playing. Unused
	lda.w cursong					; current song
	cmp.w #SngEOG					; already playing
	beq .rtl
	lda.w sndbank					; sound bank loaded
	cmp.w #2						; bank 2 is the game bank
	beq .cmd
	jsl.l SPCBootUpload				; else upload it
.cmd:								; APUIO0 = 9: play song 8
	sep #$20						; 8-bit A
	lda.b #$09
	sta.w APUIO0					; send the command
	rep #$30						; 16-bit registers
	lda.w #SngEOG
	sta.w cursong					; remember the song
.rtl:								; return
	rtl
