setsortcords:						;Draw the sorted objects in display order, hiding ones that are off screen
	lda.w #OOlist					; a4 = OOlist
	sta.b a4						; a4 = list
.top:								; next object number from OOlist
	lda.b (a4)						; object
	and.w #$00FF					; byte
	tax								; X = object
	lda.w Zpos,x					; z
	bmi .next						; none: skip
	sta.b d2
	lda.w Xpos,x					; x
	sta.b d0
	lda.w Ypos,x					; y
	sta.b d1
	jsl.l find3d					; 3d to screen position
	cmp.w #OFFSCREEN				; off the screen
	beq .next						; skip it
	sta.b spry						; screen y
	lda.b d0
	sta.b sprx						; screen x
	lda.w frame,x					; oldframe = frame
	sta.w oldframe,x
	sta.b sprframe					; frame
	lda.w attribute,x				; x flip
	and.w #attrxflip
	sta.b sprhflip					; sprite h flip
	lda.w attribute,x
	and.w #attryflip				; y flip
	sta.b sprvflip					; sprite v flip
	lda.w attribute,x				; attribute bit 0: sprflag
	lsr a
	bcc .add						; bit 0 clear
	lda.w #$8000
	sta.b sprflag					; flag
.add:								; sprframe at sprx/spry
	jsl.l addframe					; sprframe at sprx/spry
.next:								; next entry
	inc.b a4						; next entry
	lda.b a4
	cmp.w #OOlist+Sortobjs			; 16 objects
	bne .top
	rtl								; done
