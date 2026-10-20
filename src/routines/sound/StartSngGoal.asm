StartSngGoal:						;Start the home goal music unless it is already playing
	lda.w cursong
	cmp.w #CurSngGoal				; already playing
	beq .rtl
	lda.w sndbank					; sound bank loaded
	cmp.w #SoundBankGame			; bank 1 is the in-game set
	beq .cmd
	jsl.l sndqreset					; reset the sound queue
	jsl.l SPCGameUpload				; upload the game sound
.cmd:								; music cue 4
	lda.w #SngGoal					; music cue number
	jsl.l MusicCue					; driver command A (music cue)
	lda.w #CurSngGoal
	sta.w cursong					; remember the song
	lda.w #SngGoalLen				; time until the cue ends
	sta.w cuetimer					; set the cue timer
.rtl:								; return
	rtl
