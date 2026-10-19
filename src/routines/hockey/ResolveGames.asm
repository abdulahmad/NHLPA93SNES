ResolveGames:						;Record the played playoff game and the series wins; when the round is
									;over, move on to the next round
	lda.w gamenum					; game number of the played game
	asl a
	sta.b d0
	stz.b a0						; copy the score of the played game
	tay
	lda.w tmscore					; home score
	sta.w gss1,y
	lda.w tmscore+2					; visitor score
	sta.w gss2,y
	jsl.l GetShifter				; d1 = games - 1
	lda.b d1						; number of series in the round - 1
	asl a
	sta.b a0
	lda.b bosgames					; best of seven round?
	cmp.w #7						; 7 games per series
	bne .b0
	jmp.w .notbos
.b0:
	ldy.b a0						; series index
	lda.w #4						; 4 wins decide a series
	cmp.w gspotwins,y				; series already decided?
	beq .b1
	cmp.w gspobwins,y
	beq .b1
	stz.b d3						; d3 = 0
	lda.w gsflags,y					; gsflags bit 0 (gsftf): teams swapped
	bit.w #gsftf
	beq .nf
	lda.w #$0010					; teams swapped: d3 = $10
	sta.b d3
.nf:
	lda.w gss1,y					; compare the scores
	cmp.w gss2,y
	bpl .ns1
	lda.b d3
	eor.w #$0010					; flip the side of the win
	sta.b d3
.ns1:
	lda.b a0						; series offset plus side
	clc
	adc.b d3
	tax
	inc.w gspotwins,x				; count the series win
.b1:
	dec.b a0						; next series
	dec.b a0
	dec.b d1
	bpl .b0
	inc.b bosgames					; next game of the series
	lda.b bosgames
	cmp.w #7						; series finished?
	bne .more
	jmp.w .nextround
.more:
	lda.w gamenum					; current game
	asl a
	sta.b a0
	tay
	lda.w #4						; 4 wins?
	cmp.w gspotwins,y
	beq .cround
	cmp.w gspobwins,y
	beq .cround
	jmp.w .rtl						; series still open: done
.cround:							;finish the other series of the round
	lda.w gamelevel					; round level
	sec
	sbc.w #3						; before level 3?
	bmi .lvlneg
	bvs .cr
	bra .nextround
.lvlneg:							; signed compare: overflow flag corrects the sign
	bvs .nextround
.cr:
	jsl.l GetShifter				; d1 = games - 1
	lda.b d1
	asl a
	sta.b a0
.cr0:
	ldy.b a0						; series loop
	lda.b d1
	cmp.w gamenum					; skip the played series
	beq .crn
	lda.w #4
	cmp.w gspotwins,y
	beq .crn
	cmp.w gspobwins,y
	beq .crn
	lda.w gspotwins,y				; play it out at random
	inc a
	sta.w gspotwins,y
	lda.w #200						; random series result: 50/50 per game
	jsl.l randoma					; random number 0 to A-1
	lsr a
	bcc .cr0
	lda.w gspotwins,y
	dec a
	sta.w gspotwins,y
	lda.w gspobwins,y				; count the loss for the other side
	inc a
	sta.w gspobwins,y
	bra .cr0
.crn:								; next series
	dec.b a0
	dec.b a0
	dec.b d1
	bpl .cr0
	jsl.l WritePassBits				; sf3alttree: passbits before the rest was resolved
	ldy.w #$000E					; 8 words of passbits
.cp:
	lda.w passbits,y
	sta.w tpassbits,y
	dey
	dey
	bpl .cp
	lda.w #sf3alttree				; alternate tree flag
	tsb.w sflags3
.nextround:
	stz.b bosgames					; reset the game counter
	jsl.l GetShifter				; d1 = games - 1
	lda.b d1
	asl a
	sta.b a0
	stz.b d3
.nr0:
	ldy.b a0
	lda.w gspotwins,y				; series won by the first team?
	cmp.w #$0004
	beq .nr1
	lda.b d1
	asl a
	tax
	lda.l BitMaskTable,x			; mark the winning series
	tsb.b d3
.nr1:
	lda.w #$0000					; clear the win counts
	sta.w gspotwins,y
	sta.w gspobwins,y
	dec.b a0
	dec.b a0
	dec.b d1
	bpl .nr0
	lda.b d2						; WinBits: the winners of level d2
	asl a
	tax
	lda.l BitMaskTable,x
	sta.b mula						; mask of the level
	dec a							; mask - 1
	and.w WinBits
	sta.w WinBits					; clear the old bits
	lda.b d3						; new winners
	sta.b mulb
	jsl.l mulu16					; 16-bit multiply
	tsb.w WinBits					; merge the new winners
	inc.w gamelevel					; next round level
.rtl:								; return
	rtl
.notbos:							;single games
	stz.b d3
.s0:
	ldy.b a0
	lda.w gss2,y					; visitor score
	cmp.w gss1,y
	bcc .s1							; home score higher or equal?
	lda.b d1
	asl a
	tax
	lda.l BitMaskTable,x			; mark the series
	tsb.b d3
.s1:
	lda.w gsflags,y					; teams swapped?
	bit.w #gsftf
	beq .s2
	lda.b d1
	asl a
	tax
	lda.l BitMaskTable,x
	eor.b d3						; invert the winner bit
	sta.b d3
.s2:
	dec.b a0
	dec.b a0
	dec.b d1
	bpl .s0
	lda.b d2						; WinBits of this level
	asl a
	tax
	lda.l BitMaskTable,x
	sta.b mula						; mask of the level
	dec a
	and.w WinBits
	sta.w WinBits					; clear the old bits
	lda.b d3
	sta.b mulb						; new winners
	jsl.l mulu16					; 16-bit multiply
	tsb.w WinBits					; merge the new winners
	inc.w gamelevel					; next round level
	rtl
