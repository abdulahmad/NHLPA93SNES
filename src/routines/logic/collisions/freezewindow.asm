freezewindow:						;Lock the view at its current position
	lda.w Vpos						; yc1 = Vpos, xc1 = Hpos, sfslock
	sta.w yc1						; view lock y
	lda.w Hpos
	sta.w xc1						; view lock x
	lda.w #sfslock
	tsb.w sflags					; set the lock flag
	rtl
