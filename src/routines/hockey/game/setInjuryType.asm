setInjuryType:						;Player a2 is injured for the period: the crowd reacts, the view locks on
									;him and the injury box gets his name
	ldy.b a2
	lda.w pflags,y
	ora.w #pf2unav
	sta.w pflags,y					; the player is unavailable
	lda.b crowdlevel
	clc
	adc.w #$012C
	sta.b crowdlevel				; the crowd gets louder
	lda.w #SFXoooh2
	pha
	jsl.l sfx						; play the groan
	ldy.b a2
	lda.w Xpos,y
	sta.w xc1						; view target x = the player's x
	lda.w Ypos,y
	sta.w yc1						; view target y = the player's y
	lda.w #$0040
	tsb.w sflags					; set sflags bit $40
	stz.b d1						; d1 = team flag, home 0
	stz.b a0						; a0 = team offset, home 0
	lda.w pfteam,y
	beq .home						; home team: skip
	lda.w #$8000
	sta.b d1						; away team flag $8000
	lda.w #$0002
	sta.b a0						; away team offset 2
.home:
	lda.w pnum,y					; player number
	and.w #$00FF
	ora.b d1						; plus the team flag
	sta.w TempPlOffset				; remember who it is
	and.w #$00FF
	bit.w #$0080
	beq .pos
	ora.w #$FF00					; sign extend the player number
.pos:
	asl a							; times 2
	sta.b d1
	lda.b a0
	beq .tmofs						; home team: no extra offset
	lda.w #$0034					; away team offset $34
.tmofs:								; index the injury table
	adc.b d1
	tay								; Y = index into the table
	lda.w #$FFFD
	sta.w tmpdst,y					; mark this entry $FFFD
	rtl
