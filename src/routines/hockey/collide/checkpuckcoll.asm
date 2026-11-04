checkpuckcoll:						;Puck collision with the players near it
									;Called by jump from pucknorm. Walks up and down the OOlist from
									;the puck and runs checkpuckcoll_ccx on each object within 22 in y:
									;stick (puckstick), body (puckbody) or goalie (puckgoalie). No
									;collision while the puck's feet are in the air.
	lda.w Zpos+puckscnum				; puck feet in the air (Zpos > 16): no collision
	sec
	sbc.w #$0010
	beq .setup						; Zpos = 16: still low enough
	bmi .neg						; negative result: .neg checks the overflow
	bvs .setup						; positive with overflow: really negative, Zpos < 16
	bra .rtl						; Zpos > 16: feet in the air, no collision
.neg:								; negative result
	bvs .rtl						; overflow: really positive, Zpos > 16
.setup:								; puck is low: walk the OOlist up and down from it
	lda.w OOlistpos+puckscnum			; Y = puck position in OOlist
	sta.b d1
.up:								; loop: next higher object in the OOlist
	ldy.b d1
	cpy.w #$000F					; top object
	beq .cl							; none above the puck: walk down instead
	lda.w OOlist+1,y				; object number of the next higher one
	and.w #$00FF
	sta.b d4						; d4 = object number, used by checkpuckcoll_ccx
	tay
	lda.w Ylist,y					; y of the next higher object
	sec
	sbc.w pucky						; minus the puck's y
	sec
	sbc.w #$0016					; next higher object within 22 in y
	beq .cc1						; gap = 22: collide
	bmi .neg1						; negative result: .neg1 checks the overflow
	bvs .cc1						; positive with overflow: really negative, gap < 22
	bra .cl							; gap > 22: out of reach, walk down
.neg1:								; negative result
	bvs .cl							; overflow: really positive, gap > 22
.cc1:								; object within 22 in y: test the stick, body or goalie
	jsl.l checkpuckcoll_ccx
	inc.b d1						; next object up
	bra .up
.cl:								; walk down the OOlist from the puck
	lda.w OOlistpos+puckscnum
	beq .rtl						; puck is the lowest object: done
	sta.b d1
.dn:								; loop: next lower object in the OOlist
	ldy.b d1
	lda.w OOlist-1,y				; object number of the next lower one
	and.w #$00FF
	sta.b d4						; d4 = object number, used by checkpuckcoll_ccx
	tay
	lda.w pucky						; puck's y
	sec
	sbc.w Ylist,y					; minus the y of the next lower object
	sec
	sbc.w #$0016
	beq .cc2						; gap = 22: collide
	bmi .neg2						; negative result: .neg2 checks the overflow
	bvs .cc2						; positive with overflow: really negative, gap < 22
	bra .rtl						; gap > 22: out of reach, done
.neg2:								; negative result
	bvs .rtl						; overflow: really positive, gap > 22
.cc2:								; object within 22 in y: test the stick, body or goalie
	jsl.l checkpuckcoll_ccx
	dec.b d1						; next object down
	bne .dn							; until the bottom of the OOlist
.rtl:								; return
	rtl
