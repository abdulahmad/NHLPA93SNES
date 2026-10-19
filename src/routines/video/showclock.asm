showclock:							;Draw the game clock (not during a replay)
	lda.w sflags					; no clock during a replay
	bit.w #sf2replay				; sf2replay
	beq .nosf2replay
	jmp.w .rtl
.nosf2replay:
	lda.w #$0007					; clock text: 7 characters
	sta.w mesarea					; mesarea = length 7
	lda.w #$0020					; space
	sta.w mesarea+2					; first character defaults to a blank (leading zero)
	lda.w gameclock					; game clock in seconds
	sta.b mulb
	lda.w #600						; 600 s = ten minutes
	sta.b mula
	jsl.l divu16					; quotient = tens of minutes, remainder in mulres+2
	beq .notens						; zero: keep the blank
	adc.w #$0030					; ASCII digit
	sta.w mesarea+2
.notens:
	lda.w #60						; 60 s
	sta.b mula
	lda.b mulres+2					; remainder seconds
	sta.b mulb
	jsl.l divu16					; quotient = minutes ones
	adc.w #$0030
	sta.w mesarea+3					; minutes ones digit
	lda.w #':'						; colon
	sta.w mesarea+4
	lda.w #10						; 10 s
	sta.b mula
	lda.b mulres+2
	sta.b mulb
	jsl.l divu16					; quotient = seconds tens
	adc.w #$0030
	sta.w mesarea+5					; seconds tens digit
	lda.b mulres+2					; remainder = seconds ones
	adc.w #$0030
	sta.w mesarea+6					; seconds ones digit
	lda.w #$2000
	sta.w printa					; palette and priority for the text
	lda.w #$0003
	sta.w printx					; x = 3
	lda.w #$0018
	sta.w printy					; y = $18
	lda.w sfhormode
	beq .nosfhormode				; horizontal rink mode: the clock moves
	lda.w #$000D
	sta.w printx					; x = $D
	lda.w #$0004
	sta.w printy					; y = 4
	lda.w gsp
	cmp.w #$0004					; no clock when gsp = 4 (game over)
	beq .rtl
.nosfhormode:
	lda.w #mesarea					; a1 = the clock text
	sta.b a1
	lda.w #mesarea>>16
	sta.b a1+2
	jml.l print						; print it and return
.rtl:								; return
	rtl
