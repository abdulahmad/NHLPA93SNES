assfaceoff:							;Assignment: players wait until the face off is over.
									;Also starts the music cues
	lda.w pfalock,x					; locked
	bne .rts
	lda.w sflags					; flags
	bit.w #sf2faceoff				; faceoff over: exit
	beq assexit
	lda.w goalcue					; home goal music cue
	beq .per						; no cue
	stz.w goalcue					; clear it
	lda.w #$0001					; hold and clear the sound queue
	sta.b sndlock
	stz.b sndqin					; queue in
	stz.b sndqout					; queue out
	jsl.l StartSong1				; home goal music cue
.per:
	lda.w percue					; period start music cue
	beq .mid						; no cue
	stz.w percue					; clear it
	lda.w #$0001
	sta.b sndlock
	stz.b sndqin
	stz.b sndqout
	jsl.l StartSong2				; period start music cue
.mid:
	lda.w cuetimer					; no cue playing, clock >= 60 and past midpercue: mid-period cue
	bne .rts						; a cue is playing
	lda.w gameclock					; game clock
	cmp.w #$003C					; under 60 seconds
	bcc .rts
	cmp.w midpercue					; past the mid-period mark
	bcs .rts
	stz.w midpercue					; used once
	jsl.l StartSong5				; mid-period music cue
.rts:								; return
	rtl
