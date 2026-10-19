noturn:								;playeracc for a player skating backwards
	lda.w pfrev,x					; reversed skating flag
	beq .acc						; not reversed: keep d2
	lda.b d2
	eor.w #$0004					; turn the direction by half
	sta.b d2
.acc:
	jml.l playeracc					; continue in playeracc
