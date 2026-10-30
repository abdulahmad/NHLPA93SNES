SPCGameUpload:						;Switch the SPC700 to the in-game set: wait for the sound queue to empty,
									;then upload the in-game sound program and samples (GameSoundUpload).
									;Afterwards SoundBankGame is loaded and no song plays
	phy								; save Y
	phx
	pha
.qwait:								; wait for the queue
	lda.b sndqin
	cmp.b sndqout
	bne .qwait
	lda.b Vcount					; frame counter
	clc
	adc.w #$0006					; plus 6 frames
.vblank:							; wait for the frame
	cmp.b Vcount					; wait for them
	bne .vblank
	lda.w #$0001					; 1 is both the lock flag and SoundBankGame, so one load sets both
	sta.b sndlock					; lock the sound queue while the set uploads
	sta.w sndbank					; SoundBankGame: the in-game set is loaded
	stz.w cursong					; no song
	lda.w #GameSoundUpload&$FFFF	; sndptr = GameSoundUpload
	sta.b sndptr					; pointer to the upload
	lda.w #(GameSoundUpload>>8)&$FFFF
	sta.b sndptr+1
	jsl.l SPCUpload					; send it
	sep #$20						; 8-bit A
	lda.b #NMITIMEN_NMI|NMITIMEN_JOY	; NMI and joypad on
	sta.w NMITIMEN
	rep #$30						; 16-bit
	lda.w #$000A
	sta.w sndsettle					; settle for 10 frames
	pla								; restore the registers
	plx
	ply
	rtl
