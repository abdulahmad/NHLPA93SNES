StartSong1:							;Start the home goal music unless it is already playing
	lda.w cursong
	cmp.w #$0001					; already playing
	beq .rtl
	lda.w sndbank					; sound bank loaded
	cmp.w #$0001					; bank 1 is the game bank
	beq .cmd
	jsl.l sndqreset					; reset the sound queue
	jsl.l SPCGameUpload				; upload the game sound
.cmd:
	lda.w #$0004					; music cue number
	jsl.l MusicCue					; driver command A (music cue)
	lda.w #$0001
	sta.w cursong					; remember the song
	lda.w #$0240					; time until the cue ends
	sta.w cuetimer					; set the cue timer
.rtl:								; return
	rtl
