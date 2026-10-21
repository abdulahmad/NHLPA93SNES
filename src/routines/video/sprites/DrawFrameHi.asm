DrawFrameHi:						;Draw a sprite frame at sprx / spry: one sprite per piece, uploading the
									;piece tiles to free video memory
		;   when they are not cached
	lda.b sprnodraw					; drawing disabled: done
	beq .go
	jml.l addframe_end
.go:								;sprtileptr = the set + $200 (tiles)
	lda.b farptr+1
	sta.b sprtileptr+1				; tile data pointer = frame data + $200
	lda.b farptr
	clc
	adc.w #$0200
	sta.b sprtileptr
	lda.b sprhflip					; horizontal flip: OAM bit $40
	beq .fr
	lda.w #$0040
	sta.b sprhflip
.fr:								;first and next piece of the frame: sprpieces = count
	lda.b sprframe					; first piece of this frame
	asl a
	adc.w #$000A
	tay
	lda.b [farptr],y				; piece table start for the frame
	sta.b sprframe
	iny
	iny
	lda.b [farptr],y
	sec
	sbc.b sprframe					; piece count
	bne .cnt
	jml.l addframe_end				; empty frame: done
.cnt:								; pieces left
	sta.w sprpieces					; pieces left
.piece:								;next piece; OAM full (128): done
	lda.b sprcount					; OAM entries used
	cmp.w #$0080
	bne .data
	jml.l addframe_end
.data:								;sprox/sproy = piece x/y + sprx/spry, sprtile, sprpal, sprpattr from the
									;6-byte piece
	lda.b sprframe					; piece record, 6 bytes each
	asl a
	asl a
	adc.b sprframe
	adc.b sprframe
	ldy.w #$0006
	adc.b [farptr],y				; piece table address
	tay
	lda.b [farptr],y
	sta.b sprox						; x offset
	iny
	iny
	lda.b [farptr],y
	clc
	adc.b spry						; add the frame y
	sta.b sproy
	iny
	iny
	lda.b [farptr],y
	and.w #$03FF					; tile number, 32 bytes per tile
	asl a
	asl a
	asl a
	asl a
	asl a
	sta.b sprtile
	iny
	lda.b [farptr],y				; palette and size bits
	tax
	lsr a
	lsr a
	clc
	adc.b sprflag
	and.w #$0007					; palette from the byte and sprflag
	asl a
	sta.b sprpal
	cmp.w #$0004					; palette 4 with sprflag negative becomes 6
	bne .size
	lda.b sprflag
	bpl .size
	lda.w #$0006
	sta.b sprpal
.size:								;bit 5 of the attribute: 16 x 16 piece
	txa
	and.w #$00C0					; bits 6-7 of the piece attribute
	sta.b sprpattr
	txa
	and.w #$0020					; bit $20: big (16x16) piece
	beq .small
	jmp.w .big
.small:								; small piece: mirror x for a flip
	lda.b sprhflip					; small piece: mirror x for a flip
	beq .sx
	lda.b sprox
	eor.w #$FFFF					; negate
	inc a
	sec
	sbc.w #$0007					; mirror about the piece width
	sta.b sprox
.sx:								; add the frame x
	lda.b sprx						; add the frame x
	clc
	adc.b sprox
	sta.b sprox
	sec
	sbc.w #$FFF9					; off screen to the left?
	bmi .xlov
	bvc .xhi
.xloout:							; far branch to .nextpiece
	jmp.w .nextpiece
.xlov:								; signed compare: overflow flag corrects the sign
	bvc .xloout
.xhi:								; off screen to the right?
	lda.b sprox
	sec
	sbc.w #$00FF					; off screen to the right?
	beq .ylo
	bmi .xhiv
	bvs .ylo
.xhiout:							; far branch to .nextpiece
	jmp.w .nextpiece
.xhiv:								; signed compare: overflow flag corrects the sign
	bvs .xhiout
.ylo:								; off screen above?
	lda.b sproy
	sec
	sbc.w #$FFF9					; off screen above?
	bmi .ylov
	bvc .yhi
.yloout:							; far branch to .nextpiece
	jmp.w .nextpiece
.ylov:								; signed compare: overflow flag corrects the sign
	bvc .yloout
.yhi:								; off screen below?
	lda.b sproy
	sec
	sbc.w #$00DF					; off screen below?
	beq .cache
	bmi .yhiv
	bvs .cache
.yhiout:							; far branch to .nextpiece
	jmp.w .nextpiece
.yhiv:								; signed compare: overflow flag corrects the sign
	bvs .yhiout
.cache:								;cached and still fresh: reuse its slot
	lda.b sprframe					; frame number plus set offset
	clc
	adc.b sprsetofs
	cmp.w #$131D					; frame beyond the table: hang
.hang1:								;frame number out of range: hang
	bcs .hang1
	asl a
	asl a
	tax
	lda.b sprclock					; age of the cached copy
	sec
	sbc.l sprframetime,x
	cmp.b sprslotlife
	bcc .have						; still in VRAM
.find:								;find a free 8x8 slot
	lda.b sprslot					; next cache slot
	inc a
	and.w #$01FF
	sta.b sprslot
	cmp.b sprslotend				; wrapped to the end slot
	bne .chk
	jml.l addframe_full				; VRAM sprite cache full
.chk:								; look for a free sprite slot older than the current frame
	asl a
	tax
	lda.b sprclock
	sec
	sbc.w sprslottime,x				; age of this slot
	cmp.b sprslotlife
	bcc .find						; slot still too fresh: try the next
	txa
	asl a
	asl a
	asl a
	adc.w #$6000					; VRAM address of the slot
	ldx.b DMAlistend				; append a DMA list entry
.hang2:								;dma list full: hang
	cpx.w #$0578
	bcs .hang2
	sta.w DMAList+dmavram,x
	lda.b farptr+2					; source bank
	sta.w DMAList+dmabank,x
	ldy.w #$0008
	lda.b [farptr],y
	adc.b sprtile
	adc.b farptr					; tile source address
	sta.w DMAList,x
	lda.w #$0020					; 32 bytes
	sta.w DMAList+dmalen,x
	txa
	adc.w #$0007					; next DMA entry
	sta.b DMAlistend
	lda.b sprframe
	adc.b sprsetofs
	asl a
	asl a
	tax
	lda.b sprslot
	sta.l sprframetime+2,x			; remember the slot for the frame
.have:								;mark frame and slot used now, write the OAM entry
	lda.b sprclock
	sta.l sprframetime,x			; stamp the frame time
	lda.l sprframetime+2,x
	sta.b sprtile					; tile number in VRAM
	asl a
	tax
	lda.b sprclock
	sta.w sprslottime,x				; stamp the slot time
	lda.b sprcount					; OAM entry index
	asl a
	asl a
	tax
	lda.b sprox
	sta.w Satt,x					; x
	lda.b sproy
	sta.w Satt+1,x					; y
	lda.b sprtile
	sta.w Satt+2,x					; tile low byte
	xba
	sep #$20						; 8-bit A
	ora.b sprpal					; palette
	ora.b sprpriority
	ora.b sprpattr
	eor.b sprhflip					; flip bit
	sta.w Satt+3,x
	rep #$30						; 16-bit registers
	lda.b sprcount
	and.w #$0003
	tax
	lda.l .himask,x					; x bit 8 mask
	tay
	lda.b sprcount
	lsr a
	lsr a
	tax
	sep #$20						; 8-bit A
	tya
	and.w SattHi,x					; clear this sprite's x bit 8
	sta.w SattHi,x
	lda.b sprox+1
	bpl .next						; negative x: set the bit again
	tya
	eor.b #$FF
	ora.w SattHi,x
	sta.w SattHi,x
.next:								; next OAM entry
	rep #$30						; 16-bit registers
	inc.b sprcount					; next OAM entry
	jmp.w .nextpiece
.himask:							;SattHi masks that clear the x bit 8 of sprite 0-3 in a byte
	db $FE,$FB,$EF,$BF
.big:								;16 x 16 piece
	lda.b sprhflip					; big piece: mirror x for a flip
	beq .bx
	lda.b sprox
	eor.w #$FFFF					; negate
	inc a
	sec
	sbc.w #$000F					; mirror about the piece width
	sta.b sprox
.bx:								; add the frame x
	lda.b sprx						; add the frame x
	clc
	adc.b sprox
	sta.b sprox
	sec
	sbc.w #$FFF1					; off screen to the left?
	bmi .bxlov
	bvc .bxhi
.bxloout:							; far branch to .nextpiece
	jmp.w .nextpiece
.bxlov:								; signed compare: overflow flag corrects the sign
	bvc .bxloout
.bxhi:								; off screen to the right?
	lda.b sprox
	sec
	sbc.w #$00FF					; off screen to the right?
	beq .bylo
	bmi .bxhiv
	bvs .bylo
.bxhiout:							; far branch to .nextpiece
	jmp.w .nextpiece
.bxhiv:								; signed compare: overflow flag corrects the sign
	bvs .bxhiout
.bylo:								; off screen above?
	lda.b sproy
	sec
	sbc.w #$FFF1					; off screen above?
	bmi .bylov
	bvc .byhi
.byloout:							; far branch to .nextpiece
	jmp.w .nextpiece
.bylov:								; signed compare: overflow flag corrects the sign
	bvc .byloout
.byhi:								; off screen below?
	lda.b sproy
	sec
	sbc.w #$00DF					; off screen below?
	beq .bcache
	bmi .byhiv
	bvs .bcache
.byhiout:							; far branch to .nextpiece
	jmp.w .nextpiece
.byhiv:								; signed compare: overflow flag corrects the sign
	bvs .byhiout
.bcache:							; frame number plus set offset
	lda.b sprframe					; frame number plus set offset
	clc
	adc.b sprsetofs
	cmp.w #$131D					; frame beyond the table: hang
.bhang1:							; hangs if the carry is set (should not happen)
	bcs .bhang1
	asl a
	asl a
	tax
	lda.b sprclock
	sec
	sbc.l sprframetime,x			; age of the cached copy
	cmp.b sprslotlife
	bcs .bfind						; still in VRAM
	jmp.w .bhave
.bfind:								;find a free 16x16 slot: 4 free 8x8 slots in a 2 x 2 block, not in the
									;last row/column
	lda.b sprbigslot				; next big cache slot
	inc a
	and.w #$01FF
	sta.b sprbigslot
	cmp.b sprbigslotend
	bne .bchk
	jml.l addframe_full				; VRAM sprite cache full
.bchk:								; skip slots in the last column
	and.w #$000F					; skip slots in the last column
	cmp.w #$000F
	beq .bfind
	lda.b sprbigslot
	and.w #$00F0					; and in the last row
	cmp.w #$00F0
	beq .bfind
	lda.b sprbigslot
	asl a
	tax
	lda.b sprclock
	sec
	sbc.w sprslottime,x				; age of the first tile
	cmp.b sprslotlife
	bcc .bfind
	lda.b sprclock					; all four tiles must be old enough
	sec
	sbc.w sprslottime+2,x
	cmp.b sprslotlife
	bcc .bfind
	lda.b sprclock
	sec
	sbc.w sprslottime+(16*2),x
	cmp.b sprslotlife
	bcc .bfind
	lda.b sprclock
	sec
	sbc.w sprslottime+(16*2)+2,x
	cmp.b sprslotlife
	bcc .bfind
	txa
	asl a
	asl a
	asl a
	adc.w #$6000					; VRAM address of the slot
	ldx.b DMAlistend				; append two DMA list entries
.bhang2:							; second row at +$100
	cpx.w #$0571
	bcs .bhang2
	sta.w DMAList+dmavram,x
	adc.w #$0100					; second row at +$100
	sta.w DMAList+dmasize+dmavram,x
	lda.b farptr+2
	sta.w DMAList+dmabank,x
	sta.w DMAList+dmasize+dmabank,x
	lda.w #$0040					; 64 bytes per row
	sta.w DMAList+dmalen,x
	sta.w DMAList+dmasize+dmalen,x
	ldy.w #$0008
	lda.b [farptr],y
	adc.b sprtile
	adc.b farptr
	sta.w DMAList,x
	adc.w #$0200					; second row source +$200
	sta.w DMAList+dmasize+dmasrc,x
	txa
	adc.w #$000E
	sta.b DMAlistend
	lda.b sprframe
	clc
	adc.b sprsetofs
	asl a
	asl a
	tax
	lda.b sprbigslot				; remember the slot for the frame
	sta.l sprframetime+2,x
.bhave:								;mark the 4 slots, write the OAM entry (size bit set)
	lda.b sprclock
	sta.l sprframetime,x			; stamp the frame time
	lda.l sprframetime+2,x
	sta.b sprtile
	asl a
	tax
	lda.b sprclock					; stamp all four slot times
	sta.w sprslottime,x
	sta.w sprslottime+2,x
	sta.w sprslottime+(16*2),x
	sta.w sprslottime+(16*2)+2,x
	lda.b sprcount
	asl a
	asl a
	tax
	lda.b sprox
	sta.w Satt,x					; x
	lda.b sproy
	sta.w Satt+1,x					; y
	lda.b sprtile
	sta.w Satt+2,x					; tile low byte
	xba
	sep #$20						; 8-bit A
	ora.b sprpal					; palette
	ora.b sprpriority
	ora.b sprpattr
	eor.b sprhflip					; flip bit
	sta.w Satt+3,x
	rep #$30						; 16-bit registers
	lda.b sprcount
	and.w #$0003
	tax
	lda.l .himask,x					; x bit 8 mask
	tay
	lda.b sprcount
	lsr a
	lsr a
	tax
	sep #$20						; 8-bit A
	tya
	and.w SattHi,x
	sta.w SattHi,x
	tya
	eor.b #$FF
	asl a							; size bit
	ora.w SattHi,x
	sta.w SattHi,x
	lda.b sprox+1
	bpl .bnext						; negative x: set the x bit 8
	tya
	eor.b #$FF
	ora.w SattHi,x
	sta.w SattHi,x
.bnext:								; next OAM entry
	rep #$30						; 16-bit registers
	inc.b sprcount					; next OAM entry
.nextpiece:							;next piece
	inc.b sprframe					; next piece
	dec.w sprpieces					; pieces left
	beq .done
	jmp.w .piece
.done:								;clear sprhflip, sprvflip, sprflag
	stz.b sprhflip					; reset the flip and flag state
	stz.b sprvflip
	stz.b sprflag
	rtl
