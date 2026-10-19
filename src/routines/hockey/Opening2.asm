Opening2:							;Opening2 from scratch: reset the hardware and RAM, set the default
									;handlers and options, then the playoff screen
	sei								; interrupts off, native mode
	clc								; native mode
	xce
	rep #$30						; 16-bit registers
	lda.w #$1FFF					; stack
	tcs
	lda.w #$0000					; direct page 0
	tcd
	sep #$20						; bank 0
	pha
	plb
	rep #$30						; 16-bit registers
	jsl.l InitPPU					; hardware
	ldx.w #$0000					; clear RAM
.clr:
	stz.b vcount,x
	inx
	cpx.w #$15FF
	bne .clr						; $15FF bytes
	lda.w #$005C					; jmlvector opcode, sprite slot life 18
	sta.w jmlvector					; jml opcode
	lda.w #$0012
	sta.b sprslotlife				; sprite slot life
	lda.b sprclock					; free all sprite VRAM slots
	sec
	sbc.w #$003C
	ldx.w #$0000					; clear the frame times
.cache:
	sta.l sprframetime,x
	inx
	inx
	cpx.w #$4C74
	bne .cache
	ldx.w #$0000					; and the slot times
.cache2:
	sta.w sprslottime,x
	inx
	inx
	cpx.w #$0400
	bne .cache2
	lda.w #$0020					; sprite priority
	sta.b sprpriority
	lda.w #vb2						; blank vblank
	sta.b vbint
	lda.w #HBdefault				; default hblank
	sta.b hbint
	jsl.l setoptions				; options
	jml.l Opening3					; go on
