DefaultMenus:						;Set the default menu choices at power on
	lda.w #$FFFF					; not a demo
	sta.w notdemo
	lda.w #OptPlayMode				; options start
	sta.b a0
	lda.w #$0000
	sta.b a0+2
	lda.w #.tab						; default table
	sta.b a1
	lda.w #.tab>>16
	sta.b a1+2
	lda.w #$0006					; 7 words
	sta.b d0
.copy:								; copy a word of the menu defaults
	lda.b [a1]						; copy a word
	inc.b a1
	inc.b a1
	sta.b [a0]
	inc.b a0
	inc.b a0
	dec.b d0						; count down
	bpl .copy
	rtl
.tab:								;OptPlayMode, OptNOP, Opt1team, Opt2team, Optperlen, OptPen, OptLine
	dw $0000,$0001,$000F,$0003,$0001,$0000,$0001
