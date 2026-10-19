adda4:								;Move the replay one frame forward
	stz.b d7						; no extra frames
	lda.w sflags					; flags
	bit.w #sf2drec
	beq .nosf2drec					; recording?
	lda.b a4+2						; keep a4
	pha
	lda.b a4
	pha
	jsl.l adda43					; next frame in the buffer
	lda.b a4						; new a4
	sta.b tmp0
	lda.b a4+2
	sta.b tmp1
	pla								; restore a4
	sta.b a4
	pla
	sta.b a4+2
	lda.b tmp0						; compare with the buffer pointer
	cmp.w ReplayBufferPtr
	bne .nosf2drec
	lda.b tmp1
	cmp.w ReplayBufferPtr+2
	bne .nosf2drec
	rtl								; reached the end
.nosf2drec:
	lda.b a4						; compare a4 with the pointer
	cmp.w ReplayBufferPtr
	bne .a4ne
	lda.b a4+2
	cmp.w ReplayBufferPtr+2
	bne .a4ne
	rtl								; reached the end
.a4ne:
	jsl.l RestoreReplayFrame		; restore the frame
	jml.l adda43					; advance
