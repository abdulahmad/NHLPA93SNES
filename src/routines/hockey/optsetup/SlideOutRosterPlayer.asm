SlideOutRosterPlayer:				;The player shown for team a2 skates off
	jsl.l ClearRosterName			; erase the name
	ldy.b a2
	lda.w tmflags,y
	ora.w #tmfslide					; team slides out
	sta.w tmflags,y
.rtl:								; return
	rtl
