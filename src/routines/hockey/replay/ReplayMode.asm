ReplayMode:							;Instant replay: rewind, play, stop, slow motion and single frame steps,
									;with the pad scrolling the view
	stz.b DMAlistend
	stz.b Crowdlevel
	lda.w #sf2replay				; sf2replay: replay on
	tsb.w sflags
	jsl.l ClrHor					; back to the vertical rink
	stz.w VMADDL					; clear the text layer map in vram
	lda.w #$FFFF
	sta.b textdirtylo
	stz.b textdirtyhi
	lda.w blankchar
	clc
	adc.w charofs
	ldx.w #$0400
.clr:								; clear the replay icon area
	sta.w VMDATAL
	dex
	bne .clr
	lda.w #$0042					; the replay icon from the IceRinkMap data, 8 x 4 at vram $42
	sta.b tmp0
	ldx.w #$2020
	lda.w #$0004
	sta.b tmp1
.icon:								; draw the replay icon
	lda.b tmp0
	sta.w VMADDL
	ldy.w #$0008
.iconrow:							; draw one icon row
	lda.l IceRinkMap,x
	ora.w #$2000
	clc
	adc.w charofs
	sta.w VMDATAL
	inx
	inx
	dey
	bne .iconrow
	lda.b tmp0
	clc
	adc.w #$0020
	sta.b tmp0
	txa
	adc.w #$0050
	tax
	dec.b tmp1
	bne .icon
	lda.w #sfscrl					; manual scroll off
	trb.w sflags
	lda.w Vpos
	pha
	lda.w Hpos
	pha
	lda.w recbpr			;recbpr must be inside
	;replaystart..replayend on a frame boundary
	cmp.w #replaystart
	lda.w recbpr+2
	sbc.w #replaystart>>16
	bcs .chk
.wrap:								;the buffer pointer back inside the replay buffer
	lda.w #replaystart
	sta.w recbpr
	lda.w #replaystart>>16
	sta.w recbpr+2
.chk:								; check the replay buffer limit
	lda.w #replayend
	cmp.w recbpr
	lda.w #replayend>>16
	sbc.w recbpr+2
	bcc .wrap
	lda.w recbpr
	sec
	sbc.w #replaystart
	sta.b mulb
	lda.w recbpr+2
	sbc.w #replaystart>>16
	sta.b mulb+2
	lda.w #replaysize
	sta.b mula
	jsl.l divu
	lda.b mulres+2
	bne .wrap
	lda.w recbpr
	sta.b a4
	lda.w recbpr+2
	sta.b a4+2
	lda.w #$0000
	pha
.rwd:								;rewind to the first frame, counting the frames
	jsl.l suba4						; one replay frame back
	pla
	inc a
	pha
	lda.b d7
	bne .rwd
	pla
	lsr a
	pha								; $01,s = half the step count
.fwd:								;then forward to the middle
	lda.b $01,s
	beq .go
	jsl.l adda4						; one replay frame on
	pla
	dec a
	pha
	bra .fwd
.go:								; sort the sprites and update the video
	pla
	jsl.l SprSort					; sort the sprites
	jsl.l setvideo					; update the video
	lda.w #sf3rmplay				; play mode off
	trb.w sflags3
	lda.w #$0001
	sta.b d7
.top:								;wait d7 frames
	lda.b Vcount
	sec
	sbc.w OldVcount
	cmp.b d7
	bcc .top
	lda.b Vcount
	sta.w lastframevc
	sta.w OldVcount
	jsl.l ReadPads					; read the pads
	lda.w #$0001
	sta.b d7
	jsl.l getpzjoy					; d0 = dpad direction (8 = none), d1 = new buttons, d3 = held
	lda.b d0
	bit.w #$0008
	beq .man
	jmp.w .nomans
.man:								;dpad: scroll by hand
	and.w #$0007
	sta.b d0
	lda.w #sfscrl					; sfscrl
	tsb.w sflags
	asl.b d0
	asl.b d0
	lda.w #.stab					; a0 = .stab
	sta.b a0
	lda.w #.stab>>16
	sta.b a0+2
	ldy.b d0
	lda.b [a0],y
	adc.w Hpos
	sta.b d1
	bit.w #$8000
	beq .xabs
	eor.w #$FFFF					; negate
	inc a
.xabs:								; x step within the screen?
	cmp.w #$0041					; x step within the screen
	bcs .nox
	lda.b d1
	sta.w Hpos
.nox:								; camera X step
	iny
	iny
	lda.b [a0],y
	clc
	adc.w Vpos
	sta.b d1
	sec
	sbc.w #$0100
	beq .ylo
	bmi .yneg
	bvs .ylo
	bra .noy
.yneg:								; signed compare: overflow flag corrects the sign
	bvs .noy
.ylo:								; clamp Y at the lower limit
	lda.b d1
	sec
	sbc.w #$FF39
	bmi .yneg2
	bvc .sety
	bra .noy
.yneg2:								; signed compare: overflow flag corrects the sign
	bvc .noy
.sety:								; store the vertical position
	lda.b d1
	sta.w Vpos
.noy:								; PadControlBits $E000
	lda.w PadControlBits			; PadControlBits $E000: no player marker
	and.w #$0FFF
	ora.w #$E000
	sta.w PadControlBits
	jsl.l setvideo					; update the video
	jmp.w .top
.stab:								;x, y scroll step per dpad direction
	dw 0,1,1,1,1,0,1,-1
	dw 0,-1,-1,-1,-1,0,-1,1
.nomans:							; A: switch the play mode
	lda.b d1						; A: switch play mode
	bit.w #JOYA
	beq .lr
	lda.w sflags3
	eor.w #sf3rmplay
	sta.w sflags3
.lr:								; L/R: one frame back or on
	lda.b d1						; L/R: one frame back/on
	bit.w #JOYL
	bne .back1
	bit.w #JOYR
	bne .fwd1
	lda.b d3						; Y held: rewind (one frame per vblank)
	bit.w #abut
	beq .step
	jsl.l suba4						; one replay frame back
	jsl.l SprSort					; sort the sprites
	lda.w #VBlank_long
.wait:								; wait for the next frame
	cmp.b VBint
	beq .wait
	bra .vid
.back1:								;L: one frame back
	jsl.l suba4						; one replay frame back
.show:								; sort the sprites, update the video
	jsl.l SprSort					; sort the sprites
.vid:								; update the video
	jsl.l setvideo					; update the video
	lda.w #$0001
	sta.b d7
	lda.w #sf3rmplay
	trb.w sflags3
.step:								;B steps
	lda.b d3						; B: step
	bit.w #bbut
	beq .pl
	bit.w #abut						; Y+B: manual scroll off
	beq .stepon
	lda.w #sfscrl
	trb.w sflags
	jmp.w .top
.fwd1:								;R: one frame on
	jsl.l adda4						; one replay frame on
	bra .show
.stepon:							; one replay frame on
	jsl.l adda4						; one replay frame on
	jsl.l SprSort					; sort the sprites
	jsl.l setvideo					; update the video
	asl.b d7
	lda.w #sf3rmplay
	trb.w sflags3
.pl:								;play mode on: one frame at the original speed, with its sounds
	lda.w sflags3
	bit.w #sf3rmplay
	beq .noplay
	stz.w lastsfx					; lastsfx = 0: play the frame's sound
	jsl.l adda4						; one replay frame on
	lda.w lastsfx
	beq .nosfx
	pha
	jsl.l sfx
.nosfx:								; sort the sprites, update the video; Start: leave
	jsl.l SprSort					; sort the sprites
	jsl.l setvideo					; update the video
.noplay:							; Start: leave
	lda.b d1						; Start: leave
	bit.w #sbut
	bne .exit
	jmp.w .top
.exit:								; blank the screen, release the pads
	jsl.l forceblack				; blank the screen
	lda.w #$F000
	tsb.w PadControlBits
	lda.w #sfscrl
	trb.w sflags
	lda.w recbpr			; back to the current frame
	sta.b a4
	lda.w recbpr+2
	sta.b a4+2
	jsl.l RestoreReplayFrame
	jsl.l SprSort					; sort the sprites
	pla
	sta.w Hpos
	pla
	sta.w Vpos
	lda.w #sf2replay
	trb.w sflags
	jsl.l SetHor					; switch to the horizontal rink
	jsl.l setvideo					; update the video
	stz.b textdirtylo
	lda.w #$03FF
	sta.b textdirtyhi
	rtl
