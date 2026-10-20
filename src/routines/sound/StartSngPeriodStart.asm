StartSngPeriodStart:				;Start the period start music unless it is already playing
	lda.w cursong
	cmp.w #2						; already playing
	beq .rtl
	lda.w sndbank					; sound bank loaded
	cmp.w #$0001					; bank 1 is the game bank
	beq .cmd
	jsl.l sndqreset					; reset the sound queue
	jsl.l SPCGameUpload				; upload the game sound
.cmd:								; music cue 5
	lda.w #SngPeriodStart			; music cue number
	jsl.l MusicCue					; driver command A (music cue)
	lda.w #2
	sta.w cursong					; remember the song
	lda.w #$01CE					; time until the cue ends
	sta.w cuetimer					; set the cue timer
.rtl:								; return
	rtl
