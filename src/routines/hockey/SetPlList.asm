SetPlList:							;Make the list of the players team a2 wants on the ice now
	lda.w #PlList					; player list of the team
	sta.b a4
	lda.w #PlList>>16
	sta.b a4+2
	lda.w #$0000					; clear the list
	sta.b [a4]						; three words
	ldy.w #$0002					; second word
	sta.b [a4],y
	ldy.w #$0004					; third word
	sta.b [a4],y
	lda.w #priolist					; priolist
	sta.b a0
	lda.w #priolist>>16
	sta.b a0+2
	ldy.b a2
	lda.w tmgoalie,y				; goalie
	bpl .gin						; no goalie: skip the priolist goalie entry
	inc.b a0						; skip the goalie entry
.gin:
	lda.w tmdata,y					; line sets: team data + word at +6, + tmline*8
	sta.b a1
	lda.w #TeamList>>16
	sta.b a1+2
	ldy.w #LineSets					; line sets offset
	lda.b [a1],y					; line sets of the team
	clc
	adc.b a1
	sta.b a1
	ldy.b a2
	lda.w tmline,y					; current line
	asl a							; times 8
	asl a
	asl a
	sta.b d0
	adc.b a1						; plus the line offset
	sta.b a1
	lda.w tmap,y					; tmap: players on ice
	sta.b d4						; slots to fill
	bra .next
.0:									; slot loop
	ldy.b d4
	lda.b [a0],y					; priority entry
	and.w #$00FF
	sta.b d5						; keep the slot index
	tay
	sep #$20						; 8-bit A
	lda.b [a1],y					; roster number from the line
	ldy.b d4
	sta.b [a4],y					; store it in the list
	iny
	iny
	iny
	iny
	iny
	iny
	lda.b d5
	sta.b [a4],y					; and the slot index
	rep #$20						; 16-bit A
	lda.b d5
	bne .next						; slot 0 is the goalie
	ldy.b a2						; goalie: 1 + tmgoalie
	lda.w tmgoalie,y				; team goalie
	inc a
	sta.b d3
	ldy.b d4						; slot
	sep #$20						; 8-bit A
	lda.b d3
	sta.b [a4],y					; store it
	rep #$20						; 16-bit A
.next:
	dec.b d4						; next slot
	bpl .0
	lda.w #$0005					; 6 slots
	sta.b d4
.1:									;is each wanted player available?
	ldy.b d4
	lda.b [a4],y					; list entry
	and.w #$00FF
	sta.b d3						; player number
	beq .next1						; empty slot: next
	and.w #$00FF
	bit.w #$0080
	beq .p
	ora.w #$FF00
.p:									; sign extend
	dec a							; player index
	asl a
	sta.b d3
	lda.b a2
	beq .idx						; first team?
	lda.w #$0034					; second team offset
.idx:								; index the player
	clc
	adc.b d3						; plus the player index
	tay
	lda.w tmpdst,y					; player state
	cmp.w #TMPDOUT					; TMPDOUT: substitute
	beq .sub
	lda.w tmpdst,y
	bmi .next1						; bench or ice: ok
	beq .next1						; ok
.sub:								;not available: find a player of a similar position (sublist)
	ldy.b a2
	lda.w tmdata,y					; team data
	sta.b a1
	lda.w #TeamList>>16
	sta.b a1+2
	ldy.w #LineSets					; line sets offset
	lda.b [a1],y					; line sets of the team
	clc
	adc.b a1
	sta.b a1
	lda.b d4						; slot
	clc
	adc.w #$0006					; entry offset
	tay
	lda.b [a4],y					; wanted position
	and.w #$00FF
	asl a
	sta.b d0
	lda.w #sublist					; sublist (word offsets)
	sta.b a0
	lda.w #sublist>>16
	sta.b a0+2
	ldy.b d0
	lda.b [a0],y					; offset of the list
	clc
	adc.b a0
	sta.b a0
.s1:
	lda.b [a0]						; next candidate position
	inc.b a0
	and.w #$00FF
	sta.b d0
	bit.w #$0080					; $80: try everyone
	bne .all
	ldy.b d0						; roster index
	lda.b [a1],y					; player from the line sets
	and.w #$00FF
	sta.b d0
	jsl.l TryAddPlayerToList		; try to add him
	beq .s1							; failed: next candidate
.next1:
	dec.b d4						; next slot
	bmi .rtl						; all done
	jmp.w .1
.rtl:								; return
	rtl
.all:								;try every roster player, last first
	jsl.l GetPlayerCount			; GetPlayerCount
	lda.b d0						; player count
	sta.b d3
.try:								; try the previous slot
	lda.b d3
	sta.b d0
	dec.b d3
	bmi .next1
	jsl.l TryAddPlayerToList		; try to add him
	beq .try
	bra .next1
