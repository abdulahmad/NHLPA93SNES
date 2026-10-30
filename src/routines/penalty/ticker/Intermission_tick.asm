Intermission_tick:					;During the intermission, show the next ticker score from time to time,
									;then the highlights
	lda.w demoflag					; not in the intermission demo
	beq .rtl
	lda.b Vcount					; time since the last score
	sec
	sbc.w tickervc
	cmp.w #$0150					; $150 frames
	bcc .wait						; not yet
	jsl.l NewTicker2_next				; next ticker score
	lda.w tickerstart				; back at the first game?
	cmp.w TickerNum
	bne Intermission_tick			; no: show the next one
	jsl.l DoHiLights				; else the highlights
	lda.w #$0008
	trb.w sflags3					; clear sflags3 bit 3
.rtl:								; return
	rtl
.wait:								; nothing to report
	lda.w #$0000					; nothing to report
	rtl
