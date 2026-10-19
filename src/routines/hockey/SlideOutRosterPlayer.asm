SlideOutRosterPlayer:				;The player shown for team a2 skates off
	jsl.l ClearRosterName			; erase the name
	ldy.b a2
	lda.w tmflags,y
	ora.w #tmfmid					; team slides out (tmfmid)
	sta.w tmflags,y
.rtl:								; return
	rtl
