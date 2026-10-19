SetupNextPlayer:					;The next player of team a2 to show in the team block, with an
									;animation picked from his ratings
	jsl.l setplayercolors_palbuffer	; set the player palette for the block
	ldy.b a2
	lda.w tmflags,y					; clear the mid-animation flag
	and.w #~tmfmid&$FFFF
	sta.w tmflags,y
	lda.w tmsort,y					; sort slot of this team
	sta.b a3
	tax
	lda.w #-40						; park the sprite off screen
	sta.w OldXpos,x
	stz.w SPA,x						; stop its animation
.order:								; roster order index
	ldy.b a2
	lda.w tmPwrGoals,y				; index into the roster order
	sta.b d0
	tay
	lda.w #RosterOrderTable			; RosterOrderTable[tmPwrGoals]: $FF restarts the list
	sta.b a0
	lda.w #RosterOrderTable>>16
	sta.b a0+2
	lda.b [a0],y					; next slot from the order table
	and.w #$00FF
	sta.b d0
	bit.w #$0080					; $80 = end of the list
	beq .got
	ldy.b a2
	lda.w #$0000					; wrap to the first slot
	sta.w tmPwrGoals,y
	bra .order
.got:								; remember the slot
	ldy.b a2
	lda.b d0
	sta.w tmPenalties,y				; remember the slot
	lda.w tmPwrGoals,y
	inc a
	sta.w tmPwrGoals,y				; advance the order index
	lda.w #TeamList>>16
	sta.b a0+2
	lda.w tmdata,y					; roster player = LineSets byte - 1 (goalie slot: tmgoalie)
	sta.b a0
	clc
	ldy.w #LineSets					; LineSets of this team
	adc.b [a0],y
	sta.b a0
	ldy.b d0						; slot within the line set
	lda.b [a0],y
	and.w #$00FF
	dec a
	sta.b d0
	ldy.b a2
	lda.w tmPenalties,y
	bne .pl							; slot 0 is the goalie
	lda.w tmgoalie,y
	sta.b d0
.pl:								; store the player
	lda.b d0
	ldy.b a2
	sta.w tmPwrPlays,y
	jsl.l GetRosterEntry			; find the roster entry
	lda.b a0
	clc
	adc.b [a0]
	sta.b a0						; move to the player data
	lda.w attribute,x				; handedness bit: flip
	and.w #~attrxflip&$FFFF
	sta.w attribute,x
	ldy.w #Playerdata+4
	lda.b [a0],y
	lsr a
	bcs .rate
	lda.w attribute,x
	ora.w #attrxflip
	sta.w attribute,x
.rate:								;PickRosterAnim for each of the 14 rating nibbles (SkaterRosterAnims,
									;goalies GoalieRosterAnims)
	inc.b a0
	lda.w #$0006					; 7 bytes, 14 nibbles
	sta.b d0
	stz.b d2
	lda.w #SkaterRosterAnims		; skater animation table
	sta.b a1
	lda.w #SkaterRosterAnims>>16
	sta.b a1+2
	ldy.b a2
	lda.w tmPenalties,y
	and.w #$0007
	sta.b d3
	bne .nib
	lda.w #GoalieRosterAnims		; goalie animation table
	sta.b a1
.nib:
	lda.b [a0]						; high nibble first
	and.w #$00FF
	lsr a
	lsr a
	lsr a
	lsr a
	sta.b d1
	jsl.l PickRosterAnim			; pick the animation
	lda.b [a0]
	inc.b a0
	and.w #$000F
	sta.b d1
	jsl.l PickRosterAnim			; then the low nibble
	dec.b d0						; next byte
	bpl .nib
	ldy.b a2
	lda.w #$0000
	sta.w tmATOP,y
	rtl
