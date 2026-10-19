GameOver:							;After a game: the password and the playoff screen; on to the user's next
									;playoff game, or back to the start
	jsl.l EncodePW					; save the password
	jsl.l PlayoffScreen				; font tile bases, the playoff tree
	lda.w OptPlayMode				; not continuing playoffs, or no user game: Opening2
	cmp.w #$0001
	beq .po							; continuing the playoffs: .po
	jml.l Opening2					; else back to the start
.po:
	lda.w gamenum					; user game number
	bpl .pw							; none left: back to the start
	jml.l Opening2
.pw:
	lda.w PassWord					; clear bit 7 (hidden) of the first two characters
	and.w #$7F7F
	sta.w PassWord
	jsl.l DecodePW					; decode the password
	jsl.l maketree					; build the playoff tree
	lda.w #sf3alttree				; sf3alttree: Opening4 after the font bases
	trb.w sflags3
	beq .tree						; no alternative tree
	jml.l Opening3					; alternative tree
.tree:								; far branch to Opening4
	jml.l Opening4
