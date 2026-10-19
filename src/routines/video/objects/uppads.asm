uppads:								;Update the gloves object and the pad objects, and queue new pad labels
	ldy.w #$0008					; gloves (ffo 4): hidden unless glovecords
	lda.w #$FFFF					; hidden by default
	sta.w ffoz,y
	lda.w glovecords				; glove coordinates, x byte
	and.w #$00FF
	beq .nogloves					; none: leave hidden
	and.w #$00FF
	bit.w #$0080
	beq .gx
	ora.w #$FF00					; sign extend x
.gx:								; spot X
	asl a
	asl a
	sta.w ffox,y					; x times 4
	lda.w glovecords+1				; y byte
	and.w #$00FF
	bit.w #$0080
	beq .gy
	ora.w #$FF00					; sign extend y
.gy:								; spot Y
	asl a
	asl a
	sta.w ffoy,y					; y times 4
	lda.w #$0000
	sta.w ffoz,y					; visible
.nogloves:							; 4 pads (92 3); d4 = pads left-1
	lda.w #$0003					; 4 pads: a0 = ffo index, a1 = padcont, d3 = PadControlBits
	sta.b d4
	stz.b a0
	lda.w #padcont					; pad control table
	sta.b a1
	lda.w #$0000
	sta.b a1+2
	stz.b a2
	lda.w PadControlBits			; four nibbles, one per pad
	sta.b d3
.top:								; each pad nibble
	lda.b d3
	and.w #$000F					; nibble of this pad
	sta.b d0
	lda.w #$000F					; label code for $E
	sta.b d1
	lda.b d0
	cmp.w #$000E
	beq .chg						; $E: keep the label unchanged
	ldy.b a0						; hidden
	lda.w #$FFFF
	sta.w ffoz,y					; hide the pad
	lda.b d0
	cmp.w #$000F
	beq .next						; $F: no player, stay hidden
	asl.b d0						; pad at the player
	ldy.b d0						; player index
	lda.w Xpos,y
	ldy.b a0
	sta.w ffox,y					; pad x = player x
	ldy.b d0
	lda.w Ypos,y
	ldy.b a0
	sta.w ffoy,y					; pad y = player y
	lda.w #$0000
	sta.w ffoz,y					; show it
	ldy.b d0
	lda.w position,y				; position of the player
	xba
	and.w #$FF00
	sta.b d1
	lda.w rostnum,y					; roster number of the player
	and.w #$00FF
	tsb.b d1
.chg:								; store the label code
	lda.b d1
	sta.b [a1]						; store the label code
.next:								; next pad
	lda.b d3						; next nibble
	lsr a
	lsr a
	lsr a
	lsr a
	sta.b d3
	inc.b a0						; next ffo object
	inc.b a0
	inc.b a1						; next padcont word
	inc.b a1
	dec.b d4						; 4 pads
	bpl .top
	rtl
