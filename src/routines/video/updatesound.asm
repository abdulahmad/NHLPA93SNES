updatesound:						;Move the crowd noise volume toward crowdlevel and send it when it changes
	ldy.b d7						; frames
	lda.b crowdlevel				; target volume crowdlevel * 8 + $200 (max $CFF)
	asl a							; times 8
	asl a
	asl a
	adc.w #$0200					; plus $200
	cmp.w #$0CFF					; cap at $CFF
	bcc .ip
	lda.w #$0CFF
.ip:
	sta.b tmp0						; target
.step:
	lda.b tmp0						; target
	sec
	sbc.w asv						; minus the current volume
	lsr a							; /16
	lsr a
	lsr a
	lsr a
	bit.w #$0800					; signed
	beq .add
	ora.w #$F000					; sign extend
.add:
	clc
	adc.w asv						; plus the current
	sta.w asv						; new volume
	dey								; one frame less
	bne .step
	sta.b mula						; scale
	lda.w #$009D					; scale to 0-$9D, + $80
	sta.b mulb
	jsl.l mulu						; multiply
	lda.b mulres+2					; high word
	adc.w #$0080					; plus $80
	cmp.w crowdvol					; same as before
	beq .rtl
	sta.w crowdvol					; store
	pha								; keep it
	jsl.l sfx8F						; send it
.rtl:
	rtl
