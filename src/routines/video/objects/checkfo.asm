checkfo:							;Draw the face off sprites
	lda.w sflags					; not in pause, face off only
	bit.w #sfpz						; pause screen
	bne .rtl						; no sprites
	lda.w sflags					; flags
	bit.w #sf2faceoff				; face off in progress
	beq .rtl						; no: leave
	lda.w #$0030					; faceoff sprites above the players
	sta.b sprpriority
	ldx.w #$0000					; entry 0
.top:								; drop position x
	lda.w fodropx					; drop position x
	sta.b sprx
	lda.w fodropy					; y
	sta.b spry
	lda.w fofdata2,x				; 1-based faceoff frame
	clc								; plus the base frame
	adc.w #SPFfaceoff-1				; -1 for 1-based
	sta.b sprframe
	lda.w fofdata2+2,x				; flip bits
	and.w #$0800
	sta.b sprhflip					; horizontal flip
	cpx.w #$0004					; third entry (the ref): sprflag
	bne .add						; not the ref
	lda.w #$8000					; ref flag
	sta.b sprflag					; sprflag
.add:								; sprframe at sprx/spry
	phx								; keep the index
	jsl.l addframe					; sprframe at sprx/spry
	plx								; restore the index
	inx								; next entry (4 bytes)
	inx
	inx
	inx
	cpx.w #$000C					; three entries
	bne .top
	lda.w #$0020					; normal priority again
	sta.b sprpriority
.rtl:								; return
	rtl
