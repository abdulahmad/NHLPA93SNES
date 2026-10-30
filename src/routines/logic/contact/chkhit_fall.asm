chkhit_fall:							;Player X lost the fight: the other player gets a fighting penalty and X
									;may be injured
	lda.b a1+2						; push a1
	pha
	lda.b a1
	pha
	lda.w #PenaltyBufferEnd			; a1 = penalty list
	sta.b a1
	lda.w #$0000
	sta.b a1+2
.loop:								;find the fight penalty of the a0 player
	inc.b a1
	inc.b a1
	lda.b [a1]
	and.w #$00FF
	cmp.w #PenFighting
	bne .loop
	lda.b [a1]
	xba
	and.w #$000F
	sta.b d0
	ldy.b a0
	cmp.w SCnum,y					; penalty of the a0 player?
	bne .loop
	sep #$20						; 8-bit A
	lda.b #PenFighting2				; it becomes PenFighting2
	sta.b [a1]
	rep #$20						; 16-bit A
	pla
	sta.b a1
	pla
	sta.b a1+2
	lda.w #$003C					; 60
	sta.w PenCntDwn
	lda.w #$FFFF					; temp3(a0) = -1: fight over for him
	sta.w temp3,y
	lda.b Crowdlevel
	clc
	adc.w #$0258					; +600
	sta.b Crowdlevel
	lda.w #$003C
	sta.b d0
	jsl.l randomd0					; random number 0 to d0-1
	ldy.b a0
	lda.b d0
	sec
	sbc.w checking,y				; random 60 vs the winner checking: injury?
	beq .inj
	bmi .neg
	bvs .inj
	bra .noinj
.neg:								; signed compare: overflow flag corrects the sign
	bvs .noinj
.inj:								;player X is injured
	lda.w #$00B4					; 180: player is injured
	sta.w PenCntDwn
	lda.w pflags,x
	ora.w #pf2inj
	sta.w pflags,x
	lda.w #SPAfinjury
	sta.b d1
	jsl.l SetSPA					; start animation d1
	stx.b a2
	jsl.l setInjuryType				; setInjuryType (bank $8F): d1 = roster offset, bank $8F
	lda.b a0
	beq .team
	lda.w #$0034
.team:								; team index
	clc
	adc.b d1
	tay
	lda.w #INJfight					; tmpdst of the injured player = INJfight
	sta.w tmpdst,y
	lda.w #$0003
	sta.w InjCntDown				; InjCntDown = 3
	stz.w Xvel,x
	jmp.w chkhit_ex
.noinj:								; not injured: fight fall animation
	lda.w #SPAffall
	sta.b d1
	jsl.l SetSPA					; start animation d1
	stz.b a2
	lda.w #SFXcrowdcheer			; home won: cheer
	pha								; $01,s = the crowd sound number
	lda.w pfteam,x
	bne .snd
	lda.w #$0002
	sta.b a2
	lda.w #SFXcrowdboo
	sta.b $01,s
.snd:								; play the fall sound
	jsl.l sfx
	jmp.w chkhit_ex
