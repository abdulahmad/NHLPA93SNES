addframe_hi:						;addframe for the high frame numbers: find the frame set and draw it with
									;DrawFrameHi
	lda.b sprframe					; frame number
	cmp.w #SPFcrowd					; 6-byte pieces from SPFcrowd on
	bcs .hi							; high frames
	jml.l addframe_end				; low frames: normal
.hi:
	dec.b sprframe					; renumber
	stz.b sprsetofs					; first piece set offset 0
	ldx.w #$0000					; table index
	ldy.w #$0002
.find:
	lda.l FrameSetTable,x			; skip empty table entries
	beq .find						; empty
	sta.b farptr					; pointer to the set
	lda.l FrameSetTable+1,x			; bank
	sta.b farptr+1					; high byte
	lda.b sprframe					; frame
	sec
	sbc.b [farptr]					; minus the set size
	bcs .next						; frame is later
	jml.l DrawFrameHi				; in this set
.next:
	sta.b sprframe					; the rest
	lda.b sprsetofs
	clc
	adc.b [farptr],y
	sta.b sprsetofs					; offset past this set
	inx								; next table entry
	inx
	inx
	inx
	bra .find
