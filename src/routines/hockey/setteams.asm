setteams:							;Set up both team structures from the home and visiting teams
	stz.w tmsort					; home: tmsort 0, away: tmsort $0C
	lda.w #$000C
	sta.w tmsort+2
	lda.w HomeTeam					; home team number
	sta.w tmteam
	asl a							; times 4: long pointer index
	asl a
	tax
	lda.l TeamList,x				; team data pointer
	sta.w tmdata
	lda.w VisTeam					; visiting team
	sta.w tmteam+2
	asl a
	asl a
	tax
	lda.l TeamList,x				; its data pointer
	sta.w tmdata+2
	rtl
