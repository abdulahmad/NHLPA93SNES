adda43:								;Step a4 to the next replay frame, wrapping around the replay buffer
	lda.b a4
	clc								; next frame
	adc.w #replaysize
	sta.b a4
	bcc .nc							; carry into the bank
	inc.b a4+2
.nc:								; no wrap: carry into the bank
	cmp.w #ReplayBufferEnd&$FFFF	; past the end of the buffer: wrap
	bne .rtl						; not the end of the buffer
	lda.b a4+2
	cmp.w #ReplayBufferEnd>>16
	bne .rtl						; not the end
	lda.w #ReplayBufferStart&$FFFF	; wrap to the start
	sta.b a4
	lda.w #ReplayBufferStart>>16
	sta.b a4+2
.rtl:								; return
	rtl
