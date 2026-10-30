StartHL2:							;Play the highlight of playoff game a0 with its score; Start or A ends it,
									;and a tie gets a random winner
	lda.w sflags3					; Start pressed before: no more highlights
	bit.w #sf3sbut
	beq .go
	jmp.w .nhl0
.go:								; save the game state
	jsl.l .sv						; save the game state
	lda.b d1
	sta.b d3
	jsl.l NewTicker3				; the score of the highlight game, bank $8F
	lda.w sflags3
	bit.w #sf3sbut
	beq .show
	jmp.w .nhl1
.show:								; Framer 24 x 3
	lda.w #$0004					; Framer 24 x 3
	sta.w printx
	lda.w printy
	sec
	sbc.w #$0006
	sta.w printy
	lda.w #24
	sta.b d0
	lda.w #3
	sta.b d1
	jsl.l Framer					; d0 x d1
	inc.w printx
	dec.w printy
	dec.w printy
	jsl.l printz					; print the string that follows
	%String("Highlight from game:")
	lda.w #180						; 180 frames, Start skips
	sta.b d0
	jsl.l waitxsr					; wait d0 frames or a button
	lda.b d1
	bit.w #sbut
	beq .play
	jmp.w .nhl1
.play:								; blank the screen and reset the sound queue
	jsl.l forceblack				; blank the screen
	jsl.l sndqreset					; reset the sound queue
	lda.w sndbank
	cmp.w #SoundBankGame
	beq .snd
	jsl.l SPCGameUpload
.snd:								; HomeTeam/VisTeam of game a0
	ldy.b a0						; HomeTeam/VisTeam of game a0
	lda.w gst1,y
	sta.w HomeTeam
	lda.w gst2,y
	sta.w VisTeam
	stx.b xsave						; keep X
	ldx.w #$0000
.pushg:								; save a0 and the words after it (2 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0004
	bne .pushg
	ldx.b xsave						; restore X
	jsl.l clearTeamStats
	jsl.l restoreteams				; restore the teams
	stz.b a2
	jsl.l reenergizeteam
	lda.w #$0002
	sta.b a2
	jsl.l reenergizeteam
	lda.w #$FFFF
	sta.w c1playernum
	sta.w c2playernum
	stz.w cont1team
	stz.w cont2team
	lda.w #120						; gameclock = 120 + random 120
	jsl.l randoma					; random number 0 to A-1
	adc.w #120
	sta.w gameclock
	stx.b xsave						; keep X
	ldx.w #$0002
.popg:								; pull a0 and the words after it back
	pla
	sta.b a0,x
	dex
	dex
	bpl .popg
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0000
.pushg2:							; save a0 and the words after it (2 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0004
	bne .pushg2
	ldx.b xsave						; restore X
	ldy.b a0						; gsp, scores from the game
	lda.w gsper,y
	dec a
	sta.w gsp
	lda.w gss1,y
	sta.w tmscore
	lda.w gss2,y
	sta.w tmscore+2
	lda.w #gmhl						; gmode = gmhl
	sta.w gmode
	stz.w gmclock
	lda.w gsp						; odd period: gmdir
	lsr a
	bcc .ndi
	lda.w #gmdir
	tsb.w gmode
.ndi:								; not a demo: reset flags
	stz.w sflags3
	lda.w #sf2drec					; sflags = sf2drec
	sta.w sflags
	stz.w sfhormode
	stz.w glovecords
	stz.w iflags
	lda.w #$FFFF					; RefCnt, puckcross times -1
	sta.w RefCnt
	sta.w puckcross+pcframes
	sta.w puckcross+pcsize+pcframes
	jsl.l setupice
	jsl.l ClrHor					; back to the vertical rink
	stz.w Vpos
	stz.w Hpos
	jsl.l ResetBench
	stz.b a2
	jsl.l .setteam
	lda.w #$0002
	sta.b a2
	jsl.l .setteam
	jsl.l resetplstuff
	lda.w #11						; 12 players to their .postab spots
	sta.b d0
	lda.w #.postab
	sta.b a0
	lda.w #.postab>>16
	sta.b a0+2
	stz.b a1
.ploop:								; loop over the players
	ldx.b a1
	lda.w position,x
	sta.b d1
	lda.w pfgoal,x
	bne .pl0
	lda.b d1
	clc
	adc.w #6
	sta.b d1
.pl0:								; index the player table
	asl.b d1
	asl.b d1
	ldy.b d1
	lda.b [a0],y
	sta.w Xpos,x
	iny
	iny
	lda.b [a0],y
	sta.w Ypos,x
	stz.w Xvel,x
	stz.w Yvel,x
	inc.b a1
	inc.b a1
	dec.b d0
	bpl .ploop
	jsl.l SprSort					; sort the sprites
	lda.w #180						; 180 frames after the clock stops
	pha
	lda.b Vcount
	sta.w OldVcount
.0:									;wait for the next frame
	lda.b Vcount					; the frame time steps as the game loop
	cmp.w OldVcount
	beq .0
	tax
	sec
	sbc.w OldVcount
	sta.b d7
	asl a
	sta.b impactstep
	asl a
	asl a
	asl a
	sta.b velstep
	asl a
	sta.b gravstep
	asl a
	adc.b gravstep
	sta.b gravstep
	lda.b velstep
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a
	sta.b d7x1024
	stx.w lastframevc
	stx.w OldVcount
	jsl.l ReadPads					; read the pads
	lda.w sflags
	bit.w #sfpz
	bne .frame
	lda.w gmclock
	bne .frame
	ldx.b d7
.clk:								; run the clock
	lda.w gameclock					; run the clock
	beq .clk1
	lda.w gameclock+2
	sec
	sbc.w #$0AAA
	sta.w gameclock+2
	bcs .clk1
	dec.w gameclock
.clk1:								; clock countdown done
	dex
	bne .clk
.frame:								; run one game frame
	lda.b d7
	pha
	jsl.l DoGameFrame
	pla
	sta.b d7
	lda.w gmclock
	beq .1
	pla
	sec
	sbc.b d7
	pha
	bmi .endhl
.1:									; check both pads: Start or A ends it
	jsl.l Readjoy12					; Start or A ends it
	lda.b d1
	bit.w #sbut|JOYA
	beq .0
	lda.w tmscore					; tied: random goal
	cmp.w tmscore+2
	bne .endhl
	jsl.l random					; random number
	and.w #$0002
	tax
	inc.w tmscore,x
.endhl:								; end of the highlight: restore
	pla
	stx.b xsave						; keep X
	ldx.w #$0002
.popg2:								; pull a0 and the words after it back
	pla
	sta.b a0,x
	dex
	dex
	bpl .popg2
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0000
.pushd1:							; save d1 and the words after it (2 words)
	lda.b d1,x
	pha
	inx
	inx
	cpx.w #$0004
	bne .pushd1
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0000
.pusha0:							; save a0 and the words after it (2 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$0004
	bne .pusha0
	ldx.b xsave						; restore X
	jsl.l KillCrowd
	jsl.l sndqreset					; reset the sound queue
	stx.b xsave						; keep X
	ldx.w #$0002
.popa0:								; pull a0 and the words after it back
	pla
	sta.b a0,x
	dex
	dex
	bpl .popa0
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0002
.popd1:								; pull d1 and the words after it back
	pla
	sta.b d1,x
	dex
	dex
	bpl .popd1
	ldx.b xsave						; restore X
	ldy.b a0						; back into the game record
	lda.w tmscore
	sta.w gss1,y
	lda.w tmscore+2
	sta.w gss2,y
	lda.b d1						; Start: skip
	bit.w #sbut
	beq .stats
	jmp.w .nhl1
.stats:								; blank the screen, restore the game state
	jsl.l forceblack				; blank the screen
	jsl.l .lo						; restore the game state
	jsl.l setplayercolors
	jsl.l SetHor					; switch to the horizontal rink
	jsl.l setvideo					; update the video
	jsl.l printz					; DisplayStats box
	%StringCp(CC_Font1Pri,$05,$0C)
	lda.w #22
	sta.b d0
	lda.w #7
	sta.b d1
	jsl.l Framer					; d0 x d1
	jsl.l printscores1				; redraw the scores
	jsl.l Pmenu						; DisplayStats
	stx.b xsave						; keep X
	ldx.w #$001A
.resta:								; pull a0 and the words after it back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$001E
.restore:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore
	ldx.b xsave						; restore X
	ldx.b a3
	stx.b xsave						; keep X
	ldx.w #$0000
.save:								; save d0 and the words after it (16 words)
	lda.b d0,x
	pha
	inx
	inx
	cpx.w #$0020
	bne .save
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$0000
.savea:								; save a0 and the words after it (14 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$001C
	bne .savea
	ldx.b xsave						; restore X
	ldy.b a0
	lda.w #4						; gsper 4: tied after the highlight: again
	sta.w gsper,y
	lda.w gss1,y
	cmp.w gss2,y
	bne .won
	jmp.w StartHL2
.won:								; gsper 5: final
	lda.w #5						; gsper 5: final
	sta.w gsper,y
	lda.b d1
	sta.b d3
	jsl.l NewTicker3
	lda.w #180
	sta.b d0
	jsl.l waitxsr					; wait d0 frames or a button
	lda.b d1
	bit.w #sbut
	beq .exit
.exit2:								; exit with the button flag set
	lda.w #sf3sbut
	tsb.w sflags3
.exit:								; restore and return
	stx.b xsave						; keep X
	ldx.w #$001A
.resta2:							; pull a0 and the words after it back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta2
	ldx.b xsave						; restore X
	stx.b xsave						; keep X
	ldx.w #$001E
.restore2:							; pull d0 and the words after it back
	pla
	sta.b d0,x
	dex
	dex
	bpl .restore2
	ldx.b xsave						; restore X
	ldx.b a3
	rtl
.nhl1:								; NHL highlight 1: load, then randomize results
	jsl.l .lo
	jsl.l .ranres
	bra .exit2
.nhl0:								; NHL highlight 0: randomize results
	jsl.l .ranres
	bra .exit
.setteam:							;team a2 for the highlight: energy, setpersonel, forcepldata, no
									;last touches
	jsl.l reenergizeteam
	jsl.l setpersonel				; update the players on the ice
	jsl.l forcepldata
	ldy.b a2
	lda.w #$FFFF
	sta.w tmtouch1,y
	sta.w tmtouch2,y
	sta.w tmtouch3,y
	rtl
.ranres:							;a tie gets a random one-goal winner; gsper 5 (final)
	ldy.b a0
	lda.w gss1,y
	cmp.w gss2,y
	bne .rr0
	lda.w #2
	jsl.l randoma					; random number 0 to A-1
	ldy.b a0
	pha
	clc
	adc.w gss1,y
	sta.w gss1,y
	pla
	eor.w #$0001
	adc.w gss2,y
	sta.w gss2,y
.rr0:								; set the period to 5
	lda.w #5
	sta.w gsper,y
	rtl
.sv:								;save the game state (gmode-1 .. ScoreSumbytes) to hlsavebuf
	ldx.w #$0000
.sv1:								; save the game mode to the highlight buffer
	lda.w gmode-1,x
	sta.l hlsavebuf,x
	inx
	inx
	cpx.w #$02F7
	bcc .sv1
	lda.w ScoreSumbytes
	sta.l hlsavebuf,x
	inx
	inx
	stz.w tmgoalie
	stz.w tmgoalie+2
	rtl
.lo:								;restore the game state from hlsavebuf
	ldx.w #$0000
.lo1:								; restore the game mode from the highlight buffer
	lda.l hlsavebuf,x
	sta.w gmode-1,x
	inx
	inx
	cpx.w #$02F7
	bcc .lo1
	lda.l hlsavebuf,x
	inx
	inx
	sta.w ScoreSumbytes
	rtl
.postab:							;x, y start spot by position (0-5 attacking up, 6-11 down)
	dw 0,-240
	dw -70,-140
	dw 20,-110
	dw -100,-60
	dw 25,-40
	dw 70,-80
	dw 0,240
	dw 34,90
	dw -55,80
	dw 100,40
	dw -10,10
	dw -50,0
