clockcont:							;When the clock runs out, freeze the view and end the period
	lda.w gmclock					; main clock
	ora.w gameclock					; or the game clock
	bne .rtl						; still running: leave
	jsl.l freezewindow				; lock the view
	jmp.w clockcont_0				; end the period
.rtl:
	rtl
