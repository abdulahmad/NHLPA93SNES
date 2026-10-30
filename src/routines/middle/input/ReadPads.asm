ReadPads:							;Once per frame, read the four pads: buttons held, new presses and last
									;buttons
	lda.b Vcount					; once per frame
	cmp.w padvcount					; already read
	beq .new						; yes
	sta.w padvcount					; remember it
	lda.w #$0001
.wait:								;auto-joypad read busy
	bit.w HVBJOY					; still reading
	bne .wait
	lda.w JOY1L						; pad 1
	sta.w PadRaw1
	lda.w JOY2L						; pad 2
	sta.w PadRaw2
	lda.w JOY3L						; pad 3
	sta.w PadRaw3
	lda.w JOY4L						; pad 4
	sta.w PadRaw4
.new:								; new presses = changed and down
	lda.w PadRaw1					; new presses = changed and down
	eor.w padlast1					; last pad state
	and.w PadRaw1					; down
	sta.w padnew1					; new presses
	lda.w PadRaw2
	eor.w padlast1+2
	and.w PadRaw2
	sta.w padnew1+2
	lda.w PadRaw3
	eor.w padlast1+4
	and.w PadRaw3
	sta.w padnew1+4
	lda.w PadRaw4
	eor.w padlast1+6
	and.w PadRaw4
	sta.w padnew1+6
	lda.w PadRaw1					; remember the pads
	sta.w padlast1
	lda.w PadRaw2
	sta.w padlast1+2
	lda.w PadRaw3
	sta.w padlast1+4
	lda.w PadRaw4
	sta.w padlast1+6
	rtl								; done
