sfx8F:								;Queue the sound number pushed before the call, unless sound effects are
									;muted for now. Also sends the crowd volume
	pla								; return address +1 into jmlvector
	inc a
	sta.w jmlvector+1
	sep #$20						; 8-bit A
	pla
	sta.w jmlvector+3				; bank
	rep #$20						; 16-bit A
	lda.b vcount
	sec
	sbc.w sfxmutetime
	cmp.w #$00B4					; muted for 180 frames
	bcc .muted						; muted: drop it
	pla								; the sound (0 = none)
	beq .ret						; no sound: skip
	jsl.l QueueSound				; queue it
.ret:								; far branch to jmlvector
	jml.l jmlvector
.muted:								; muted: drop the sound
	pla								; drop the pushed sound
	bra .ret
