addframe:							;Draw sprite frame sprframe at sprx / spry: find its frame set, then draw
									;it
	lda.b sprframe					; frame
	cmp.w #SPFcrowd					; 6-byte pieces from SPFcrowd on
	bcc .sprframelt					; low frames: look up the set
	jml.l addframe_end				; else the long form
.sprframelt:						; renumber
	dec.b sprframe					; renumber
	bpl .sprframepos				; frame 0: nothing
	jml.l addframe_end
.sprframepos:						; piece set offset 0
	stz.b sprsetofs					; piece set offset 0
	ldx.w #$0000					; table index
	ldy.w #$0002					; offset of the set size
.loop:								; set pointer
	lda.l FrameSetTable,x			; set pointer
	beq .loop						; empty entry
	sta.b farptr
	lda.l FrameSetTable+1,x			; bank
	sta.b farptr+1
	lda.b sprframe					; frame
	sec
	sbc.b [farptr]					; minus the set size
	bcs .sprframege					; frame is later
	jml.l DrawFrame					; in this set
.sprframege:						; the rest of the frame number
	sta.b sprframe					; the rest
	lda.b sprsetofs
	clc
	adc.b [farptr],y				; offset past this set
	sta.b sprsetofs
	inx								; next entry
	inx
	inx
	inx
	bra .loop
