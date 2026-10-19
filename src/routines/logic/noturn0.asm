noturn0:							;doplayeracc when the wanted direction needs no turn
	lda.w #$0002					; d4 = 2, 6 skating backwards
	sta.b d4						; backwards?
	lda.w pfrev,x
	beq .0
	lda.w #$0006					; d4 = 6
	sta.b d4
	lda.b d0
	eor.w #$0008					; flip the direction
	sta.b d0
.0:
	lda.b d0						; direction
	beq .nochg
	lda.w Xvel,x					; moving: stop if the direction is more than 90 degrees off
	sta.b d0
	lda.w Yvel,x					; Y velocity
	sta.b d1
	jsl.l vtoa						; vector to direction
	bit.w #$0008					; no direction?
	bne .nostop
	sec								; minus the facing
	sbc.w facedir,x
	clc
	adc.b d4						; plus d4
	and.w #$0007
	sta.b d0
	cmp.w #$0004					; 90 degrees or more off?
	bcs .nostop
	jml.l dostop					; stop
.nostop:
	inc.w facedir,x					; turn one step
	lda.w attribute,x				; attribute
	bit.w #attrxflip
	beq .nos0
	dec.w facedir,x					; flipped: turn back
	dec.w facedir,x
.nos0:
	lda.w facedir,x					; facing
	and.w #$0007
	sta.w facedir,x
	lda.w #SPAglide					; glide
	sta.b d1
	lda.w pfrev,x					; backwards?
	bne .gback
	jml.l SetSPA					; start animation d1
.gback:
	lda.w #SPAglideback				; glide back
	sta.b d1
	jml.l SetSPA					; start animation d1
.nochg:
	lda.w #SPAskateback				; no change: skate
	sta.b d1
	lda.w pfrev,x					; backwards?
	bne .ns
	lda.w #SPAskate					; skate
	sta.b d1
	lda.w pflags,x					; pflags $0004 (pflags2 bit 6): stumble
	bit.w #pf2inj					; injured?
	beq .nb6
	lda.w #SPAstumble				; stumble
	sta.b d1
.nb6:
	lda.w puckc						; carrier: skate with the puck
	sta.b d4
	cmp.w SCnum,x					; is X the carrier?
	bne .ns
	lda.w #SPAskatewp				; skate with the puck
	sta.b d1
.ns:
	lda.w pf2aip,x					; animation in progress?
	beq .set
	jml.l noturn					; keep it
.set:
	jsl.l SetSPA					; start animation d1
	jml.l noturn					; accelerate
