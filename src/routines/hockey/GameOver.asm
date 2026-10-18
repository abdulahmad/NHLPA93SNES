GameOver:							;After a game: the password and the playoff screen; on to the user's next
									;playoff game, or back to the start
	jsl.l EncodePW
	jsl.l PlayoffScreen				; font tile bases, the playoff tree
	lda.w OptPlayMode				; not continuing playoffs, or no user game: Opening2
	cmp.w #$0001
	beq .po
	jml.l Opening2
.po:
	lda.w gamenum
	bpl .pw
	jml.l Opening2
.pw:
	lda.w PassWord					; clear bit 7 (hidden) of the first two characters
	and.w #$7F7F
	sta.w PassWord
	jsl.l DecodePW
	jsl.l maketree
	lda.w #sf3alttree				; sf3alttree: Opening4 after the font bases
	trb.w sflags3
	beq .tree
	jml.l Opening3
.tree:
	jml.l Opening4
