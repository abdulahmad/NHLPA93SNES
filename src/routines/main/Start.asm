Start:								;Reset entry and cold start: switch to native mode, clear RAM, set up the
									;interrupt handlers and sprite tile cache,
		;   check the ROM, start the hardware and sound, then go to the title screen
	sei								; interrupts off
	clc
	xce								; native mode
	rep #$30						; 16-bit registers
	lda.w #$1FFF
	tcs								; stack at the top of low RAM
	lda.w #$0000
	tcd								; D = 0
	sep #$20						; 8-bit A
	pha
	plb								; DB = $00 (low RAM and registers)
	rep #$30						; 16-bit registers
	ldx.w #$0000
.clrdp:								;clear the direct page and the low RAM variables
	stz.b vcount,x
	inx
	inx
	cpx.w #DPCLEAREND
	bcc .clrdp
	lda.w #vb2_blank
	sta.b vbint
	lda.w #HBdefault
	sta.b hbint
	lda.w #JMLOPCODE				; jml opcode for the jmlvector trampoline
	sta.w jmlvector
	lda.w #$0012					; sprite VRAM slots stay reserved 18 frames
	sta.b sprslotlife
	lda.b sprclock
	sec
	sbc.w #$003C					; 60 frames ago
	ldx.w #$0000
.clrcache:							;sprframetime: every frame "sent 60 frames ago" (sprclock-$3C), so every
									;cached frame is stale
	sta.l sprframetime,x
	inx
	inx
	cpx.w #$4C74
	bne .clrcache
	ldx.w #$0000
.clrslots:							;sprslottime: every VRAM sprite slot free
	sta.w sprslottime,x
	inx
	inx
	cpx.w #$0400
	bne .clrslots
	lda.w #$0020
	sta.b sprpriority
	stz.b tmp0						; sum = 0
	ldx.w #$0000
	ldy.w #$0002					; word at +2 of each pointer
.sumloop:							;sum the word at [ptr]+2 for each long ptr in the table at FrameSetTable
									;(0-terminated, 4 bytes per entry)
	lda.l FrameSetTable,x
	beq .validate
	sta.b tmp1
	lda.l FrameSetTable+1,x
	sta.b tmp1+1
	lda.b [tmp1],y
	clc
	adc.b tmp0
	sta.b tmp0
	inx
	inx
	inx
	inx
	bra .sumloop
.validate:							;anti-tamper: hang forever unless the sum is $131D
	lda.b tmp0
	cmp.w #$131D
	bne .validate
	lda.w #$0001					; hold the sound queue while the hardware/sound driver starts
	sta.b sndlock
	jsl.l InitPPU					; PPU registers off/clear, sound driver start
	sep #$20						; 8-bit A
	cli
	lda.w RDNMI						; ack a pending NMI
	lda.b #NMITIMEN_NMI|NMITIMEN_JOY	; NMI on, auto joypad read
	sta.w NMITIMEN
	rep #$30						; 16-bit registers
	jsl.l SPCBootUpload
	stz.b sndlock
	stz.b vbactive					; vblank handlers may run
	jsl.l ResetPassWord				; PassWord: 16 characters of $1E
	jsl.l DefaultMenus				; initial menu choices from OptPlayMode on
	jsl.l Readjoy12
	jml.l Opening					; on to the title screen
