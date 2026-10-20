StartSngPO:							;Start the playoff screen music unless it is already playing
	lda.w cursong					; current song
	cmp.w #CurSngPO					; already playing
	beq .rtl
	lda.w sndbank					; sound bank loaded
	cmp.w #SoundBankBoot			; bank 2 is the boot set
	beq .cmd
	jsl.l SPCBootUpload				; else upload it
.cmd:								; APUIO0 = SngPO: play it
	sep #$20						; 8-bit A
	lda.b #SngPO
	sta.w APUIO0					; send the command
	rep #$30						; 16-bit registers
	lda.w #CurSngPO
	sta.w cursong					; remember the song
.rtl:								; return
	rtl
