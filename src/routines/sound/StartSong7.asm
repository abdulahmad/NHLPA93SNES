StartSong7:							;Start song 7 unless it is already playing. Unused
	lda.w cursong					; current song
	cmp.w #7						; already playing
	beq .rtl
	lda.w sndbank					; sound bank loaded
	cmp.w #2						; bank 2 is the game bank
	beq .cmd
	jsl.l SPCBootUpload				; else upload it
.cmd:
	sep #$20
	lda.b #$02
	sta.w APUIO0					; send the command
	rep #$30
	lda.w #7
	sta.w cursong					; remember the song
.rtl:
	rtl
