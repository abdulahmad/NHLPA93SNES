SuperMult:							;password bits *= d0
	phx
	ldx.w #$000E
.copy:
	lda.w pwddatabuffer,x			; copy pwddatabuffer, clear pwddatabuffer
	sta.b mulres,x
	stz.w pwddatabuffer,x
	dex
	dex
	bpl .copy
	lda.b d0
	sta.b mula
.loop:
	lsr.b mula
	bcc .noadd
	lda.w pwddatabuffer
	clc
	adc.b mulres
	sta.w pwddatabuffer
	lda.w pwddatabuffer+2
	adc.b mulres+2
	sta.w pwddatabuffer+2
	lda.w pwddatabuffer+4
	adc.b mulres+4
	sta.w pwddatabuffer+4
	lda.w pwddatabuffer+6
	adc.b mulres+6
	sta.w pwddatabuffer+6
	lda.w pwddatabuffer+8
	adc.b mulres+8
	sta.w pwddatabuffer+8
	lda.w pwddatabuffer+10
	adc.b mulres+10
	sta.w pwddatabuffer+10
	lda.w pwddatabuffer+12
	adc.b mulres+12
	sta.w pwddatabuffer+12
	lda.w pwddatabuffer+14
	adc.b mulres+14
	sta.w pwddatabuffer+14
.noadd:
	asl.b mulres
	rol.b mulres+2
	rol.b mulres+4
	rol.b mulres+6
	rol.b mulres+8
	rol.b mulres+10
	rol.b mulres+12
	rol.b mulres+14
	lda.b mula
	bne .loop
	plx
	clc
	rtl
