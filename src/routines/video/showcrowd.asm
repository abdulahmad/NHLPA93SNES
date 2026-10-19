showcrowd:							;Draw the crowd and penalty box sprites
	stz.b a1						; sprite counter
	lda.w Hpos						; horizontal scroll
	sta.b d4
	lda.w Vpos						; vertical scroll
	sta.b d5
	lda.w sfhormode					; horizontal mode?
	beq .v
	lda.w #$FFC0					; scroll x for the horizontal rink
	sta.b d4
	lda.w #$0100					; scroll y for the horizontal rink
	sta.b d5
.v:
	stz.b d0						; first penalty box
	lda.w PBnum						; count of the first box
	sta.b d2
	lda.w #$001A					; frames 26+
	sta.b d3
	jsl.l .pb						; draw the first box
	lda.w PBnum						; count of the second box
	lsr a
	lsr a
	lsr a
	lsr a
	sta.b d2						; count
	lda.w #$001D					; frames 29+
	sta.b d3
	jsl.l .pb						; draw the second box
	lda.w sfhormode					; horizontal mode?
	bne .rtl						; no crowd
	lda.b crowdframe				; first crowd frame
	sta.b d0
	jsl.l .sc						; draw it
	lda.b crowdframe+1				; second crowd frame
	sta.b d0
	bra .sc							; draw it
.pb:								;d2 = count, d3 = first frame
	lda.b d2						; count
	and.w #$000F
	sta.b d2
	cmp.w #$0004					; at most 3
	bcc .pb0
	lda.w #$0003
	sta.b d2
.pb0:
	bra .nextpb						; next sprite
.pbt:
	lda.b d3						; frame
	clc
	adc.b d2
	sta.b d0						; frame number
	jsl.l .sc						; draw it
.nextpb:
	dec.b d2						; sprites left
	bpl .pbt
.rtl:								; return
	rtl
.sc:								;d0 = frame (0 = none): SPFcrowd-1 + d0 (+31 horizontal) at the rink
									;scroll position
	lda.b d0						; frame byte
	and.w #$00FF
	sta.b d0
	beq .rtl						; none
	lda.w sfhormode					; horizontal mode?
	beq .chk
	lda.b d0
	clc								; horizontal frames
	adc.w #31
	sta.b d0
.chk:
	lda.b d0						; frame
	clc
	adc.w #SPFcrowd-1				; local frame 1 is SPFcrowd
	sta.b sprframe
	lda.w #$FFC0					; x = $FFC0 - Hpos
	sec
	sbc.b d4
	sta.b sprx
	lda.w #$FEFF					; y = Vpos - $101
	clc
	adc.b d5
	sta.b spry
	jml.l addframe_hi				; draw it
