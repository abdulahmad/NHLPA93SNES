PAttribColumns:						;skater attribute columns for the Team Roster screen (TeamRosterScreen).
									;A String header, then two words for GetNameandAttrib: the mask of
									;rating nibbles to average and the attribjmp offset (0 status, 2 energy,
									;4 handed, 6 weight, 8 fighting, $A rating). A negative word ends the list
	%String("   Status   ]")
	dw $0000,$0000					;status
	%String("[  Overall  ]")
	dw $1F3A,$000A					;rating
	%String("[  Energy   ]")
	dw $0000,$0002					;energy
	%String("[  Agility  ]")
	dw $1000,$000A
	%String("[   Speed   ]")
	dw $0800,$000A
	%String("[  Handed   ]")
	dw $0040,$0004					;handed
	%String("[Off. Aware.]")
	dw $0400,$000A
	%String("[Def. Aware.]")
	dw $0200,$000A
	%String("[Shot Power ]")
	dw $0100,$000A
	%String("[Shot  Accur]")
	dw $0010,$000A
	%String("[Pass  Accur]")
	dw $0002,$000A
	%String("[Stick Handl]")
	dw $0020,$000A
	%String("[  Weight   ]")
	dw $2000,$0006					;weight
	%String("[ Endurance ]")
	dw $0008,$000A
	%String("[Aggression ]")
	dw $0001,$000A
	%String("[ Checking  ]")
	dw $0080,$000A
	%String("[  Fighting  ")
	dw $0040,$0008					;fighting
	dw $FFFF						; end
