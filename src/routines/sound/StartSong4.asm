StartSong4:							;Start music cue 4 unless it is already playing. Unused
	lda.w cursong
	cmp.w #$0004					; already playing
	beq .rtl
	lda.w sndbank					; sound bank loaded
	cmp.w #$0001					; bank 1 is the game bank
	beq .cmd
	jsl.l sndqreset					; reset the sound queue
	jsl.l SPCGameUpload				; upload the game sound
.cmd:
	lda.w #$0007					; music cue number
	jsl.l MusicCue					; driver command A (music cue)
	lda.w #$0004
	sta.w cursong					; remember the song
	lda.w #$022E					; time until the cue ends
	sta.w cuetimer					; set the cue timer
.rtl:
	rtl
