StartSngLateGame:					;Start the third period music unless it is already playing
	lda.w cursong
	cmp.w #CurSngLateGame			; already playing
	beq .rtl
	lda.w sndbank					; sound bank loaded
	cmp.w #SoundBankGame			; bank 1 is the in-game set
	beq .cmd
	jsl.l sndqreset					; reset the sound queue
	jsl.l SPCGameUpload				; upload the game sound
.cmd:								; music cue 6
	lda.w #SngLateGame				; music cue number
	jsl.l MusicCue					; driver command A (music cue)
	lda.w #CurSngLateGame
	sta.w cursong					; remember the song
	lda.w #SngLateGameLen			; time until the cue ends
	sta.w cuetimer					; set the cue timer
.rtl:								; return
	rtl
