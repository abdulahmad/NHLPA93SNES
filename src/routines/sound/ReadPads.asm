ReadPads:							;Once per frame, read the four pads: buttons held, new presses and last
									;buttons
	lda.b vcount					; once per frame
	cmp.w padvcount					; already read
	beq .new						; yes
	sta.w padvcount					; remember it
	lda.w #$0001
.wait:								;auto-joypad read busy
	bit.w HVBJOY					; still reading
	bne .wait
	lda.w JOY1L						; pad 1
	sta.w joypad1
	lda.w JOY2L						; pad 2
	sta.w joypad2
	lda.w JOY3L						; pad 3
	sta.w joypad3
	lda.w JOY4L						; pad 4
	sta.w joypad4
.new:								; new presses = changed and down
	lda.w joypad1					; new presses = changed and down
	eor.w padlast1					; last pad state
	and.w joypad1					; down
	sta.w padnew1					; new presses
	lda.w joypad2
	eor.w padlast1+2
	and.w joypad2
	sta.w padnew1+2
	lda.w joypad3
	eor.w padlast1+4
	and.w joypad3
	sta.w padnew1+4
	lda.w joypad4
	eor.w padlast1+6
	and.w joypad4
	sta.w padnew1+6
	lda.w joypad1					; remember the pads
	sta.w padlast1
	lda.w joypad2
	sta.w padlast1+2
	lda.w joypad3
	sta.w padlast1+4
	lda.w joypad4
	sta.w padlast1+6
	rtl								; done
