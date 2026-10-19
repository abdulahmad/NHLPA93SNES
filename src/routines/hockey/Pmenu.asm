Pmenu:								;Draw the pause menu items with the current one highlighted
	jsl.l printz					; print the string that follows
	%StringCp(CC_Font1Pri,$06,$0D)
	stz.b d0
	lda.w #.mlist
	sta.b a0
	lda.w #.mlist>>16
	sta.b a0+2
	lda.w gsp
	cmp.w #$0004
	bne .item
	lda.w #.mlist2
	sta.b a0
.item:
	lda.w #$2400
	sta.w printa
	lda.b d0
	cmp.w psitem
	bne .nohilite
	lda.w #$2000
	sta.w printa
.nohilite:
	lda.w #$0006
	sta.w printx
	jsl.l printz					; print the string that follows
	%String("                    ")
	lda.w #mesarea
	sta.b a1
	lda.w #mesarea>>16
	sta.b a1+2
	ldy.w #$001E
.copy:
	lda.b [a0],y
	sta.b [a1],y
	dey
	dey
	bpl .copy
	jsl.l .goalie
	lda.b [a1]
	lsr a
	eor.w #$FFFF					; negate
	inc a
	clc
	adc.w #$0011
	sta.w printx
	jsl.l print						; print it
	inc.w printy
	lda.b a0
	clc
	adc.b [a0]
	sta.b a0
	inc.b d0
	lda.b d0
	cmp.w #$0005
	bne .item
	rtl
.goalie:							;item 3: append the name of the goalie on the ice (or NONE)
	lda.b d0
	cmp.w #$0003
	beq .item3
	jmp.w .rtl
.item3:
	jsl.l seta2
	ldy.b a2
	lda.w tmgoalie,y
	bmi .none
	sta.b tmp0
	lda.w tmdata,y
	sta.b a4
	lda.w #TeamList>>16
	sta.b a4+2
	ldy.w #Playerdata
	lda.b [a4],y
	clc
	adc.b a4
	sta.b a4
.findpl:
	dec.b tmp0
	bmi .gotpl
	lda.b [a4]
	clc
	adc.b a4
	adc.w #$0008
	sta.b a4
	bra .findpl
.gotpl:
	ldy.w #$0001
.findspace:
	iny
	lda.b [a4],y
	and.w #$00FF
	cmp.w #$0020
	bne .findspace
.copyname:
	iny
	tya
	cmp.b [a4]
	beq .rtl
	lda.b [a4],y
	phy
	ldy.w mesarea
	sta.w mesarea,y
	inc.w mesarea
	ply
	bra .copyname
.rtl:
	rtl
.none:
	ldy.w mesarea
	lda.w #$004E
	sta.w mesarea,y
	lda.w #$004F
	sta.w mesarea+1,y
	lda.w #$004E
	sta.w mesarea+2,y
	lda.w #$0045
	sta.w mesarea+3,y
	inc.w mesarea
	inc.w mesarea
	inc.w mesarea
	inc.w mesarea
	rtl
.mlist:								;the pause menu items
	%String("Resume Game")
	%String("Instant Replay")
	%String("Stats Report")
	%String("Goalie - ")
	%String("Team Roster")
.mlist2:							;the menu items after the game (Exit Game first)
	%String("Exit Game")
	%String("Instant Replay")
	%String("Stats Report")
	%String("Goalie - ")
	%String("Team Roster")
