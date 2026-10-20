StartSngPP:							;Start music cue 4 unless it is already playing. Unused
	lda.w cursong
	cmp.w #CurSngPP					; already playing
	beq .rtl
	lda.w sndbank					; sound bank loaded
	cmp.w #SoundBankGame			; bank 1 is the in-game set
	beq .cmd
	jsl.l sndqreset					; reset the sound queue
	jsl.l SPCGameUpload				; upload the game sound
.cmd:								; music cue 7
	lda.w #SngPP					; music cue number
	jsl.l MusicCue					; driver command A (music cue)
	lda.w #CurSngPP
	sta.w cursong					; remember the song
	lda.w #SngPPLen					; time until the cue ends
	sta.w cuetimer					; set the cue timer
.rtl:								; return
	rtl
