QueueSound:							;Queue sound A for the sound driver. Dropped while a music cue plays;
									;loads the in-game sound set first
		;   when a game sound needs it
	phx								; cuetimer running: drop it
	ldx.w cuetimer
	bne .exit
	phy								; keep Y
	pha								; keep the sound
	ldx.w #$0001					; lock the queue
	stx.b sndlock
	cpx.w sndbank					; game set not loaded and a game sound: upload it first
	beq .put						; already loaded
	cmp.w #$00A2					; sound numbers $A2 and up are boot sounds
	bcs .put
	jsl.l SPCGameUpload				; upload the game sounds
.put:
	ldx.b sndqin					; sndqueue[sndqin] = A, sndqin = (sndqin + 2) & 15
	pla								; sound back
	sta.b sndqueue,x				; queue it
	txa								; index
	inc a
	inc a
	and.w #$000F
	sta.b sndqin
	stz.b sndlock					; unlock
	ply								; restore Y
.exit:								; restore X and return
	plx
	rtl
