GAttribColumns:						;goalie attribute menu
	%String("   Status   ]")
	dw $0000,$0000					; bit mask, rating column
	%String("[  Overall  ]")
	dw $1B0F,$000A					; bit mask, rating column
	%String("[  Agility  ]")
	dw $1000,$000A					; bit mask, rating column
	%String("[   Speed   ]")
	dw $0800,$000A					; bit mask, rating column
	%String("[Glove Hand ]")
	dw $0040,$0004					; bit mask, rating column
	%String("[Def. Aware.]")
	dw $0200,$000A					; bit mask, rating column
	%String("[Puck Cont. ]")
	dw $0100,$000A					; bit mask, rating column
	%String("[Stick Right]")
	dw $0008,$000A					; bit mask, rating column
	%String("[Stick Left ]")
	dw $0004,$000A					; bit mask, rating column
	%String("[Glove Right]")
	dw $0002,$000A					; bit mask, rating column
	%String("[Glove Left ]")
	dw $0001,$000A					; bit mask, rating column
	%String("[   Weight   ")
	dw $2000,$0006					; bit mask, rating column
	dw $FFFF						; end
