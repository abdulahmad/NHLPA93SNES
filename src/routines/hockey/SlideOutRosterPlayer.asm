SlideOutRosterPlayer:				;The player shown for team a2 skates off
	jsl.l ClearRosterName
	ldy.b a2
	lda.w tmflags,y
	ora.w #tmfmid
	sta.w tmflags,y
.rtl:
	rtl
