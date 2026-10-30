; NHLPA 93 SNES RAM map and hardware names (WRAM $7E0000-$7FFFFF, low 8K mirrored at $0000-$1FFF in banks
; $00-$3F/$80-$BF).
; Equates only, no ROM bytes. Grouped and ordered like 93G ram93.asm: ports and record offsets, hardware,
; buttons, sounds, rink, then the work RAM in 93G's rs order; 93S-only names in the group they belong to.
; Prefer the 68000 RAM names for the same role. Define each name once.
; Like the 93G module files, data/teamdata93s.asm holds the team record offsets, data/frames93s.asm
; the animation and sprite frame equates and routines/tables/asstab.asm the assignment names.
;
; Format: Name = $xxxx (asar equate). DP names are < $100 and are written with .b; others with .w / .l.

;video and sound ports (93S: the SNES PPU, CPU, APU and DMA registers and their values)
; SNES hardware registers (standard names, fullsnes/anomie). Equates only, no bytes.
INIDISP			=	$2100
OBSEL			=	$2101
OAMADDL			=	$2102
OAMADDH			=	$2103
OAMDATA			=	$2104
BGMODE			=	$2105
MOSAIC			=	$2106
BG1SC			=	$2107
BG2SC			=	$2108
BG3SC			=	$2109
BG4SC			=	$210A
BG12NBA			=	$210B
BG34NBA			=	$210C
BG1HOFS			=	$210D
BG1VOFS			=	$210E
BG2HOFS			=	$210F
BG2VOFS			=	$2110
BG3HOFS			=	$2111
BG3VOFS			=	$2112
BG4HOFS			=	$2113
BG4VOFS			=	$2114
VMAIN			=	$2115
VMADDL			=	$2116
VMADDH			=	$2117
VMDATAL			=	$2118
VMDATAH			=	$2119
M7SEL			=	$211A
M7A				=	$211B
M7B				=	$211C
M7C				=	$211D
M7D				=	$211E
M7X				=	$211F
M7Y				=	$2120
CGADD			=	$2121
CGDATA			=	$2122
W12SEL			=	$2123
W34SEL			=	$2124
WOBJSEL			=	$2125
WH0				=	$2126
WH1				=	$2127
WH2				=	$2128
WH3				=	$2129
WBGLOG			=	$212A
WOBJLOG			=	$212B
TM				=	$212C
TS				=	$212D
TMW				=	$212E
TSW				=	$212F
CGWSEL			=	$2130
CGADSUB			=	$2131
COLDATA			=	$2132
SETINI			=	$2133
MPYL			=	$2134
MPYM			=	$2135
MPYH			=	$2136
SLHV			=	$2137
OAMDATAREAD		=	$2138
VMDATALREAD		=	$2139
VMDATAHREAD		=	$213A
CGDATAREAD		=	$213B
OPHCT			=	$213C
OPVCT			=	$213D
STAT77			=	$213E
STAT78			=	$213F
APUIO0			=	$2140
APUIO1			=	$2141
APUIO2			=	$2142
APUIO3			=	$2143
WMDATA			=	$2180
WMADDL			=	$2181
WMADDM			=	$2182
WMADDH			=	$2183
JOYSER0			=	$4016
JOYSER1			=	$4017
NMITIMEN		=	$4200
WRIO			=	$4201
WRMPYA			=	$4202
WRMPYB			=	$4203
WRDIVL			=	$4204
WRDIVH			=	$4205
WRDIVB			=	$4206
HTIMEL			=	$4207
HTIMEH			=	$4208
VTIMEL			=	$4209
VTIMEH			=	$420A
MDMAEN			=	$420B
HDMAEN			=	$420C
MEMSEL			=	$420D
RDNMI			=	$4210
TIMEUP			=	$4211
HVBJOY			=	$4212
RDIO			=	$4213
RDDIVL			=	$4214
RDDIVH			=	$4215
RDMPYL			=	$4216
RDMPYH			=	$4217
JOY1L			=	$4218
JOY1H			=	$4219
JOY2L			=	$421A
JOY2H			=	$421B
JOY3L			=	$421C
JOY3H			=	$421D
JOY4L			=	$421E
JOY4H			=	$421F
; DMA channels 0-7: registers at $43n0-$43nA (DMAPn, BBADn, A1TnL/H, A1Bn, DASnL/H, DASBn, A2AnL/H, NLTRn)
DMAP0			=	$4300
BBAD0			=	$4301
A1T0L			=	$4302
A1T0H			=	$4303
A1B0			=	$4304
DAS0L			=	$4305
DAS0H			=	$4306
DASB0			=	$4307
A2A0L			=	$4308
A2A0H			=	$4309
NLTR0			=	$430A
DMAP1			=	$4310
BBAD1			=	$4311
A1T1L			=	$4312
A1T1H			=	$4313
A1B1			=	$4314
DAS1L			=	$4315
DAS1H			=	$4316
DASB1			=	$4317
A2A1L			=	$4318
A2A1H			=	$4319
NLTR1			=	$431A
DMAP2			=	$4320
BBAD2			=	$4321
A1T2L			=	$4322
A1T2H			=	$4323
A1B2			=	$4324
DAS2L			=	$4325
DAS2H			=	$4326
DASB2			=	$4327
A2A2L			=	$4328
A2A2H			=	$4329
NLTR2			=	$432A
DMAP3			=	$4330
BBAD3			=	$4331
A1T3L			=	$4332
A1T3H			=	$4333
A1B3			=	$4334
DAS3L			=	$4335
DAS3H			=	$4336
DASB3			=	$4337
A2A3L			=	$4338
A2A3H			=	$4339
NLTR3			=	$433A
DMAP4			=	$4340
BBAD4			=	$4341
A1T4L			=	$4342
A1T4H			=	$4343
A1B4			=	$4344
DAS4L			=	$4345
DAS4H			=	$4346
DASB4			=	$4347
A2A4L			=	$4348
A2A4H			=	$4349
NLTR4			=	$434A
DMAP5			=	$4350
BBAD5			=	$4351
A1T5L			=	$4352
A1T5H			=	$4353
A1B5			=	$4354
DAS5L			=	$4355
DAS5H			=	$4356
DASB5			=	$4357
A2A5L			=	$4358
A2A5H			=	$4359
NLTR5			=	$435A
DMAP6			=	$4360
BBAD6			=	$4361
A1T6L			=	$4362
A1T6H			=	$4363
A1B6			=	$4364
DAS6L			=	$4365
DAS6H			=	$4366
DASB6			=	$4367
A2A6L			=	$4368
A2A6H			=	$4369
NLTR6			=	$436A
DMAP7			=	$4370
BBAD7			=	$4371
A1T7L			=	$4372
A1T7H			=	$4373
A1B7			=	$4374
DAS7L			=	$4375
DAS7H			=	$4376
DASB7			=	$4377
A2A7L			=	$4378
A2A7H			=	$4379
NLTR7			=	$437A
; Register values (bits and common settings). Equates only.
INIDISP_FBLANK	=	$80				; INIDISP bit 7: forced blank (brightness in bits 0-3)
NMITIMEN_NMI	=	$80				; NMITIMEN bit 7: vblank NMI on
NMITIMEN_JOY	=	$01				; NMITIMEN bit 0: auto joypad read
MDMAEN_CH0		=	$01				; MDMAEN/HDMAEN: one bit per channel
MDMAEN_CH7		=	$80
VMAIN_INCHI		=	$80				; VMAIN bit 7: step VMADD after the VMDATAH write (word writes)
BGMODE_1		=	$01				; BG mode 1: BG1/BG2 4bpp, BG3 2bpp
TM_BG1			=	$01				; TM/TS layer bits
TM_BG2			=	$02
TM_BG3			=	$04
TM_BG4			=	$08
TM_OBJ			=	$10
; DMAPn/BBADn pairs written as one word (low byte DMAPn, high byte BBADn)
DMA_VRAMWORD	=	$1801			; DMAP $01 (two registers, A->B, increment), BBAD $18 (VMDATAL/VMDATAH)
DMA_CGRAM		=	$2200			; DMAP $00 (one register), BBAD $22 (CGDATA)
DMA_OAM			=	$0400			; DMAP $00 (one register), BBAD $04 (OAMDATA)

;record and field offsets (names shared with 93G, 94G and 94S)
; record fields (names shared with 93G, 94G and 94S)
sstime		=	0					; ScoreSum entry (6 bytes per goal): word period / time
ssflags		=	2					; byte 2 + skater difference (goal type); bit 7 = away team scored
ssscorer	=	3					; byte scorer
ssassist1	=	4					; byte first assist (negative none)
ssassist2	=	5					; byte second assist (negative none)
sssize		=	6
pbpen		=	0					; PenBuf entry (2 bytes): penalty number (0 = free)
pbscnum		=	1					; SCnum of the player
pcx			=	0					; puckcross entry (4 bytes; entry 0 top, 1 bottom): word x
pcframes	=	2					; word frames
pcsize		=	4
foframe		=	0					; fofdata2, fofdata: 4 bytes per big faceoff sprite (centers, ref): frame
foattr		=	2					; word attribute (bit 11 x flip)
fosize		=	4
plpos		=	6					; PlList: 6 wanted roster players, then their positions
pldnum		=	0					; .pld player ratings, 8 bytes after the name (92 setplayer field names):
									; jersey number -> rostnum (setplayer then steps y through the rest)
pldweight	=	1					; high nibble weight, low nibble leg power legstr
pldlegspd	=	2					; high nibble speed legspd, low nibble offense aioff
pldaidef	=	3					; high nibble defense aidef, low nibble shot power shotspd
pldcheck	=	4					; high nibble checking, bit 0 handed, bits 1-3 fighting
pldstick	=	5					; high nibble stickhandling stickhand, low nibble shot accuracy
pldendur	=	6					; high nibble endurance, low nibble shoot / pass odds spodds
pldpass		=	7					; high nibble passing passacc, low nibble aggression aggress
pldsize		=	8

;joystick buttons (93S: SNES pad bits)
bbut		=	$8000				; B: pass / switch player
; joypad
cbut	=	$0080					; shoot / check button in d2
abut		=	$4000				; Y: hold / line change
; joypad bits (SNES)
JOYSTART	=	$1000				; Start
JOYR		=	$0010				; R shoulder
JOYL		=	$0020				; L shoulder
JOYRIGHT	=	$0100				; dpad right
JOYLEFT		=	$0200				; dpad left
JOYDOWN		=	$0400				; dpad down
JOYUP		=	$0800				; dpad up
JOYA		=	$0080				; A button
OFFSCREEN	=	$4E20				; find3d: d1 for a point off the screen (20000)

;sfx / song numbers (93S: SNES sfx and song numbers, SPC700 addresses)
SngGoal			=	4				;home goal (game sample set)
SngPeriodStart	=	5				;period start
SngLateGame		=	6				;third period
SngPP			=	7				;power play (unused)
SngFaceoff		=	8				;face off, mid-period
SngTitle		=	3				;title screen and the game menu (boot set)
SngEOP			=	2				;end of period (unused, boot set)
SFXsiren		=	$A0				; goal siren
SFXwhistle		=	$89				; whistle
SFXhorn			=	$A1				; horn at the end of a period (93G SFXhorn); nothing in the code sends it
SFXshotwiff		=	$98				; +0-3: missed shot (doshot)
SFXhithigh		=	$92				; SFXhithigh 9
SFXhitlow		=	$93				; SFXhitlow $A
SFXcrowdcheer	=	$8A				; home player won the fight, home goalie save (93 song $B)
SFXcrowdboo		=	$8B				; visitor won the fight (93 song $C)
SFXoooh2		=	$8C				; hard shot saved by the visiting goalie, an injury (93 $D)
SFXbglass		=	$8C				; puck over the glass (93 $E)
SFXshotbh		=	$8E				; backhand shot (93 $14)
SFXshotfh		=	$8D				; forehand shot (93 $18)
SFXcheck		=	$90				; +0/1: check (93 $1C-$1F)
SFXplayerwall	=	$9E				; +0/1: player hits the boards (93 $20)
SFXplayerwall2	=	$9F				; player hits the boards, second sound (SFXplayerwall+1)
SFXpuckbody		=	$90				; +0/1: puck hits a body (93 $24)
SFXpuckpost		=	$94				; puck off the post
SFXpuckwall1	=	$95				; +0-2: puck off the boards by speed (93 $28-$2B)
SFXpuckwall2	=	$96				; puck off the boards, variant 2 (SFXpuckwall1+1)
SFXpuckwall3	=	$97				; variant 3 (SFXpuckwall1+2)
; The songs, numbered as the game numbers them: the cue number on port 0 of the sound program (92 and 93G
; names). StartSng<name> sends it (songs 4-8 through MusicCue, 1-3 and 9 on APUIO0). cursong holds the
; starter's own number 1-9 (Goal 1 ... PO 9), not the cue.
SngPO			=	1				;playoff screen (boot sample set)
SngEOG			=	9				;end of game (unused, boot set)
; SPC700 (APU RAM) addresses used by the sound uploads
SPCSAMPLEDIR	=	$2C00			; DSP sample directory (DIR = $2C)
SPCDRIVER		=	$0400			; SPC700 sound driver code (boot upload); the boot upload starts it here
SPCINSTR		=	$2B00			; instrument table of the boot set (6 bytes per instrument)
SPCBOOTSAMPLES	=	$2C30			; first BRR sample of the boot set
SPCSAMPLES		=	$2C50			; first BRR sample of the in-game set
SPCRESUME		=	$0800			;driver entry after the in-game sample upload (the boot upload starts the
									;driver at $0400)
SPCDRIVERSIZE	=	$26E7			; bytes of the SPC700 program (SPCDriver .. SPCDriverEnd)
BOOTSAMPLESIZE	=	$5271			; bytes of Extracted/Sound/bootsamples.brr
GAMESAMPLESIZE	=	$B814			; bytes of the in-game BRR samples (GameSamples)
; sounds (sfx numbers)
SFXstop			=	$9C				; +0/1: skate stop (dostop, controlled player)
SFXshothard		=	$8F				; shot with passspeed >= $32
SFXcheck2		=	$91				; second check sound (93 $1D); the puck body sound has the same two
SFXshotwiff2	=	$99				; missed shot, variant 2 (SFXshotwiff+1)
SFXshotwiff3	=	$9A				; variant 3
SFXshotwiff4	=	$9B				; variant 4
SFXstop2		=	$9D				; skate stop, second sound (SFXstop+1)
SFXcrowd		=	$80				; +1-7: crowd noise level, loops (updatesound)
SFXcrowdoff		=	$88				; crowd noise off

;rink distances
goalline	=	$B0					; blueline+goalline = $108
; rink
blueline	=	$58
sideline	=	$88					; distance from center to side boards

;memory layout, replay
replaysize		=	$71				; bytes per replay frame record
Sortobjs	=	16					; number of sorted graphics objects

;SNES port: the 68k registers in direct page (a0-a4, d0-d7: 4 bytes each, word code uses the low word), scratch and math operands
xsave		=	$0A					;X saved around the movem-style push/pop loops of the 68k port (stx xsave
									;: ldx #0 ...)
a0				=	$33				; 68k a0: object index (SCnum*2) or long pointer [a0] (a0+2 = bank)
a1				=	$37				; 68k a1
a2				=	$3B				; 68k a2: team index, 0 = home (hmtmstruct), 2 = away (awtmstruct)
a3				=	$3F				; 68k a3: current object index (SCnum*2); X normally holds the same value
a4				=	$43				; 68k a4 (long pointer, e.g. PlList)
d0				=	$53				; 68k d0
d1				=	$57				; 68k d1
d2				=	$5B				; 68k d2
d3				=	$5F				; 68k d3
d4				=	$63				; 68k d4
d5				=	$67				; 68k d5
d6				=	$6B				; 68k d6
d7				=	$6F				; 68k d7: frames elapsed this game frame (time step), as in updateplayers
tmp0			=	$73				;scratch word (SNES port temporaries in place of extra 68k data registers)
tmp1			=	$75				;scratch word; tmp0/tmp1 together form a 32-bit value (or tmp1 = long
									;pointer, tmp1+2 = bank)
tmp2			=	$77				; scratch word
mula			=	$7D				;multiply/divide operand A (32-bit with mula+2). Helpers: muls16, mulu
									;(bank $8D/$88), muls (bank $82)
mulb			=	$83				; multiply/divide operand B (32-bit with mulb+2)
mulres			=	$93				; multiply result low word; mulres+2 = high word (68k swap)
mulneg			=	$98				; muls32: count of negative operands
mulsign			=	$81				; divs: count of negative operands
mulcnt			=	$87				; divs: bit loop count (16)

;video: vram layout and tile bases
BigFontchars	=	$1BD1			; vram tiles for the big font
smallfontchars	=	$1BD7			; vram tiles for the small font (print)
logochars		=	$1BDD			;vram tiles for the NHLPA logo (game setup and playoff screens, packed at
									;NHLPALogo)
faceoffvrcset	=	$1BD9			; vram tiles for the faceoff box
framercset		=	$1BDB			; vram tiles for the Framer box
ExtraChars		=	$1BD5			; first free vram tile after the text tiles
unusedchars		=	$1BD3			; 14 tiles after the faceoff box; set by setupice, not read
refcharshor		=	$1BDF			; vram tiles for the little ref (horizontal rink)
refchars		=	$1BE1			; vram tiles for the little ref (vertical rink)
ronbarrchars	=	$1BE3			; vram tiles for the Ron Barr picture (ScoutingReport)
scorechars		=	$1BE5			; vram tiles for the scoreboard / team block maps
blankchar		=	$1BE7			; vram tile of the blank character
unpackbuf		=	$7F0000			;DecompressBytecode output buffer (64K, bank $7F): tiles are copied to
									;vram from here

;print
printx				=	$047B		; x cordinate for printing (text map column)
printy				=	$047D		; y cordinate for printing
printa				=	$0477		; attribute (palette/priority bits) for print characters
printm			=	$D4				;byte offset of the print map in textmap (map number from the print
									;control code)
printfontset	=	$1BCB			; tile base of the selected print font (control code)
strtext				=	2			; String: start of the text after its length word
textdirtylo		=	$D0				; lowest changed word of textmap (sent at the next vblank); $D2 = highest
textdirtyhi		=	$D2				; highest changed word of textmap
printfont			=	$0479		; font number (0-3) from the print control code
; print control codes: a byte with bit 7 set picks palette, priority and font (font 1-3 also picks the map)
; for the text after it; x and y follow. The byte is -(priority << 6 | palette << 4 | font).
CC_Font1		=	$FF				; font 1
CC_Font2		=	$FE				; font 2
CC_Font1Pri		=	$BF				; font 1, priority set
CC_Font2Pri		=	$BE				; font 2, priority set
CC_Font1Pal1	=	$EF				; font 1, palette 1
CC_Font1Pal3	=	$CF				; font 1, palette 3
CC_Font1Pal2Pri	=	$9F				; font 1, palette 2, priority set
charofs			=	$1BCD			;added to every text map tile written by the game code ($FF00 at boot, 0
									;in the game screens)
charofs2		=	$1BCF			;second tile offset: cleared with charofs by the screen setups (the team
									;roster screen adds it)
textmap			=	$7E6E74			;text layer tile map buffer (32x32 words);
									;textdirtylo/hi mark what to send
backmap			=	$7E7674			;second BG map buffer (32x32 words) after textmap: screen backgrounds
									;(GameSetUpMap, Title1Map, EASNBGMap)
textsave		=	$7FF800			; copy of textmap while the pause screen is up

;face off drop, replay record, vblank and frame timing, menu repeat
fodropx				=	$0136		; faceoff box x (pixels)
fodropy				=	$0138		; faceoff box y
VBint		=	$14					; address (bank $80) of the vblank handler VBjsr jumps to
Vcount		=	$00					; 32-bit frame counter, +1 per vblank in vb2_main. Vcount (word there)
OldVcount			=	$0427		; Vcount at the last game frame (d7 = Vcount - OldVcount)
repeatdelayframes			=	$0499		; ProcessInputWithRepeat: frames to the next key repeat
asv			=	$1644				; scouting text without delays (down pressed)
lldisp				=	$0189		; count down for the once-a-second screen/game updates ($18 frames)
vbactive	=	$12					;nonzero while the VBint handler runs (or while main code holds vblank
									;off): VBjsr skips it
hbint		=	$16					;address (bank $80) of the H/V-timer IRQ handler HBjsr jumps to. Default
									;HBdefault
hcount		=	$18					; +1 per IRQ that is not a timer IRQ (HBdefault); cleared every vblank
impactstep		=	$E2				; d7*2: impact decay this game frame (game loop)
velstep			=	$E4				; d7*16: velocity to position scale this game frame
gravstep		=	$E6				; d7*96: gravity this game frame
d7x1024			=	$E8				; d7*1024, set with the other time steps (no reader found yet)
ReplayBufferPtr		=	$0495		;long pointer to the next replay frame record (wraps at ReplayBufferEnd
									;to ReplayBufferStart)
vcountmark			=	$08FB		;32-bit Vcount snapshot: elapsed time base (setupice sets it 2*$10000
									;frames back)
lastframevc			=	$08DB		; Vcount at the last replay frame shown (ReplayMode, bank $8F); not read
hlsavebuf		=	$7E7E74			;StartHL2: the game state (gmode-1 .. ScoreSumbytes) while a highlight
									;plays. ReplayStart role
ReplayBufferEnd		=	$7EFF41		; replay buffer end: adda43 wraps to ReplayBufferStart
ReplayBufferStart	=	$7E8174		; first replay frame record

;sort objects (SortCords). 93S: structure of arrays, one word per object, 16 objects ($20 bytes per field); index with X/Y = SCnum*2; the byte fields (pnum ... handed) are each a word array
Xpos		=	$08FF				; Xpos (integer part)
attribute	=	$09DF				; frame attribute bits (attrxflip, attryflip)
frame		=	$093F				; sprite frame number
oldframe	=	$09FF				; last frame
Ypos		=	$095F				; Ypos (integer part)
Zpos		=	$099F				; Zpos (height)
OldXpos		=	$0A1F
OldYpos		=	$0A5F
OldZpos		=	$0A9F
rosxoff		=	OldXpos				; roster screen: sprite x offset from Xpos (slides -40..+40)
Xvel		=	$0ADF
Yvel		=	$0AFF
Zvel		=	$0B1F
impactp		=	$0B3F				; last player to cause impact (SCnum)
limpact		=	$0B5F				; last impact value
impact		=	$0B7F				; impact value
position	=	$0B9F				;player's position
									;(0=goalie,1=l.def,2=r.def,3=l.wing,4=center,5=r.wing; negative = none)
assnum		=	$0BBF				; index to current assignment (0-7)
asslist		=	$0BDF				;list of assignments, 8 bytes per object:
									;asslist+SCnum*8+assnum (index X*4+assnum)
temp1		=	$0C5F
temp2		=	$0C7F				; temp2 (high byte as a byte counter: sub.b d7,temp2)
temp3		=	$0C9F
temp4		=	$0CBF
temp5		=	$0CDF
radiusx		=	$0D1F				; width of this graphic (wall collision)
radiusy		=	$0D3F
Wallcos		=	$0D5F				; cos of the angle of the last wall collision
Wallsin		=	$0D7F
SCnum		=	$0D9F				; index number of this object (X/2)
facedir		=	$0DBF				; direction of facing 0-7
SPA			=	$0DFF				; current animation (offset into the animation data)
SPAnum		=	$0E1F				; index into animation (4 per frame)
SPAcnt		=	$0E3F				; count down to the next animation frame (-1 = restart)
nopuck		=	$0E5F				; no puck collision until zero
nopuckb		=	$0E7F				; second count down
newpos		=	$0E9F				; requested next position (negative = none)
newpnum		=	$0EBF				; requested next roster player (negative = none)
pflags		=	$0EDF				;pflags (bits 0-7) and pflags2 (bit n at bit n+10); some flags have their
									;own arrays below
; pflags bits (pflags2 bit n is bit n+10)
pfdoff		=	$0001				; deceleration off
pfna		=	$0002				; new assignment
pfnc		=	$11FF				; nonzero: no collision mode. pflags bit pfnc
pfjoycon	=	$0008				; joystick controlled
pfrev		=	$11BF				; nonzero: skating backwards. pflags bit pfrev
pfalock		=	$117F				; nonzero: locked until the animation is done. pflags bit pfalock
pfteam		=	$119F				; 0 = home, nonzero = visitors. pflags bit pfteam
pfgoal		=	$113F				; nonzero: shoots at the top goal. pflags bit pfgoal
pf2fight	=	$115F				; nonzero: fighting. pflags2 bit pf2fight
pf2aip		=	$11DF				; nonzero: animation in progress. pflags2 bit pf2aip
pf2unav		=	$1000				; unavailable
pf2lcm		=	$2000				; line change mode
pf2pen		=	$4000				; caused a penalty
pf2npc		=	$8000				; no player collision
pf2inj		=	$0004				; injured
pnum		=	$0F1F				; player's team location number (low byte)
weight		=	$0F3F
legstr		=	$0F5F
legspd		=	$0F7F
aioff		=	$0F9F
aidef		=	$0FBF
shotspd		=	$0FDF
shotacc		=	$0FFF
passacc		=	$101F				; passacc (goalies: glove save right)
rostnum		=	$103F
spodds		=	$105F				; shot/pass odds
stickhand	=	$107F
endurance	=	$109F				; endurance (goalies: stick save right)
aggress		=	$10BF				; aggression: penalty odds (goalies: glove save left)
GGSleft		=	aggress				; goalie glove save left (92 name), puckgoalie
fighting	=	$10DF				; fighting rating (fight strength and fight odds; 93 $74)
checking	=	$10FF				; checking rating (check odds; 93 $75)
handed		=	$111F				; nonzero: left handed (pldcheck bit 0; 0 = right handed: +3 faceoff)
Ylist		=	$121F				; y of each sort object
OOlistpos	=	$123F				; position of each object in OOlist
OOlist		=	$125F				; 16 bytes: object order list, bottom of the screen last
Xfrac		=	$091F				; fraction of Xpos
Yfrac		=	$097F				; fraction of Ypos
Zfrac		=	$09BF				; fraction of Zpos
OldXfrac	=	$0A3F				; OldXpos low word
OldYfrac	=	$0A7F
OldZfrac	=	$0ABF
temp2b		=	$0CFF				;temp2+1 (low byte; the port also uses it where uses temp2 as a word:
									;swing time, pass wait)
facefrac	=	$0DDF				;turn fraction of facedir: doplayeracc adds the turn rate here and carries
									;into facedir. facedir.l low word
pspeed		=	$126F				; |Xvel|+|Yvel| after a burst (SNES only, read by the hit code)
puckobj			=	$1C				; object index of the puck
netobj1		=	$18					; object index*2 of goal net 1 (y +268)
puckc	=	newpos+puckobj			; SCnum of the puck carrier, negative = loose. puckc (puck newpos)
puckvz	=	Zvel+puckobj
puckvy	=	Yvel+puckobj
pucky	=	Ypos+puckobj
puckvx	=	Xvel+puckobj
puckx	=	Xpos+puckobj
netobj2		=	$1A					; object index*2 of goal net 2 (y -268)
; attribute bits
attrxflip	=	$0800				; x flip
attryflip	=	$1000				; y flip

;crowd, zamboni, title logo sprite
Crowdframe		=	$DC				;crowd frame: low byte = random extra frame (loud crowd), high byte
									;= frame from cd0
Crowdlevel		=	$DE				;level of crowd excitement (+$50 per punch, +$258 for a won fight, +$C8
									;for a faceoff win)
Crowdstep		=	$E0				; animation step for the crowd (0-$1E)
Crowdcnt		=	$DA				; count down to the next crowd animation step
Zamx				=	$08DD		; cleared by setupice
cheercnt			=	$0150		;crowd cheers still to play after a goal (SFXcrowdcheer every 150 frames,
									;Gameloop)
cheervc				=	$0152		; Vcount of the last crowd cheer

;DMA list, rink scroll, wall collision
DMAList			=	$1653			;vram dma list (7-byte entries, see dma* offsets), filled up to DMAlistend
DMAlistend		=	$A3				;byte offset of the end of DMAList (7 bytes per entry); VBlank sends and
									;empties it
Vpos				=	$08DF		; ice rink vertical position
Oldrow				=	$049B		; last rink map row (vertical scrolling of the map data; 999 = redraw all)
Hpos				=	$0154		; ice rink horizontal position
Hscroll				=	$0156		; horizontal scroll: BG2HOFS = Hscroll+$C0 (VBlank)
Vscroll				=	$08E1		; vertical scroll (low 3 bits = BG2 fine scroll)
wcradiusx			=	$08E3		; wall collision radius x
wcradiusy			=	$08E5		; wall collision radius y
vramrow				=	$049D		;BG2 tile map row (0-31) at the top of the ring buffer: BG2VOFS =
									;vramrow*8 + (Vscroll&7)
; DMAList entry offsets
dmasrc	=	0						; word: source address
dmabank	=	2						; byte: source bank
dmalen	=	3						; word: byte count
dmavram	=	5						; word: VRAM word address
dmasize	=	7						; bytes per entry

;palette fades and brightness
brightness	=	$04					;INIDISP shadow (0-15 brightness, $80 forced blank), written each vblank
									;by vb2
fadeout		=	$06					;nonzero: vb2 steps brightness down every 4 frames until 0.
									;SNES stand-in for cramfade
fadein		=	$08					;1: vb2 steps brightness up every 4 frames to 15; >1:
									;delay count before fading in
palbuffer		=	$7E6C74			;CGRAM shadow (256 colors, 512 bytes):
									;VBlank_Cram sends it. palbuffer role

;screen objects: face off sprites, ffo pads, camera, sso arrows
fofdata2			=	$013A		;face off pull frame of the home (fofdata2) and visiting (+4) center
									;(assfaceoffpl)
fofdata				=	$0142		; frame/attribute of the faceoff ref (big faceoff sprites)
PadControlBits		=	$0431		; SCnum nibbles of the pad-controlled players ($FFFF = none)
padcont				=	$0433		; 4 words
fobox			=	$F4				;nonzero while the faceoff box is on screen (puckfaceoff2 .. Endfaceoff):
									;SetLCmode2 keeps its area. disflags bit 4
ffoattr			=	$F6				; 5 words: attribute of the ffo objects (pads 0-3, gloves). ffo attribute
ffoframe			=	$0100		;5 words: frame of the objects tied to rink scrolling (pads 0-3, gloves at
									;+8). ffo frame (92 ffo)
ffoxofs				=	$010A		; 5 words: ffo x offset of the label sprites
ffox				=	$0114		; 5 words: ffo x. ffo Xpos
ffoy				=	$011E		; 5 words: ffo y
ffoz				=	$0128		; 5 words: ffo z ($FFFF = hidden)
ssoattr				=	$08AB		; 4 words: attribute of the off-screen arrow objects
ssoframe			=	$08B3		; 4 words: sso frame
ssoz				=	$08BB		; 4 words: sso z ($FFFF = hidden)
ssox				=	$08C3		; 4 words: sso x
ssoy				=	$08CB		; 4 words: sso y

;puck, pass and touch state, pads, display flags, icing
shotplayer			=	$04A5		; SCnum of the player who shot last
lastplayer			=	$017D		; SCnum of the last player who touched the puck (doshot)
passdir				=	$043B		; direction for pass/shot 0-7 (8 = none)
passspeed			=	$043D		; speed of pass/shot
passReceiverPlayerNum	=	$043F	; SCnum the last pass was aimed at (negative = none)
glovecords			=	$014E		; x/y bytes of the dropped gloves (chkhit)
threat				=	$08D3		; direction of threat on puck handler (nonzero = threat)
puckcross			=	$0489		;2 entries of (x, frames): where/when the puck crosses the top / bottom
									;goal line ($FFFF frames = never)
lj1					=	$0185		; last controller 1 buttons (debounce)
lj2					=	$0187
ltplayer			=	$018B		; last touch player (SCnum)
ltx					=	$018D		; last touch x
lty					=	$018F		; last touch y
iflags				=	$015C		;icing flags (if* masks); high byte (iflags+1) = icingPlayer (SCnum).
									;iflags/icingPlayer
; iflags bits
ifcgl	=	$0001					; puck crossed the goal line
ifdir	=	$0002					; icing toward the top goal
ifok	=	$0004					; icing possible
joypad1				=	$015E		; controller 1 buttons (SNES joypad bits, JOY* masks)
joypad2				=	$0160		; controller 2 buttons
joypad3				=	$0162		; controller 3 buttons (multitap)
joypad4				=	$0164		; controller 4 buttons
padlast1			=	$0166		; 4 words: buttons at the last ReadPads (joypad1-4)
padnew1				=	$016E		; 4 words: buttons newly pressed at the last ReadPads (joypad1-4)
padvcount			=	$0176		; Vcount of the last ReadPads (the pads are read once per frame)
carriedy			=	$0181		;pucky while the puck is carried: the y a shot was taken from (puckgoalie)
cheatpads	=	$1648				; 3 words: the last three new pad presses (the unreached Gameloop .cheat)

;clock, scroll lock, face off spot, collision
; clock
jps		=	24						; jiffys per second
xc1					=	$08F5		; scroll lock x (fight)
yc1					=	$08F7		; scroll lock y
yleader				=	$08F9		; lead distance on scrolling
fox					=	$0146		; faceoff spot x
foy					=	$0148		; faceoff spot y
fodir1				=	$0132		; pull direction of the home center on the faceoff (dpad, negative = none)
fodir2				=	$0134
deltax			=	$EA				; avdgoal: x correction around the goal
deltay			=	$EC				; avdgoal: y correction
collflag		=	$D8				; a player collision happened: checkcoll restores the old position
evalue			=	$F2				; elasticity value of a player collision (0-16)

;text buffers, last sound
mesarea				=	$0191		; temp area for print strings (length word, then characters)
PushWidthBuf		=	$01F5		;PushNumberWidth string: length word (digits + 2), then the digits right
									;aligned, spaces before (8 characters)
lastsfx				=	$017F		; last sound effect requested

;sprites: sprite attribute table (93S: OAM shadow and the addframe sprite engine)
Satt				=	$01FF		; sprite attribute table (OAM shadow, $220 bytes), sent by VBlank
farptr		=	$0C					; long pointer ($0C-$0E) to a frame set table (addframe, addframe_hi)
sprtileptr	=	$0F					; addframe: long pointer to the tiles of the frame set ($0F-$11)
sprclock		=	$A7				;sprite VRAM tile cache clock: a slot whose sprslottime is older than
									;sprclock-sprslotlife is free
sprpriority		=	$BB				; OAM attribute priority bits ORed into every game sprite ($20 at start)
sprflag			=	$AB				;addframe parameter: $8000 = attribute bit 0 / the second faceoff sprite
									;(cleared by addframe)
sprframe		=	$C3				; addframe parameter: sprite frame number (1-based)
sprsetofs		=	$C5				; addframe: first frame number of the frame set that holds sprframe
sprnodraw		=	$C7				; addframe: nonzero: draw nothing
sprx			=	$C9				; addframe parameter: screen x of the frame
spry			=	$CB				; addframe parameter: screen y
sprhflip		=	$A5				; addframe parameter: $0800 = x flip (attribute bit 11)
sprvflip		=	$CD				; addframe parameter: $1000 = attribute bit 12
sprcount		=	$A9				; addframe: next OAM entry (sprite count this frame)
sprpal			=	$AD				; addframe: palette bits of the piece
sprpattr		=	$AF				; addframe: flip bits of the piece ($C0)
sprbigslot		=	$B1				; addframe: VRAM slot rotor for 16x16 sprites
sprbigslotend	=	$B3				; addframe: rotor stop: all big slots in use
sprslot			=	$B5				; addframe: VRAM slot rotor for 8x8 sprites
sprslotend		=	$B7				; addframe: rotor stop: all small slots in use
sprtile			=	$B9				; addframe: VRAM tile of the piece
sprox			=	$BD				; addframe: OAM x of the piece (bit 8 in $BE)
sproy			=	$BF				; addframe: OAM y of the piece
sprslotlife		=	$C1				;frames a sprite VRAM slot stays reserved after it was last used ($12 at
									;start)
SattHi				=	$03FF		; OAM high table shadow (x bit 8 and size, 2 bits per sprite)
sprpieces			=	$0487		; addframe: pieces left in the frame
sprslottime			=	$04AB		;512 words: sprclock value when each 32-byte VRAM sprite tile slot was
									;last used
sprframetime	=	$7E2000			;4 bytes per sprite frame: sprclock when its tiles were last sent (sprite
									;VRAM tile cache)

;game mode and state flags
gmode				=	$1288		; game mode flags (gm* masks)
gmclock				=	$128A		; nonzero: game clock is stopped. gmode bit gmclock
; gmode bits
gmdir		=	$0002				; 0 = home team goes up
gmpen		=	$0004				; penalty called, ref in progress
gmpendel	=	$0008				; delayed penalty has been called
gmhl		=	$0010				; hilight mode
gmoffs		=	$0020				; offsides on
gmeog		=	$0040				; end the period at the next faceoff
sflags				=	$128C		; sflags (low byte) and sflags2 (high byte) as one word (sf*/sf2* masks)
; sflags (low byte = sflags, high byte = sflags2)
sfpz		=	$0001				; pause mode
sfpj		=	$0002				; pause started by controller 2
sfspdir		=	$0004				; set pass dir mode
sfssdir		=	$0008				; set shot dir mode
sfwrap		=	$0010				; replay has wrapped around
sfscrl		=	$0020				; replay scrolled by hand: Hpos/Vpos not from the frames
sfslock		=	$0040				; scroll lock to xc1/yc1
sf2faceoff	=	$0100				; face off in progress
sf2refref	=	$0200				; ref needs refresh
sf2drec		=	$0400				; disable replay record
sf2replay	=	$0800				; replay in progress
sf2shot		=	$1000				; shot was taken
sf2pwrplay	=	$2000				; power play in progress
sf2pwrtm	=	$4000				; 0 for team 1 in power play
sf2offsig	=	$8000				; offsides little ref on
sflags3				=	$1290		; sflags3 (sf3* masks)
; sflags3 bits
sf3llcs		=	$0001				; lower line change box on screen
sf3rmplay	=	$0002				; replay play mode on
sf3alttree	=	$0004				; alt. playoff tree
sf3sbut		=	$0008				; Start pressed during the highlights: skip the rest
sf3fo		=	$0010				; face off just ended: the next puck pickup wins it
sf3icetime	=	$0020				; count frames on ice per player
sfhormode			=	$128E		; nonzero: screen in horizontal mode. sflags bit sfhor

;controllers and teams
c1playernum			=	$1292		; player on controller 1 (negative = none)
c2playernum			=	$1294
cont1team			=	$1296		; team on controller 1 (0 none, 1 home, 2 away)
cont2team			=	$1298
HomeTeam			=	$129A		; home team number (TeamList index)
VisTeam				=	$129C		; visiting team number
lcplayer			=	$0183		;SCnum of the player who opened the line change box ($FFFE = take the next
									;one)

;penalties and ref
PenBuf				=	$129E		; up to 32 penalties: (penalty number, SCnum) byte pairs, 0 = free
PenCntDwn			=	$12E0		; penalty/fight count down (negative = fight over)
PenaltyBufferEnd	=	PenBuf-2	; the word before PenBuf, used as the list base
Penaltytimer			=	$12E2		; frames to the next penalty clock second (updatepentime, 24 per second)
PBnum				=	$12E4		; players in the penalty boxes: home*16 + visitors
InjCntDown			=	$12E6
penmsgtimer			=	$12E8		;count down to reprinting the horizontal penalty message line ($7FFF =
									;never)
RefCnt				=	$12EA		; ref graphics control (negative = idle)
RefStep				=	$12EC		; step in the ref animation (negative = done)
RefPen				=	$12EE		; penalty number of the ref animation

;period, clock and summaries
gsp					=	$12F0		; game period
gameclock			=	$12F2		; game clock seconds; gameclock+2 = jiffies (-$AAA per frame)
PerTimeTotal		=	$12F6		; length of this period (seconds)
ChkCnt				=	$12F8		; checks since the last fight (fight chance)
TempPlOffset		=	$12FA		; pnum of the penalized player | $8000 for the visitors (InProgress)
ScoreSumbytes		=	$12FC		; bytes used in ScoreSum (6 per goal, max $B4)
ScoreSum			=	$12FE		; goal log: time word, (2+tmap diff | $80 away), scorer, assist, assist

;team structures (93S: hmtmstruct / awtmstruct word arrays indexed by a2, 0 home, 2 away)
tmshots		=	$13B2				; shots stat
tmPwrGoals	=	$13B6				; power play goals stat
tmPwrPlays	=	$13BA				; power plays stat
tmPenalties	=	$13BE				; penalties stat
tmPenmin	=	$13C2				; penalty minutes stat
tmATOP		=	$13CA				; attack zone time stat (seconds)
tmdata		=	$13CE				; team data address (bank $83)
tmsort		=	$13D2				; first object index of the team
tmscore		=	$13D6				; score
tmline		=	$13DE				; current line
tmap		=	$13EE				; active players on ice
tmgoalie	=	$13F2				;goalie: low byte = goalie 0/1, $FFxx = pulled (xx = goalie to return, $FF
									;= stays out)
tmflags		=	$140A				; team flags
tmflcc		=	$0001				; line change box needs redrawing
tmflcm		=	$0008				; team in line change mode
tmflast		=	$0004				; next touch overwrites the last touch only
tmfoside	=	$0010				; team offsides
; tmflags bits
tmftimeout	=	$0002				; 93G timeout bit; 93S has no timeout, the bit is shared as in 93G
tmfmid		=	tmftimeout			; nearest player takes the spot between puck and own goal
tmfslide	=	tmftimeout			; team slides out (SlideOutRosterPlayer)
tmfowon		=	$13DA				; faceoffs won
tmchecks	=	$1402				; checks stat
tmpasscomp	=	$1406				; completed passes
tmtouch1	=	$13E2				; pnum of the last touch
tmtouch2	=	$13E6				; second last touch (93 $1A)
tmtouch3	=	$13EA				; third last touch (93 $1C)
tmteam		=	$13F6				; team number (TeamList index) of the team struct
tmnear		=	$13FA				;32-bit (tmnear = low word, +4 = high word): nearest distance^2 to the
									;puck (assnearest). team long $2A
tmlcchoice	=	$140E				; line change box row chosen (0-2). team word $2E
tmpde		=	$147A				; energy of each roster player (word per player, +$34 for team 2)
; roster
maxros	=	26						; roster slots per team
tmpdst		=	$14E2				; bench/ice/box state of each roster player (+$34 for team 2)
tmboxlist	=	$154A				;penalty box list of roster players (bytes, +$1A for team 2, negative
									;ends; team bytes $9A)
tmgoals		=	$1412				; goals per roster player (bytes, +$1A for team 2)
pchecks		=	$1446				; checks per roster player (bytes, +$1A for team 2)
colorflag1			=	$08B7		; cleared by setplayercolors (no reader found)
colorflag2			=	$08B9		; cleared by setplayercolors (no reader found)
; injury
INJfight	=	$112C				; tmpdst value for a player injured in a fight (93 $112C)
; tmpdst values
TMPDICE		=	$FFFF				; on the ice
TMPDBENCH	=	$FFFE				; on the bench
TMPDOUT		=	$FFFD				; out of the game
TMPDINJ		=	$1000				; injured: box time with this bit has no penalty

;playoff game structures
gst1		=	$157F				;playoff games: one word per game (8) for each
									;gstruct field. gst1 (team 1)
gst2		=	$158F				; gst2 (team 2)
gspotwins	=	$159F
gspobwins	=	$15AF
gsper		=	$15BF				; gsper (period)
gss1		=	$15CF				; gss1 (team 1 score)
gss2		=	$15DF
gsflags		=	$15EF				; gsflags (gsf* masks)
gsftf		=	$0001				; the teams of the game are flipped
gsfhl		=	$0002				; game shown in the score ticker
gsfso		=	$0004				; game over
gamenum				=	$014C		; index of the user game in the playoff game arrays (-1 = none)
postarts			=	$0451		; 0-31: playoff tree layout; negative after DecodePW = bad password
bosgames		=	$D6				; 0-6 game of the best of seven series, 7 = single games
gamelevel			=	$014A		; 0-3: depth into the playoff tree (4 = finished)
potreeteam			=	$0473		; the user's slot in the first playoff round
pojoy				=	$044F		; playoff joystick indicator (2+: two players). POJoy
WinBits				=	$08E7		; bits of the teams that go on in the playoff tree
potree				=	$0453		; 32 bytes: team in each playoff tree slot (16+8+4+2+1+1)
PlList				=	$0443		; 12 bytes: wanted roster players (6), then their positions (6)

;menus, bonuses, ticker, stats and scouting screens
TickerNum			=	$08D7		; playoff game the score ticker shows next
PPBonus				=	$0475		; setplayer: power play bonus
PKBonus				=	$0441		; setplayer: penalty kill bonus (negative)
ThirdPBonus		=	$F0				; setplayer: +2 when tied or trailing late in the 3rd period
HmAwBonus			=	$015A		; setplayer: home bonus / visitor penalty
DispAttribCtr		=	$08F1		; scouting text column
VertLineScrolling	=	$08F3		; scouting text line (0-6)
PlayerScrollCtr		=	$08E9		;scouting text: offset of the next word in the paragraph (negative = next
									;paragraph)
SelectedPlayerIdx	=	$08ED		; scouting text: TestList index
ScoutingReportTimer	=	$08EF		; frames to the next word ($7FFF = text finished)
screentimer			=	$08EB		; frames left on the scouting report screen
TestList		=	$7F0000			; scouting report paragraph numbers (-1 ends)
nibblebuffer		=	$041F		; 4 words: the weights WeightedRandomSelect picks from (SetScore)
pausetimer		=	$EE				; pause menu: frames left before a demo pause ends by itself (60000)
tickerstart			=	$0158		;TickerNum at the start of the intermission (IntermissionTick: all shown
									;when it comes round again)
psitem				=	$0485		; pause menu item (0-4)
tickervc			=	$08D9		;Vcount when the ticker box was last shown (Intermission:
									;next one after $150 frames)
DPCLEAREND		=	$164E			; Start clears DP/RAM $0000 up to here

;options, demo, random seed
OptPlayMode	=	$1600				; play mode (0 regular season, 1 continue playoffs, 2/3 new playoffs)
OptNOP	=	$1602				; players option
Opt1team	=	$1604				; team 1
Opt2team	=	$1606				; team 2
Optperlen	=	$1608				; period length index
OptPen		=	$160A				; penalties (0 = off)
OptLine		=	$160C				; line changes (0 = on)
demoflag			=	$08D5		;nonzero in demo mode (pause ends by itself when no controller has a team)
seed				=	$04A1		;32-bit random seed (randomd0). 92 seed, StanleyCupTimer. Its low bits
									;also serve as a quick random
rndb1				=	$0491		; copy of seed byte 1 after each random (8-bit random for other code)
rndb2				=	$0493		; high byte of the new seed after each random
notdemo		=	$160E				;$FFFF once a player set up the game, 0 after the attract demo (FigureJoy:
									;no controller teams). demoflag role

;password and saved data
passbits	=	$1624				;password bits: a 128-bit number, 8 words, low word first (SuperDiv,
									;PushBits). PassBits
tpassbits	=	$1634				; 8 words: passbits before all games are resolved (EncodePW)
PassWord	=	$1610				; 16 password characters (indexes into PasstoText; bit 7 hides it)
PWrange		=	30					; characters in PasstoText
pwlength	=	16					; password characters

;sound driver (93S: SPC700 command queue, uploads and music cues)
sndptr		=	$1A					; long pointer to the SPC upload stream ($1A-$1C, bank in $1C)
sndqin		=	$1D					;sound command queue write index (bank $82 sfx queue at sndqueue, 8 words)
sndqout		=	$1F					; sound command queue read index
sndlock		=	$21					;nonzero while main code changes the sound command queue (bank $82); set
									;by Start during sound init
sndqueue	=	$23					; sound command queue (8 words)
jmlvector			=	$0178		;RAM jml trampoline: $5C (jml opcode, set by Start), target at +1..+3. sfx
									;returns through it, updateplayers calls the assignment through it
goalcue				=	$0429		;nonzero: home team just scored (lead 0-2): assfaceoff plays the goal
									;music cue at the next faceoff
percue				=	$042B		; nonzero: period just started: assfaceoff plays the period music cue
p3cue				=	$042D		;third period: frames until StartSngLateGame plays its music cue (set by
									;StartPer, 0 = done)
midpercue			=	$042F		;gameclock value (half the period) at which assfaceoff plays the
									;mid-period music cue (0 = done)
sfxmutetime			=	$04A7		;Vcount when sound effects were cut off: sfx are dropped for 180 frames
									;after it
sndsettle			=	$049F		;set to 10 after the in-game sample upload: p_music_vblank sends no
									;commands until it counts down
cuetimer			=	$04A9		; frames left of a music cue; sfx are dropped while it runs
crowdvol	=	$1646				; crowd noise volume last sent to the sound driver (updatesound)
sndbank			=	$164F			;sound set loaded into the SPC (1 = the in-game sounds); sfx are queued
									;only for it
cursong			=	$1651			;song playing on the SPC (0 = none); set by the song starters in banks
									;$86/$89
; sndbank: the sample set loaded into the SPC700 (1 = the in-game sounds, 2 = the boot set)
SoundBankGame	=	1
SoundBankBoot	=	2
; The values cursong takes: the starters' own numbers (the cue of the same song is the Sng* value below).
CurSngGoal		=	1
CurSngPeriodStart	=	2
CurSngLateGame	=	3
CurSngPP		=	4
CurSngFaceoff	=	5
CurSngTitle		=	6
CurSngEOP		=	7
CurSngEOG		=	8
CurSngPO		=	9
; The frames a music cue plays (cuetimer), during which sound effects are dropped
SngGoalLen		=	$0240
SngPeriodStartLen	=	$01CE
SngLateGameLen	=	$0474
SngPPLen		=	$022E
SngFaceoffLen	=	$041A
JMLOPCODE		=	$5C				; jml opcode (sfxretjml)
