puckfaceoff2:						;Assignment: the face off and the setup for play
	lda.w pflags,x					; new assignment?
	bit.w #pfna
	bne .first
	jmp.w .nna
.first:								;first time: set up the faceoff
	and.w #~pfna&$FFFF
	sta.w pflags,x
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
	lda.b Crowdlevel				; limit crowd level
	cmp.w #$0258
	bcc .ntm
	lda.w #$0258
	sta.b Crowdlevel
.ntm:								; stop clock
	lda.w #sfpz						;no pause, no lower lc box, no gloves, no icing, no refs, no goalie moves,
									;puck invisible and loose
	trb.w sflags
	lda.w #sf3llcs
	trb.w sflags3
	stz.w glovecords				; no icing, no lower lc box, glove spots cleared
	stz.w iflags
	lda.w #$FFFF					; -1 marks the ref count, crossings, puck carrier and receiver as none
	sta.w RefCnt
	sta.w puckcross+pcframes
	sta.w puckcross+pcsize+pcframes
	sta.w Zpos+puckobj
	sta.w puckc
	sta.w passReceiverPlayerNum
	lda.w #sf2refref				; clear sf2refref; faceoff on, replay record off
	trb.w sflags
	lda.w #sf2faceoff|sf2drec
	tsb.w sflags
	jsl.l ClrHor					; back to the vertical rink
	stz.w Vpos						; Vpos = Hpos = 0
	stz.w Hpos
	lda.w fox						; puck to the faceoff spot, stopped
	sta.w puckx
	lda.w foy
	sta.w pucky
	stz.w puckvx
	stz.w puckvy
	stz.w puckvz
	stz.w Xvel+netobj1				; goal nets (objects 12/13) at y +-268
	stz.w Yvel+netobj1
	stz.w Xpos+netobj1
	lda.w #$010C
	sta.w Ypos+netobj1
	stz.w Xvel+netobj2				; goal net 2 at y -268
	stz.w Yvel+netobj2
	stz.w Xpos+netobj2
	lda.w #$FEF4
	sta.w Ypos+netobj2
	lda.w #SPFpuck					; object 15 (puck shadow) = SPFpuck
	sta.w frame+puckobj+2
	stz.w SPA+puckobj+2
	stz.w attribute+puckobj+2
	stz.w attribute+puckobj
	lda.w #sfslock					; clear sfslock: free up scrolling
	trb.w sflags
	lda.w #$0064					; 100 scroll steps
	sta.b d4
.cw:								;scroll to the faceoff spot
	jsl.l checkwindow
	dec.b d4
	bpl .cw
	lda.w #$003C					; yleader = 60
	sta.w yleader
	jsl.l ResetBench				; ResetBench
	stz.b a2
	jsl.l setpersonel				; update the players on the ice
	jsl.l forcepldata
	inc.b a2
	inc.b a2
	jsl.l setpersonel				; update the players on the ice
	jsl.l forcepldata
	jsl.l resetplstuff				; resetplstuff
	lda.b a3+2						; push a3
	pha
	lda.b a3
	pha
	stz.b a3
	lda.w #$000B					; 12 objects
	sta.b d2
.l0:								;each player: assignment and faceoff position
	ldx.b a3
	lda.w #$FF10					; Xpos = -240, off the screen
	sta.w Xpos,x
	stz.w Ypos,x
	stz.w frame,x
	lda.w position,x
	sta.b d1						; d1 = position
	bpl .pos
	jmp.w .next
.pos:								; position test: goalies are placed separately
	beq .goalie1
	lda.w #afaceoff					; forwards and defense get the faceoff assignment
	sta.b d0
	lda.b d1						; centers take the faceoff
	cmp.w #$0004
	bne .l1
	stz.b a2						; center: team touches = him only
	lda.w pfteam,x
	beq .tm
	inc.b a2
	inc.b a2
.tm:								; team of this player
	ldy.b a2
	lda.w pnum,x
	and.w #$00FF
	sta.w tmtouch1,y
	lda.w #$FFFF
	sta.w tmtouch2,y
	sta.w tmtouch3,y
	lda.w tmflags,y
	and.w #~tmflast&$FFFF
	sta.w tmflags,y
	lda.w #afaceoffpl				; afaceoffpl
	sta.b d0
.l1:								; give the player his face off assignment
	jsl.l assinsert					; insert assignment d0
.goalie1:							; d4 = active players of this player's team
	lda.w tmap						; d4 = (6-tmap)*8: .apl row
	sta.b d4
	ldx.b a3
	lda.w pfteam,x
	beq .t0
	lda.w tmap+2
	sta.b d4
.t0:								; row = (6 - tmap) * 8 in the .apl table
	lda.b d4
	eor.w #$FFFF					; negate
	inc a
	clc
	adc.w #$0006
	asl a
	asl a
	asl a
	sta.b d4
	lda.w #.apl>>16					; .apl row address
	sta.b a1+2
	lda.w #.apl
	clc
	adc.b d4
	sta.b a1
	ldy.b d1
	lda.b [a1],y					; table entry for the position
	and.w #$00FF
	asl a							; entry to a .ptab offset
	asl a
	sta.b d4
	lda.w #.ptab
	sta.b a1
	lda.w #.ptab>>16
	sta.b a1+2
	ldy.b d4
	lda.b [a1],y					; X and Y offsets of the position
	sta.b d0
	iny
	iny
	lda.b [a1],y
	sta.b d1
	lda.w pfgoal,x					; mirror for the top goal
	bne .f0
	lda.b d0
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	lda.b d1
	eor.w #$FFFF					; negate
	inc a
	sta.b d1
.f0:								; goalie or skater?
	lda.w position,x
	beq .goalie2
	lda.b d4						; defense (entry <= 2*4): shift by fox/foy
	sec
	sbc.w #$0008
	beq .def
	bmi .neg
	bvs .def
	bra .nodef
.neg:								; signed compare: overflow flag corrects the sign
	bvs .nodef
.def:								; defender: mirror by the faceoff spot
	lda.w fox						; defender on the other side of the center line
	eor.b d0
	bpl .notmid
	lda.w foy
	lsr a
	lsr a
	lsr a
	bit.w #$1000
	beq .mid
	ora.w #$E000
.mid:								; negate
	eor.w #$FFFF					; negate
	inc a
	clc
	adc.b d1
	sta.b d1
.notmid:							; not on the center line: scaled spot offset
	lda.w fox						; fox / 4 as the X offset
	lsr a
	lsr a
	bit.w #$2000
	beq .xadj
	ora.w #$C000
.xadj:								; apply the X adjustment
	sta.b d3
	lda.b d0
	sec
	sbc.b d3
	sta.b d0
.nodef:								; forwards: add the faceoff spot X
	lda.b d0						; add the faceoff spot
	clc
	adc.w fox
	sta.b d0
	lda.b d1
	clc
	adc.w foy
	sta.b d1
.goalie2:							; set the position and face the puck
	lda.b d0						; store X
	sta.w Xpos,x
	sec
	sbc.w puckx
	eor.w #$FFFF					; negate
	inc a
	sta.b d0
	lda.b d1						; store Y
	sta.w Ypos,x
	sec
	sbc.w pucky
	eor.w #$FFFF					; negate
	inc a
	sta.b d1
	stz.w Xvel,x					; stand still
	stz.w Yvel,x
	jsl.l vtoa						; face the puck
	lda.b d0
	sta.w facedir,x
	lda.w pflags,x
	and.w #~pf2unav&$FFFF			; clear pf2unav, pfalock, SPA
	sta.w pflags,x
	stz.w pfalock,x
	stz.w SPA,x
	lda.w #SPAglide
	sta.b d1
	jsl.l SetSPA					; start animation d1
.next:								; next player
	inc.b a3
	inc.b a3
	dec.b d2
	bmi .done
	jmp.w .l0
.done:								; sort the sprites
	jsl.l SprSort					; SprSort
	pla
	sta.b a3
	pla
	sta.b a3+2
	ldx.b a3
	jsl.l ResetAndSelectPlayers		; reset the controllers and select players
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1Pri,$00,$00)
	lda.w #$0036					; 8+46
	sta.b d0
	lda.w fox						; puck on the right: drop spot on the right
	bpl .fok
	lda.w #$00BE					; (18*8)+46
	sta.b d0
.fok:								; store the puck drop spot X
	lda.b d0
	sta.w fodropx
	sec
	sbc.w #$002E
	lsr a
	lsr a
	lsr a
	sta.w printx
	lda.w #$005C					; (3*8)+68
	sta.w fodropy
	lda.w #$0003
	sta.w printy
	lda.w printy					; box row offset
	asl a
	asl a
	asl a
	asl a
	asl a
	adc.w printx
	jsl.l marktextlo				; mark the box rows dirty
	lda.w printy
	clc
	adc.w #$0009
	asl a
	asl a
	asl a
	asl a
	asl a
	adc.w printx
	adc.w #$000B
	jsl.l marktexthi
	lda.w #FaceOffMap				; fobox nonzero
	sta.b fobox
	sta.b tmp0
	lda.w #FaceOffMap>>16
	sta.b tmp1
	lda.w printy
	asl a
	asl a
	asl a
	asl a
	asl a
	adc.w printx
	asl a
	tax
	ldy.w #$0000					; start of the map
	lda.w #$000A					; 10 rows
	sta.b tmp1+1
	clc
.row:								;copy the 12x10 FaceOffMap into the text map
	lda.w #$000C					; 12 columns
	sta.b tmp2+1
.col:								; copy the faceoff map columns with the tile set added
	lda.b [tmp0],y
	clc
	adc.w faceoffvrcset
	adc.w charofs
	sta.l textmap,x
	iny
	iny
	inx
	inx
	dec.b tmp2+1
	bne .col
	txa								; next text row
	clc
	adc.w #$0028
	tax
	dec.b tmp1+1
	bne .row
	ldx.b a3
	lda.w OptLine					; line changes on: line names box
	bne .nol
	lda.w printy
	clc
	adc.w #$000A
	sta.w printy
	lda.w #$000C
	sta.b d0
	lda.w #$0003
	sta.b d1
	jsl.l Framer					; d0/d1 size
	lda.w tmline					; line numbers of the two teams
	sta.b d0
	lda.w tmline+2
	sta.b d1
	lda.w gmode						; gmdir
	bit.w #gmdir
	bne .nx
	lda.w tmline					; swap the teams if the home team is below
	sta.b d1
	lda.w tmline+2
	sta.b d0
.nx:								; next print position
	inc.w printx
	dec.w printy
	dec.w printy
	lda.w #linelist					; linelist
	sta.b a1
	lda.w #linelist>>16
	sta.b a1+2
	jsl.l Fprint
	inc.w printx
	inc.w printx
	inc.w printx
	inc.w printx
	lda.b d1						; then the visitor line name
	sta.b d0
	lda.w #linelist
	sta.b a1
	lda.w #linelist>>16
	sta.b a1+2
	jsl.l Fprint
.nol:								;time for the puck drop: 180-299 frames
	lda.w #$0078					; random puck drop time
	jsl.l randoma					; random number 0 to A-1
	adc.w #$00B4
	sta.b d0
	ldx.b a3						; temp1 = frames to the drop
	sta.w temp1,x
	lda.w #$0001					; fofdata2: home pull frame 1, away 4, ref 7
	sta.w fofdata2
	lda.w #$8000
	sta.w fofdata2+foattr
	sta.w fofdata+foattr
	lda.w #$0004
	sta.w fofdata2+fosize
	lda.w #$A800
	sta.w fofdata2+fosize+foattr
	lda.w #$0007
	sta.w fofdata
	lda.w gmode
	bit.w #gmdir					; gmdir: flip the attributes
	bne .nfl
	lda.w #$8800
	sta.w fofdata2+foattr
	lda.w #$A000
	sta.w fofdata2+fosize+foattr
.nfl:								; no pull directions yet
	lda.w #$FFFF					; fodir1/fodir2 = none
	sta.w fodir1
	sta.w fodir2
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
	rtl
.nna:								;count down to the drop; then Endfaceoff
	lda.b d7						; temp1 -= min(d7, temp1)
	sta.b tmp0
	sec
	sbc.w temp1,x
	bmi .neg1
	bvc .one
	bra .sub
.neg1:								; signed compare: overflow flag corrects the sign
	bvc .sub
.one:								; decrement by one
	lda.w #$0001
	sta.b tmp0
.sub:								; subtract from the timer
	lda.w temp1,x
	sec
	sbc.b tmp0
	sta.w temp1,x
	bpl updatefaceoff
	jmp.w Endfaceoff
.apl:								;.ptab entry for each position, by players on ice (6, 5, 4)
	db 0,1,2,3,4,5,6,0				; 6 on ice
	db 0,1,5,3,4,2,0,0				; 5 on ice
	db 0,3,5,1,4,0,0,0				; 4 on ice
.ptab:								;faceoff x/y offsets
	dw 0,-250, -35,-50, 35,-50, -50,-10
	dw 0,-15, 50,-10, 0,-60
