NewTicker3:							;Show the ticker box for game d3: round, period and both teams with their
									;scores
	lda.b d3						; d3 = game number
	asl a							; times 2: word offset
	sta.b a0						; a0 = offset into the game tables
	tay
	lda.w gsflags,y					; game flags
	bit.w #$0006					; flag bits $0006 set: NewTicker2 draws the box
	bne NewTicker2
	jsl.l printz					; print the position code that follows
	%StringCp(CC_Font1Pri,$02,$17)
	lda.w sflags					; pause screen flag
	bit.w #sfpz
	bne .pj							; pause screen: one position code is enough
	jsl.l printz
	%StringCp(CC_Font1Pri,$02,$17)	; print the position code again
.pj:
	lda.w sfhormode					; horizontal rink mode
	bne .frame						; use the position as is
	lda.w printy
	sec
	sbc.w #$0005
	sta.w printy					; print y - 5
.frame:
	lda.w #$001C					; frame width $1C
	sta.b d0
	lda.w #$0005					; frame height 5
	sta.b d1
	jsl.l Framer					; draw the frame
	lda.b vcount					; ticker clock = frame counter
	sta.w tickervc
	inc.w printx					; x + 1
	lda.w printy
	sec
	sbc.w #$0004
	sta.w printy					; print y - 4
	lda.w printx
	pha								; keep x on the stack
	jsl.l GetShifter				; set up the shifter for this game
	lda.w #$2400
	sta.w printa					; palette for the text
	jsl.l printz					; print a blank
	%String("                          ")
	lda.b $01,s						; x from the stack
	sta.w printx
	lda.b d3
	clc
	adc.b d2
	sta.b d0						; d0 = label number (game + d2)
	lda.w #GameLabels
	sta.b a1
	lda.w #GameLabels>>16
	sta.b a1+2
	jsl.l Fprint_list				; print the game label
	lda.b $01,s
	clc
	adc.w #$0015
	sta.w printx					; x + $15
	ldy.b a0
	lda.w gsper,y					; period of this game
	dec a							; minus 1: label index
	sta.b d0
	lda.w #PerLabels
	sta.b a1
	lda.w #PerLabels>>16
	sta.b a1+2
	jsl.l Fprint_list				; print the period label
	lda.w #$2000
	sta.w printa					; score palette
	ldy.b a0
	lda.w gst1,y					; first team
	sta.b d0
	lda.w gss1,y					; its score
	sta.b d1
	jsl.l PrintGameInfo				; print team and score
	ldy.b a0
	lda.w gst2,y					; second team
	sta.b d0
	lda.w gss2,y					; its score
	sta.b d1
	jsl.l PrintGameInfo				; print team and score
	pla								; drop the saved x
	rtl
