PushTime:							;a1 = the time d0 (seconds) as a minutes:seconds string
	lda.w #mesarea+30				; write backwards from the end of the buffer
	sta.b a1
	lda.w #mesarea>>16
	sta.b a1+2
	lda.b d0						; seconds
	sta.b mulb
	lda.w #$000A					; 10
	sta.b mula
	jsl.l divu16					; divide
	dec.b a1						; one character back
	sep #$20						; 8-bit A
	lda.b mulres+2					; seconds ones
	adc.b #$30						; ASCII
	sta.b [a1]						; store it
	rep #$30						; 16-bit registers
	lda.w #$0006					; 6
	sta.b mula
	jsl.l divu16					; seconds tens
	dec.b a1						; one character back
	sep #$20						; 8-bit A
	lda.b mulres+2
	adc.b #$30						; ASCII
	sta.b [a1]
	dec.b a1						; one character back
	lda.b #$3A						; colon
	sta.b [a1]
	rep #$30						; 16-bit registers
	lda.w #$000A					; 10
	sta.b mula
	jsl.l divu16					; minutes ones
	dec.b a1						; one character back
	sep #$20						; 8-bit A
	lda.b mulres+2
	adc.b #$30
	sta.b [a1]
	rep #$30						; 16-bit registers
	lda.b mulres
	beq .noz						; minutes tens present?
	dec.b a1						; one character back
	sep #$20						; 8-bit A
	adc.b #$30						; ASCII
	sta.b [a1]
	rep #$30						; 16-bit registers
.noz:
	dec.b a1						; room for the length word
	dec.b a1
	lda.w #$01AF					; end of the buffer
	sec
	sbc.b a1
	sta.b [a1]						; length word
	rtl
