EncodePW:							;After a playoff game, work out the winners and the new password, or new
									;playoffs when the user's team won or went out
	lda.w OptPlayMode				; play mode
	bne .po							; playoffs
	jmp.w .rtl						; regular season: nothing to do
.po:
	lda.w #$0001					; continue the playoffs
	sta.w OptPlayMode
	jsl.l ResolveGames				; work out the winners
	jsl.l maketree					; build the tree
	lda.w gamelevel					; finished playoffs
	cmp.w #$0004					; round 4 is over
	beq .userwon					; the user won
	lda.w gamenum					; gamenum >= 0: player 1 won
	bpl .nofail						; user won this game
	lda.w pojoy						; pojoy < 2: one player or teammates
	sec
	sbc.w #$0002
	bmi .neg						; one player or two on one team
	bvc .two
	bra .userfailed					; failed
.neg:
	bvc .userfailed					; failed
.two:								;two players, first round: switch to the other team
	lda.w gamelevel					; first round
	cmp.w #$0001
	bne .userfailed					; no: failed
	lda.w potreeteam				; other team
	eor.w #$0001
	sta.w potreeteam
	lda.w pojoy
	eor.w #$0001
	sta.w pojoy						; swap the joystick too
.nofail:
	jsl.l WritePassBits				; password bits
	jsl.l BitstoPW					; to characters
	lda.w sflags3					; sf3alttree: passbits before all games were resolved
	bit.w #sf3alttree
	beq .tree						; normal tree
	ldy.w #$000E					; 8 words
.cp:
	lda.w tpassbits,y
	sta.w passbits,y
	dey
	dey
	bpl .cp
	jsl.l ReadPassBits				; read the bits back
.tree:
	jml.l maketree					; build the tree
.userwon:
	jsl.l ResetPassWord				; reset the password
.userfailed:
	lda.w #$0080					; PassWord bit 7: no password
	tsb.w PassWord					; set the bit
	lda.w #$0002
	sta.w OptPlayMode				; play mode 2
	lda.b bosgames
	cmp.w #$0007					; single games
	beq .rtl						; keep it
	lda.w #$0003
	sta.w OptPlayMode				; else 3
.rtl:
	rtl
