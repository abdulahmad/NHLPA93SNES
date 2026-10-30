PauseMenu:							;Draw the pause menu and read the pad: up and down move, Start leaves,
									;else run the chosen item.
									;A = 0 to leave, 1 to redraw
	stz.w psitem
.gj:								; redraw the menu and read the pad
	jsl.l Pmenu						; draw the pause menu
	jsl.l PauseReadJoy				; read the pad
	lda.b d1						; Start: leave
	bit.w #sbut
	beq .down
	jml.l PauseLeave
.down:								;down
	bit.w #dbut
	beq .up
	inc.w psitem
	lda.w psitem
	cmp.w #$0005
	bne .gj
	dec.w psitem
	bra .gj
.up:								;up
	bit.w #ubut
	beq .item
	dec.w psitem
	bpl .gj
	stz.w psitem
	bra .gj
.item:								;go to .jump[psitem] through jmlvector
	lda.w psitem					; jmlvector = .jump[psitem]
	asl a
	asl a
	sta.b d0
	tay
	lda.w #.jump
	sta.b a0
	lda.w #.jump>>16
	sta.b a0+2
	lda.b [a0],y
	sta.w jmlvector+1
	iny
	lda.b [a0],y
	sta.w jmlvector+2
	jml.l jmlvector
.rm:								;Instant Replay (A = ReplayMode)
	lda.b d1
	bit.w #cbut
	beq .gj
	jsl.l forceblack				; blank the screen
	jsl.l sndqreset					; reset the sound queue
	lda.b d7
	pha
	lda.b Vcount+2
	dec a
	dec a
	sta.w vcountmark+2
	jsl.l ReplayMode
	pla
	sta.b d7
.redraw:							;return 1: draw the pause screen again
	lda.w #$0001
	rtl
.sr:								;Stats Report
	lda.b d1
	bit.w #cbut
	bne .sr1
	jmp.w .gj
.sr1:								; stats report, then redraw
	jsl.l StatsReport
	jsl.l SetHor_rink
	bra .redraw
.ros:								;SNES Team Roster: show the roster, then rebuild the game screen (bg
									;registers, palette, small font tiles, SetHor)
	lda.b d1
	bit.w #cbut
	bne .ros1
	jmp.w .gj
.ros1:								; team roster, then restore the screen
	jsl.l TeamRosterScreen
	jsl.l sndqreset					; reset the sound queue
	jsl.l forceblack				; blank the screen
	sep #$20						; 8-bit A
	lda.b #$00
	sta.w BG1SC
	lda.b #$05
	sta.w BG2SC
	lda.b #$12
	sta.w BG12NBA
	lda.b #TM_BG1|TM_BG2|TM_OBJ
	sta.w TM
	stz.w CGADD
	ldx.w #$0000
.pal:								; restore the palette from the buffer
	lda.l palbuffer,x
	sta.w CGDATA
	inx
	cpx.w #$0080
	bne .pal
	rep #$30						; 16-bit registers
	lda.w #$FF00
	sta.w charofs
	stz.w charofs+2
	lda.w smallfontchars
	asl a
	asl a
	asl a
	asl a
	adc.w #$1000
	sta.w VMADDL
	lda.w #SmallFontTiles
	sta.b tmp0
	lda.w #SmallFontTiles>>16
	sta.b tmp1
	jsl.l DecompressBytecode
	stz.b a0
	lda.w #unpackbuf>>16
	sta.b a0+2
	lda.w #PixelRemap83
	sta.b a1
	lda.w #PixelRemap83>>16
	sta.b a1+2
	lda.w #$0064
	sta.b d0
	jsl.l remap						;remap the 4bpp pixels of the unpacked tiles ([a0] data, [a1] table, d0
									;tiles)
	lda.w #FramerTiles
	sta.b a0
	lda.w #FramerTiles>>16
	sta.b a0+2
	lda.w #PixelRemap87
	sta.b a1
	lda.w #PixelRemap87>>16
	sta.b a1+2
	lda.w #$0004
	sta.b d0
	jsl.l remap						;remap the 4bpp pixels of the unpacked tiles ([a0] data, [a1] table, d0
									;tiles)
	lda.b sprclock
	adc.w #$003C
	sta.b sprclock
	lda.w #$FFFF
	sta.b textdirtylo
	stz.b textdirtyhi
	jsl.l SetHor					; switch to the horizontal rink
	jsl.l setvideo					; update the video
	jmp.w .redraw
.go:								;Goalie: left/right change tmgoalie (0, 1, none), then Setpersonel
	jsl.l seta2
	jsl.l GetGoalieCount
	jsl.l seta2
	ldy.b a2						; A or right: next goalie; left: previous; d0 = number of goalies
	lda.b d1
	bit.w #cbut|rbut
	bne .nextg
	bit.w #lbut
	bne .prevg
	jmp.w .gj
.prevg:								; previous goalie
	lda.w tmgoalie,y
	bmi .lastg
.dec:								; step the goalie index down
	dec a
.set:								; store the new goalie and update the players on the ice
	sta.w tmgoalie,y
	jsl.l setpersonel				; update the players on the ice
	jmp.w .gj
.lastg:								; wrap to the last goalie
	lda.b d0
	bra .dec
.nextg:								; next goalie
	lda.w tmgoalie,y
	bmi .firstg
	inc a
	cmp.b d0
	bcc .set
	lda.w #$FFFF
	bra .set
.firstg:							; wrap to the first goalie
	lda.w #$0000
	bra .set
.jump:								;Resume Game, Instant Replay, Stats Report, Goalie, Team Roster
	dd PauseResume,.rm,.sr,.go,.ros
