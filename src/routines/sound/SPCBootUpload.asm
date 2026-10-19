SPCBootUpload:						;Wait for the sound queue to empty, then upload the sound driver and its
									;boot samples
	phy								; save the registers
	phx
	pha
.dark:								;keep the screen dark unless fully on
	lda.b brightness				; brightness
	cmp.w #$000F					; full
	beq .qwait
	stz.b brightness				; else dark
.qwait:
	lda.b sndqin					; queue in
	cmp.b sndqout					; equals queue out
	bne .dark						; wait for the queue
	lda.b vcount					; frame counter
.vblank:
	cmp.b vcount					; wait for a new frame
	beq .vblank
	lda.w #$0001					; sndbank 2, no song
	sta.b sndlock					; lock the queue
	lda.w #$0002					; bank 2
	sta.w sndbank
	stz.w cursong					; no song
	lda.w #BootSoundUpload&$FFFF	; sndptr = BootSoundUpload
	sta.b sndptr
	lda.w #(BootSoundUpload>>8)&$FFFF
	sta.b sndptr+1
	jsl.l SPCUpload					; send it
	sep #$20						; 8-bit A
	lda.b #NMITIMEN_NMI|NMITIMEN_JOY	; NMI and auto joypad read back on
	sta.w NMITIMEN
	rep #$30						; 16-bit
	lda.b vcount
	inc a
	inc a
.frames:							;wait 2 frames
	cmp.b vcount
	bne .frames
	pla								; restore the registers
	plx
	ply
	rtl
