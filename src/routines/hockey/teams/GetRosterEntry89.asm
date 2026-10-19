GetRosterEntry89:					;Bank $89 copy of GetRosterEntry (called from getname and
									;FormatPlayerNumInitial): a0 = the roster record of player d0 of team a2
	lda.w #TeamList>>16				; team list bank
	sta.b a0+2
	ldy.b a2
	lda.w tmdata,y					; team data pointer
	sta.b a0
	ldy.w #Playerdata
	clc								; offset of the player data
	adc.b [a0]
	sta.b a0						; a0 = start of the player data
	bra .cnt						; count down
.next:								; add the record length
	lda.b a0
	clc
	adc.b [a0]						; plus the record length
	adc.w #$0008					; plus 8
	sta.b a0
.cnt:								; d0 entries to skip
	dec.b d0						; until record d0
	bpl .next
	rtl
