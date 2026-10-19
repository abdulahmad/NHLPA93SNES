DrawFrame:							;Draw a sprite frame made of small pieces, as DrawFrameHi
	lda.b farptr+1					; tile data pointer = frame data + $200
	sta.b sprtileptr+1
	lda.b farptr
	clc
	adc.w #$0200
	sta.b sprtileptr
	lda.b sprhflip					; horizontal flip: OAM bit $40
	beq .vf
	lda.w #$0040
	sta.b sprhflip
.vf:
	lda.b sprvflip					; vertical flip: OAM bit $80
	beq .fr
	lda.w #$0080
	sta.b sprvflip
.fr:
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
	jmp.w addframe_end				; empty frame: done
.cnt:
	sta.w sprpieces					; pieces left
.piece:								;next piece; OAM full (128): done
	lda.b sprcount					; OAM entries used
	cmp.w #$0080
	bne .data
	jmp.w addframe_end
.data:
	lda.b sprframe					; piece record, 4 bytes each
	asl a
	asl a
	ldy.w #$0006
	adc.b [farptr],y
	tay
	lda.b [farptr],y				; x offset, sign extended
	and.w #$00FF
	bit.w #$0080
	beq .px
	ora.w #$FF00
.px:
	sta.b sprox
	iny
	lda.b [farptr],y				; y offset, sign extended
	and.w #$00FF
	bit.w #$0080
	beq .py
	ora.w #$FF00
.py:
	sta.b sproy
	iny
	lda.b [farptr],y				; tile number, 32 bytes per tile
	and.w #$03FF
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
.size:
	txa
	and.w #$00C0					; bits 6-7 of the piece attribute
	sta.b sprpattr
	txa
	and.w #$0020					; bit $20: big (16x16) piece
	beq .small
	jmp.w .big
.small:
	lda.b sprhflip					; small piece: mirror x for a flip
	beq .sx
	lda.w #$FFF9
	sec
	sbc.b sprox
	sta.b sprox
.sx:
	lda.b sprx						; add the frame x
	clc
	adc.b sprox
	sta.b sprox
	sec
	sbc.w #$FFF9					; off screen to the left?
	bmi .xlov
	bvc .xhi
.xloout:
	jmp.w .nextpiece
.xlov:
	bvc .xloout
.xhi:
	lda.b sprox						; off screen to the right?
	sec
	sbc.w #$00FF
	beq .sy
	bmi .xhiv
	bvs .sy
.xhiout:
	jmp.w .nextpiece
.xhiv:
	bvs .xhiout
.sy:
	lda.b sprvflip					; mirror y for a flip
	beq .ylo
	lda.w #$FFF9
	sec
	sbc.b sproy
	sta.b sproy
.ylo:
	lda.b spry						; add the frame y
	clc
	adc.b sproy
	sta.b sproy
	sec
	sbc.w #$FFF9
	bmi .ylov
	bvc .yhi
.yloout:
	jmp.w .nextpiece
.ylov:
	bvc .yloout
.yhi:
	lda.b sproy						; off screen below?
	sec
	sbc.w #$00DF
	beq .cache
	bmi .yhiv
	bvs .cache
.yhiout:
	jmp.w .nextpiece
.yhiv:
	bvs .yhiout
.cache:
	lda.b sprframe					; frame number plus set offset
	clc
	adc.b sprsetofs
	cmp.w #$131D					; frame beyond the table: hang
.hang1:
	bcs .hang1
	asl a
	asl a
	tax
	lda.b sprclock					; age of the cached copy
	sec
	sbc.l sprframetime,x
	cmp.b sprslotlife
	bcc .have						; still in VRAM
	lda.b sprnodraw					; no new draws allowed
	beq .find
	jmp.w addframe_end
.find:
	lda.b sprslot					; next cache slot
	inc a
	and.w #$01FF
	sta.b sprslot
	cmp.b sprslotend				; wrapped to the end slot
	bne .chk
	lda.b sprslotlife
	cmp.w #$0005
	bcs .shorten
	jml.l addframe_full				; VRAM sprite cache full
.shorten:
	dec.b sprslotlife				; keep slots for less time
	lda.b sprslot
.chk:
	asl a
	tax
	lda.b sprclock					; age of this slot
	sec
	sbc.w sprslottime,x
	cmp.b sprslotlife
	bcc .find						; slot still too fresh: try the next
	txa
	asl a
	asl a
	asl a
	adc.w #$6000					; VRAM address of the slot
	ldx.b DMAlistend				; append a DMA list entry
.hang2:
	cpx.w #$0578					; DMA list full: hang
	bcs .hang2
	sta.w DMAList+dmavram,x
	lda.b farptr+2					; source bank
	sta.w DMAList+dmabank,x
	ldy.w #$0008
	lda.b [farptr],y
	adc.b sprtile					; tile source address
	adc.b farptr
	sta.w DMAList,x
	lda.w #$0020
	sta.w DMAList+dmalen,x			; 32 bytes
	txa
	adc.w #$0007
	sta.b DMAlistend				; next DMA entry
	lda.b sprframe
	adc.b sprsetofs
	asl a
	asl a
	tax
	lda.b sprslot
	sta.l sprframetime+2,x			; remember the slot for the frame
.have:
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
	lda.b sproy						; y
	sta.w Satt+1,x
	lda.b sprtile					; tile low byte
	sta.w Satt+2,x
	xba
	sep #$20						; 8-bit A
	ora.b sprpal					; palette
	ora.b sprpriority
	ora.b sprpattr
	eor.b sprhflip					; flip bits
	eor.b sprvflip
	sta.w Satt+3,x					; attribute byte
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
.next:
	rep #$30						; 16-bit registers
	inc.b sprcount
	jmp.w .nextpiece
.himask:							;SattHi masks that clear the x bit 8 of sprite 0-3 in a byte
	db $FE,$FB,$EF,$BF
.big:
	lda.b sprhflip					; big piece: mirror x for a flip
	beq .bx
	lda.w #$FFF1
	sec
	sbc.b sprox
	sta.b sprox
.bx:
	lda.b sprx						; add the frame x
	clc
	adc.b sprox
	sta.b sprox
	sec
	sbc.w #$FFF1
	bmi .bxlov
	bvc .bxhi
.bxloout:
	jmp.w .nextpiece
.bxlov:
	bvc .bxloout
.bxhi:
	lda.b sprox						; off screen to the right?
	sec
	sbc.w #$00FF
	beq .by
	bmi .bxhiv
	bvs .by
.bxhiout:
	jmp.w .nextpiece
.bxhiv:
	bvs .bxhiout
.by:
	lda.b sprvflip					; mirror y for a flip
	beq .bylo
	lda.w #$FFF1
	sec
	sbc.b sproy
	sta.b sproy
.bylo:
	lda.b spry						; add the frame y
	clc
	adc.b sproy
	sta.b sproy
	sec
	sbc.w #$FFF1
	bmi .bylov
	bvc .byhi
.byloout:
	jmp.w .nextpiece
.bylov:
	bvc .byloout
.byhi:
	lda.b sproy						; off screen below?
	sec
	sbc.w #$00DF
	beq .bcache
	bmi .byhiv
	bvs .bcache
.byhiout:
	jmp.w .nextpiece
.byhiv:
	bvs .byhiout
.bcache:
	lda.b sprframe					; frame number plus set offset
	clc
	adc.b sprsetofs
	cmp.w #$131D
.bhang1:
	bcs .bhang1
	asl a
	asl a
	tax
	lda.b sprclock					; age of the cached copy
	sec
	sbc.l sprframetime,x
	cmp.b sprslotlife
	bcs .bnodraw
	jmp.w .bhave
.bnodraw:
	lda.b sprnodraw					; no new draws allowed
	beq .bfind
	jmp.w addframe_end
.bfind:
	lda.b sprbigslot				; next big cache slot
	inc a
	and.w #$01FF
	sta.b sprbigslot
	cmp.b sprbigslotend
	bne .bchk
	lda.b sprslotlife
	cmp.w #$0005
	bcs .bshorten
	jml.l addframe_full				; VRAM sprite cache full
.bshorten:
	dec.b sprslotlife
	lda.b sprbigslot
.bchk:
	and.w #$000F					; skip slots that straddle a row
	cmp.w #$000F
	beq .bfind
	lda.b sprbigslot
	and.w #$00F0
	cmp.w #$00F0
	beq .bfind
	lda.b sprbigslot
	asl a
	tax
	lda.b sprclock
	sec
	sbc.w sprslottime,x
	cmp.b sprslotlife
	bcc .bfind
	lda.b sprclock
	sec
	sbc.w sprslottime+2,x
	cmp.b sprslotlife
	bcc .bfind
	lda.b sprclock					; all four tiles must be old enough
	sec
	sbc.w sprslottime+$20,x
	cmp.b sprslotlife
	bcc .bfind
	lda.b sprclock
	sec
	sbc.w sprslottime+$22,x
	cmp.b sprslotlife
	bcc .bfind
	txa								; VRAM address of the slot
	asl a
	asl a
	asl a
	adc.w #$6000
	ldx.b DMAlistend				; append two DMA list entries
.bhang2:
	cpx.w #$0571					; DMA list full: hang
	bcs .bhang2
	sta.w DMAList+dmavram,x
	adc.w #$0100
	sta.w DMAList+dmasize+dmavram,x	; second row at +$100
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
	sta.w DMAList,x					; source of the first row
	adc.w #$0200
	sta.w DMAList+dmasize+dmasrc,x	; second row source +$200
	txa
	adc.w #$000E
	sta.b DMAlistend
	lda.b sprframe
	clc
	adc.b sprsetofs
	asl a
	asl a
	tax
	lda.b sprbigslot
	sta.l sprframetime+2,x			; remember the slot for the frame
.bhave:
	lda.b sprclock
	sta.l sprframetime,x			; stamp the frame time
	lda.l sprframetime+2,x
	sta.b sprtile
	asl a
	tax
	lda.b sprclock
	sta.w sprslottime,x
	sta.w sprslottime+2,x			; stamp all four slot times
	sta.w sprslottime+$20,x
	sta.w sprslottime+$22,x
	lda.b sprcount
	asl a
	asl a
	tax
	lda.b sprox
	sta.w Satt,x					; x
	lda.b sproy						; y
	sta.w Satt+1,x
	lda.b sprtile
	sta.w Satt+2,x					; tile low byte
	xba
	sep #$20						; 8-bit A
	ora.b sprpal
	ora.b sprpriority
	ora.b sprpattr
	eor.b sprhflip
	eor.b sprvflip
	sta.w Satt+3,x					; attribute byte
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
	eor.b #$FF						; set the size bit
	asl a
	ora.w SattHi,x
	sta.w SattHi,x
	lda.b sprox+1					; negative x: set the x bit 8
	bpl .bnext
	tya
	eor.b #$FF
	ora.w SattHi,x
	sta.w SattHi,x
.bnext:
	rep #$30						; 16-bit registers
	inc.b sprcount					; next OAM entry
.nextpiece:
	inc.b sprframe					; next piece
	dec.w sprpieces					; pieces left
	beq addframe_end
	jmp.w .piece
