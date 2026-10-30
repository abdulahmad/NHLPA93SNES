setvideo:							;Once per game frame, when vblank is idle: build the sprite table and the
									;transfer list for the next vblank.
									;Not vblank code itself
	lda.b VBint						; vblank busy with a list: skip this frame
	cmp.w #vb2						; skip if vblank is not ready
	beq .go							; the blank vblank handler
	cmp.w #vb2_blank
	bne .rtl						; else leave
	lda.b fadein					; first time after vb2_blank: fade in
	bne .go							; already faded in
	stz.b brightness				; brightness 0
	inc.b fadein					; fade in counter
.go:								;clear the sprite table
	jsl.l ClearSprites				; clear the sprite table (all sprites off screen)
	stx.b xsave						; keep X
	ldx.w #$0000					; save a0 through the 29 words after it
.savea:								; save a0 and the words after it (30 words)
	lda.b a0,x
	pha
	inx
	inx
	cpx.w #$003C
	bne .savea
	ldx.b xsave						; restore X
	jsl.l show_rink					; rink scroll
	jsl.l checkfo					; face off circles
	jsl.l checksso					; shootout
	jsl.l setsortcords				; sort the sprites
	jsl.l setffo					; face off objects
	jsl.l showclock					; game clock
	jsl.l showzam					; elapsed time from vcountmark
	jsl.l showcrowd					; crowd
	jsl.l showref					; clears sf2refref
	jsl.l ShowRinkRows				; queue the rink map rows for Vscroll
	jsl.l QueueTextDMA				; queue the changed textmap words (textdirtylo/hi)
	lda.w #VBlank_long				; VBlank sends it all next vblank
	sta.b VBint						; handler for the next vblank
	stx.b xsave						; X again
	ldx.w #$003A
.resta:								; pull the registers back
	pla
	sta.b a0,x
	dex
	dex
	bpl .resta
	ldx.b xsave						; restore X
	ldx.b a3						; X = a3
.rtl:								; return
	rtl
