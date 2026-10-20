QueueSound:							;Send sound A to the SPC700 sound program (an effect $80-$A1, or $00 for
									;stop): it goes into the sound queue that VBlank empties one entry a
									;frame. Dropped while a music cue plays (cuetimer). A game sound first
									;uploads the in-game sample set (SPCGameUpload) if the boot set is loaded
	phx								; cuetimer running: drop it
	ldx.w cuetimer
	bne .exit
	phy								; keep Y
	pha								; keep the sound
	ldx.w #$0001					; 1 is the lock flag and also SoundBankGame
	stx.b sndlock					; lock the queue
	cpx.w sndbank					; is SoundBankGame loaded? if not, upload it first
	beq .put						; already loaded
	cmp.w #$00A2					; sound numbers $A2 and up are boot sounds
	bcs .put
	jsl.l SPCGameUpload				; upload the game sounds
.put:								; queue the sound
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
