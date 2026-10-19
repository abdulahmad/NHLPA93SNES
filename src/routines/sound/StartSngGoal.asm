StartSngGoal:						;Start the home goal music unless it is already playing
	lda.w cursong
	cmp.w #SngGoal					; already playing
	beq .rtl
	lda.w sndbank					; sound bank loaded
	cmp.w #$0001					; bank 1 is the game bank
	beq .cmd
	jsl.l sndqreset					; reset the sound queue
	jsl.l SPCGameUpload				; upload the game sound
.cmd:								; music cue 4
	lda.w #$0004					; music cue number
	jsl.l MusicCue					; driver command A (music cue)
	lda.w #SngGoal
	sta.w cursong					; remember the song
	lda.w #$0240					; time until the cue ends
	sta.w cuetimer					; set the cue timer
.rtl:								; return
	rtl
