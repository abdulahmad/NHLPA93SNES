UpdateScoutingDisplay:				;Every frame of the scouting report: print the next word of the commentary
									;when its timer runs out,
									;filling in team and goalie names
	lda.w ScoutingReportTimer		; text finished ($7FFF)
	sec
	sbc.w #$1000					; $1000 and above: text finished
	beq .tm
	bmi .neg
	bvs .tm
	bra .rtl
.neg:								; signed compare: overflow flag corrects the sign
	bvs .rtl
.tm:								; count the screen delay down
	lda.w asv						; asv: no delay
	bmi .go
	dec.w ScoutingReportTimer		; count the timer down
	bpl .rtl
.go:								; time to print: a1 = text base
	lda.w #ScoutingReportText		; commentary text
	sta.b a1
	lda.w #ScoutingReportText>>16
	sta.b a1+2
	lda.w PlayerScrollCtr			; position in the text, -1: next paragraph
	sta.b d0
	bpl .cont
	stz.w DispAttribCtr				;next paragraph number from TestList; -1: stop typing, leave the screen in
									;480 frames
	ldy.w SelectedPlayerIdx			; paragraph number index
	inc.w SelectedPlayerIdx
	inc.w SelectedPlayerIdx
	lda.w #$0000
	sta.b a0
	lda.w #TestList>>16
	sta.b a0+2
	lda.b [a0],y					; next paragraph number
	sta.b d0
	bpl .para						; negative: end of the commentary
	lda.w #$7FFF					; stop typing
	sta.w ScoutingReportTimer
	lda.w #$01E0					; leave the screen after 480 frames
	sta.w screentimer
.rtl:								; return
	rtl
.para:								;blank line between paragraphs
	jsl.l ScrollDisplayUp			; blank line between paragraphs
	lda.b a1
	sta.b a2
	lda.b a1+2
	sta.b a2+2
	bra .cnt
.find:								; find the next line of the text
	lda.b [a2]
	inc.b a2
	and.w #$00FF
	cmp.w #$000D					; end of line?
	bne .find
.cnt:								; skip d0 paragraphs
	dec.b d0						; paragraph lines left
	bpl .find
	lda.b a2						; text offset of the paragraph
	sec
	sbc.b a1
	sta.b d0
.cont:								; a2 = next word to print
	lda.b a1						; text base plus offset
	clc
	adc.b d0
	sta.b a2
	lda.b a1+2
	sta.b a2+2
	lda.w #$000A					; 10 frames per word
	sta.w ScoutingReportTimer
	lda.w DispAttribCtr				; column
	sta.b d0
	lda.b [a2]
	and.w #$00FF
	cmp.w #'~'						; ~: home team
	bne .c2
	jmp.w .under
.c2:								; { is the home team name
	cmp.w #'{'						; {: home team name
	bne .c3
	jmp.w .home
.c3:								; } is the away team name
	cmp.w #'}'						; }: away team name
	bne .c4
	jmp.w .away
.c4:								; [ is the home goalie
	cmp.w #'['						; [: home goalie
	bne .c5
	jmp.w .hmtm
.c5:								; ] is the away goalie
	cmp.w #']'						; ]: away goalie
	bne .word
	jmp.w .awtm
.word:								;copy the word and its trailing spaces to mesarea+2
	lda.w #$FFFF					; word position valid
	sta.w PlayerScrollCtr
	lda.w #mesarea+2				; name buffer
	sta.b a0
	lda.w #$0000
	sta.b a0+2
	stz.b d1						; word length
.wd:								; find the end of the word
	lda.b [a2]
	and.w #$00FF
	cmp.w #$000D					; end of line?
	beq .eol
	inc.b d0						; count the column
.copy:								; copy the word and its trailing spaces
	sep #$20						; 8-bit A
	lda.b [a2]
	sta.b [a0]						; copy a character
	rep #$30						; 16-bit registers
	inc.b a0
	inc.b d1						; next buffer position
	lda.b [a2]
	and.w #$00FF
	cmp.w #','						; comma?
	beq .pause
	cmp.w #'.'						; period?
	bne .nopause
.pause:								;40 more frames after punctuation
	lda.w ScoutingReportTimer
	clc
	adc.w #$0028
	sta.w ScoutingReportTimer
.nopause:							; stop the word at a space
	lda.b [a2]						; next character
	inc.b a2
	and.w #$00FF
	cmp.w #' '						; space?
	bne .wd
	lda.b [a2]
	and.w #$00FF
	cmp.w #' '						; trailing spaces too
	beq .copy
	dec.b d0						; back one column
	lda.b a2
	sec
	sbc.b a1
	sta.b a2
	sta.w PlayerScrollCtr			; remember the position
.eol:								;make a String at mesarea
	lda.b d1						; length
	inc a
	inc a
	sta.w mesarea					; buffer length
	lda.w #mesarea
	sta.b a1
	lda.w #$0000
	sta.b a1+2
.print:								;past column 20: ScrollDisplayUp
	lda.b d0
	sec
	sbc.w #$0014					; 20 columns
	beq .noscr
	bmi .neg1
	bvs .noscr
.scr:								; scroll the text box up
	jsl.l ScrollDisplayUp			; scroll up
	bra .noscr
.neg1:								; signed compare: overflow flag corrects the sign
	bvs .scr
.noscr:								; position the word: x 9 + column, y 4 + line
	jsl.l printz					; print at column + DispAttribCtr, line + VertLineScrolling
	%StringCp(CC_Font1,$0A,$04)
	lda.w DispAttribCtr				; column
	clc
	adc.w printx
	sta.w printx
	lda.w VertLineScrolling			; line scroll
	clc
	adc.w printy
	sta.w printy
	jsl.l print						; print it
	lda.w DispAttribCtr				; advance the column
	clc
	adc.b d1
	sta.w DispAttribCtr
	rtl
.awtm:								;away goalie
	lda.w #$0002					; away goalie, team 2
	sta.b a1
	bra .team
.hmtm:								;home goalie
	stz.b a1						; home goalie, team 1
.team:								; goalie of the selected team
	ldy.b a1
	lda.w tmgoalie,y				; his player number
	sta.b d1
	lda.w tmdata,y					; team data
	sta.b a1
	lda.w #TeamList>>16
	sta.b a1+2
	ldy.w #Playerdata				; player data offset
	lda.b a1
	clc
	adc.b [a1],y
	sta.b a1
	bra .pn
.pl:								; next player
	lda.b a1
	clc
	adc.b [a1]						; skip the player
	adc.w #$0008					; plus the fixed part
	sta.b a1
.pn:								; count down to the player
	dec.b d1
	bpl .pl
	bra .name
.away:								;away team name
	lda.w tmdata+2					; team data
	sta.b a1
	lda.w #TeamList>>16
	sta.b a1+2
	bra .tname
.under:								;~: the home team (Montreal for the All-Star teams)
	lda.w #TeamList>>16
	sta.b a1+2
	lda.w tmdata
	cmp.w #AllStarsEast
	beq .mtl
	cmp.w #AllStarsWest
	bne .ar
.mtl:								; Montreal for the All-Star teams
	lda.w #Montreal					; Montreal for the All-Star teams
.ar:								; store the team
	sta.b a1
	bra .tname
.home:								;home team name
	lda.w tmdata
	sta.b a1
	lda.w #TeamList>>16
	sta.b a1+2
.tname:								; team name
	ldy.w #Teamname					; team name offset
	lda.b a1
	clc
	adc.b [a1],y
	sta.b a1
.name:								; step past the escape char
	inc.w PlayerScrollCtr			; next character position
	lda.b d0
	clc
	adc.b [a1]						; plus the name length
	dec a
	sta.b d0
	lda.b [a1]
	dec a
	tay
	dec a
	sta.b d1
	lda.b [a1],y
	and.w #$00FF
	beq .pad						; trailing zero?
	jmp.w .print
.pad:								; drop the trailing zero
	dec.b d1						; drop it
	jmp.w .print
