ClearSprites:						;Move every sprite off screen and start a new sprite frame
	clc								; clear carry
	ldx.w #$0000					; offset 0
	ldy.w #$0008					; 8 blocks of 16 sprites
.loop:
	lda.w #$E0E0					; y = $E0, x = $E0: off screen
	sta.w Satt,x					; sprite 0
	stz.w Satt+2,x					; attributes 0
	sta.w Satt+$4,x
	stz.w Satt+$6,x
	sta.w Satt+$8,x
	stz.w Satt+$A,x
	sta.w Satt+$C,x
	stz.w Satt+$E,x
	sta.w Satt+$10,x
	stz.w Satt+$12,x
	sta.w Satt+$14,x
	stz.w Satt+$16,x
	sta.w Satt+$18,x
	stz.w Satt+$1A,x
	sta.w Satt+$1C,x
	stz.w Satt+$1E,x
	sta.w Satt+$20,x
	stz.w Satt+$22,x
	sta.w Satt+$24,x
	stz.w Satt+$26,x
	sta.w Satt+$28,x
	stz.w Satt+$2A,x
	sta.w Satt+$2C,x
	stz.w Satt+$2E,x
	sta.w Satt+$30,x
	stz.w Satt+$32,x
	sta.w Satt+$34,x
	stz.w Satt+$36,x
	sta.w Satt+$38,x
	stz.w Satt+$3A,x
	sta.w Satt+$3C,x
	stz.w Satt+$3E,x
	txa								; next block
	adc.w #$0040
	tax
	dey								; count down
	bne .loop
.hiclear:							; clear the high table
	stz.w Satt,x
	inx
	inx
	cpx.w #$0220					; $220 bytes in all
	bne .hiclear
	stz.b sprcount					; no sprites yet
	inc.b sprclock					; sprite clock
	lda.b sprnodraw					; any sprites not drawn?
	beq .nosprnodraw
	stz.b sprnodraw					; clear it
	lda.b sprslotlife
	cmp.w #$0003					; slot life above 2
	bcc .nosprnodraw
	dec.b sprslotlife				; shorten the slot life
.nosprnodraw:
	lda.b sprbigslot				; big slot
	sta.b sprbigslotend				; end of the big slots
	lda.b sprslot					; small slot
	sta.b sprslotend				; end of the small slots
	rtl
