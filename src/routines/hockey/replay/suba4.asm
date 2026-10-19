suba4:								;Move the replay one frame back
	lda.b a4						; a4
	cmp.w #ReplayBufferStart		; start of the buffer
	bne .a4ne
	lda.b a4+2						; bank
	cmp.w #ReplayBufferStart>>16
	bne .a4ne
	lda.w sflags					; flags
	bit.w #sfwrap
	beq .end						; not wrapped: stay
	lda.w #ReplayBufferEnd
	sta.b a4						; else the end
	lda.w #ReplayBufferEnd>>16
	sta.b a4+2
.a4ne:								; not the same low word
	lda.b a4						; a4
	sec
	sbc.w #replaysize				; one frame back
	sta.b a4
	lda.b a4+2
	sbc.w #$0000					; carry
	sta.b a4+2
	lda.b a4
	cmp.w ReplayBufferPtr			; compare with the pointer
	beq .a4eq						; equal
	jml.l RestoreReplayFrame		; restore the frame
.a4eq:								; same bank as the record pointer
	lda.b a4+2						; high word
	cmp.w ReplayBufferPtr+2
	beq .a4eq2						; equal
	jml.l RestoreReplayFrame		; restore the frame
.a4eq2:								; undo the move: stay at the record pointer
	lda.b a4						; undo the move
	clc
	adc.w #replaysize
	sta.b a4						; a4
	lda.b a4+2
	adc.w #$0000					; high word
	sta.b a4+2
.end:								; show the frame, no extra frames
	jsl.l RestoreReplayFrame		; restore the frame
	stz.b d7						; no extra frames
	rtl
