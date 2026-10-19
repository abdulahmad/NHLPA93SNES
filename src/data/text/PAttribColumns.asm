PAttribColumns:						;player attribute menu (ShowGoalBox): 15-byte item strings, the
									;rating bit mask and column, $FFFF ends
	%String("   Status   ]")
	dw $0000,$0000					; bit mask, rating column
	%String("[  Overall  ]")
	dw $1F3A,$000A					; bit mask, rating column
	%String("[  Energy   ]")
	dw $0000,$0002					; bit mask, rating column
	%String("[  Agility  ]")
	dw $1000,$000A					; bit mask, rating column
	%String("[   Speed   ]")
	dw $0800,$000A					; bit mask, rating column
	%String("[  Handed   ]")
	dw $0040,$0004					; bit mask, rating column
	%String("[Off. Aware.]")
	dw $0400,$000A					; bit mask, rating column
	%String("[Def. Aware.]")
	dw $0200,$000A					; bit mask, rating column
	%String("[Shot Power ]")
	dw $0100,$000A					; bit mask, rating column
	%String("[Shot  Accur]")
	dw $0010,$000A					; bit mask, rating column
	%String("[Pass  Accur]")
	dw $0002,$000A					; bit mask, rating column
	%String("[Stick Handl]")
	dw $0020,$000A					; bit mask, rating column
	%String("[  Weight   ]")
	dw $2000,$0006					; bit mask, rating column
	%String("[ Endurance ]")
	dw $0008,$000A					; bit mask, rating column
	%String("[Aggression ]")
	dw $0001,$000A					; bit mask, rating column
	%String("[ Checking  ]")
	dw $0080,$000A					; bit mask, rating column
	%String("[  Fighting  ")
	dw $0040,$0008					; bit mask, rating column
	dw $FFFF						; end
