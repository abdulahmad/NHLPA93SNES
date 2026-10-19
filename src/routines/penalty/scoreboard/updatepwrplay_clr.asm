updatepwrplay_clr:					;Power play over: put the EASN logo back
	lda.w #sf2pwrplay
	trb.w sflags					; clear the power play flag
	beq .rtl						; it was not set: nothing to do
	jml.l EASNLogo					; show the logo again
.rtl:								; return
	rtl
