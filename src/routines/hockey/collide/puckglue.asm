puckglue:							;Player a2 takes the puck
	lda.w seed+2					; pickup sound (one of 4)
	and.w #$0003
	clc
	adc.w #SFXshotwiff
	pha
	jsl.l sfx
	ldy.b a2						; player
	tya
	lsr a							; player number
	sta.w puckc						; puckc = a2
	sta.b d0						; d0 = him
	stz.b a0						; a0 = 0
	lda.w #$0002					; a1 = 2
	sta.b a1
	lda.w pfteam,y					; team
	bne .tm							; team 1
	stz.b a1						; a1 = 0
	lda.w #$0002
	sta.b a0						; a0 = 2
.tm:								; other team loses its touch
	ldy.b a0						; other team
	lda.w #$FFFF					; no touches
	sta.w tmtouch2,y				; other team loses its touches
	sta.w tmtouch3,y				; touches
	lda.w tmflags,y					; flags
	ora.w #tmflast					; last touch
	sta.w tmflags,y					; store
	lda.w #sf3fo
	trb.w sflags3					; sf3fo: this pickup wins the faceoff
	beq .snd						; no faceoff win
	ldy.b a1						; faceoff team
	lda.w tmfowon,y					; faceoff wins
	inc a
	sta.w tmfowon,y
	lda.b Crowdlevel				; +200
	clc								; crowd noise
	adc.w #$00C8
	sta.b Crowdlevel
.snd:								; d0 = the player number
	lda.b a2						; player
	lsr a							; number
	sta.b d0						; d0
	cmp.w passReceiverPlayerNum		; pass reached its receiver
	bne .nrec
	ldy.b a1						; team
	lda.w tmpasscomp,y				; passes completed
	inc a							; one more
	sta.w tmpasscomp,y
.nrec:								; no pass pending any more
	lda.w #$FFFF					; none
	sta.w passReceiverPlayerNum		; no receiver now
	lda.w #sfspdir|sfssdir			; clear sfspdir/sfssdir
	trb.w sflags
	ldy.b a2						; player
	lda.w position,y				; position
	beq .goalie						; goalie
	jml.l setd0player				; give him to the controller
.goalie:							; goalie: count a shot, puck lockout 140
	jsl.l ChkShotStat				; ChkShotStat (goalie made a save)
	ldy.b a2						; player
	lda.w #$008C					; temp5 = 140, count down for the faceoff
	sta.w temp5,y					; store
	lda.w SPA,y						; animation
	cmp.w #SPAgdive
	beq .gdive						; diving: short
	jml.l setd0player				; give him to the controller
.gdive:								; diving goalie: 5 frames
	lda.w #$0005					; 5 frames
	sta.w temp5,y
	jml.l setd0player
