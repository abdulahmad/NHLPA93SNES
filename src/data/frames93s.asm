; Animation (SPA) and sprite frame (SPF) names, as in 93G frames93.asm.
;
; First the SPF equates: the first frame number of each group of frames in the SNES sprite sets, each one the
; previous plus the size of its group ("New" marks groups added in 93). From SPFpuck on the frames are one
; lower than in 93G (no SPFreplay frame), and the goalie and the groups new in 93 are laid out differently.
;
; Then SPAlist and one table per animation, in the order of the SPA numbers. Each SPA equate sits above its
; table and an assert checks it against the table.

; Sprite Frame (SPF) base indices
SPFskatewp		=	1				; 1 (skating, stick down)
SPFskate		=	SPFskatewp+40	; 41 (skating, stick up)
SPFturnl		=	SPFskate+40		; 81 (turning left)
SPFturnr		=	SPFturnl+8		; 89 (turning right)
SPFswing		=	SPFturnr+8		; 97 (pass and shot swings)
SPFstop			=	SPFswing+48		; 145 (scrape stop)
SPFskateb		=	SPFstop+16		; 161 (skating backwards)
SPFcelebrate	=	SPFskateb+24	; 185 (celebrating)
SPFpump			=	SPFcelebrate+16	; 201 (arm pump)
SPFcup			=	SPFpump+16		; 217 (skating with the cup)
SPFhipl			=	SPFcup+8		; 225 (hip check left)
SPFhipr			=	SPFhipl+8		; 233 (hip check right)
SPFshoulderl	=	SPFhipr+8		; 241 (shoulder check left)
SPFshoulderr	=	SPFshoulderl+8	; 249 (shoulder check right)
SPFsweep		=	SPFshoulderr+8	; 257 (sweep check)

SPFfallback		=	SPFsweep+16		; 273 (falling backward)
SPFfallfwd		=	SPFfallback+32	; 305 (falling forward)
SPFduck			=	SPFfallfwd+32	; 337 (ducking)
SPFhold			=	SPFduck+8		; 345 (holding)
SPFgloves		=	SPFhold+8		; 353 (gloves on the ice (fights))
SPFfight		=	SPFgloves+1		; 354 (fighting)
SPFfinjury		=	SPFfight+17		; 371 - New (fight injury)
SPFPen			=	SPFfinjury+6	; 377 (frames used by the wall jump animations)

SPFarrow		=	SPFPen+7		; 384 (arrows for off screen players)
SPFpad			=	SPFarrow+6		; 390 (face off pads)
SPFpuck			=	SPFpad+3		; 393 (puck), 93G 394
SPFgoal			=	SPFpuck+11		; 404 (goal), 93G 405
SPFGoalie		=	SPFgoal+2		; 406 (goalie), 93G 407
SPFSiren		=	SPFGoalie+112	; 518 (siren), 93G 555

SPFfaceoff		=	SPFSiren+14		; 532: big faceoff sprites (frame 1; checkfo adds SPFfaceoff-1)
SPFsmallfont	=	SPFfaceoff+10	; 542: pad-label glyphs (the glyph index is added)
SPFzamboni		=	SPFsmallfont+15	; 557: zamboni
SPFflip			=	SPFzamboni+1	; 558 - New (flipping over), 93G 625
SPFstumble		=	SPFflip+8		; 566 - New (stumbling), 93G 601
SPFhook			=	SPFstumble+24	; 590 - New (hooking), 93G 585
SPFcatch		=	SPFhook+16		; 606 - New (catching a puck hit), 93G 569
SPFbglass		=	SPFcatch+16		; 622 - New (glass bang), 93G 645
SPFgready		=	SPFbglass+5		; 627 - New (goalie ready), 93G 539
SPFgdive		=	SPFgready+16	; 643 - New (goalie dive), 93G 519
SPFcrowd		=	SPFgdive+16		; 659: crowd and penalty-box sprites; first frame stored as 6-byte pieces

SPAlist:							;sprite animation pointer list
	dw 0							; (SPA 0 = no animation)
SPAgready		=	$0002			; goalie ready (loops)
SPAgready_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAgready_table			; direction 0
	dw .1-SPAgready_table			; direction 1
	dw .2-SPAgready_table			; direction 2
	dw .3-SPAgready_table			; direction 3
	dw .4-SPAgready_table			; direction 4
	dw .5-SPAgready_table			; direction 5
	dw .6-SPAgready_table			; direction 6
	dw .7-SPAgready_table			; direction 7
	dw 1							; attributes: loops
	;frame/time list for direction 0
.0:	dw SPFGoalie,180,SPFgready,10,SPFgready+1,10,SPFgready,10,SPFgready+1,10,SPFGoalie,240,SPFgready,10,SPFgready+1,10
	dw SPFgready,-10
	;frame/time list for direction 1
.1:	dw SPFGoalie+3,130,SPFgready+2,10,SPFgready+3,10,SPFgready+2,10,SPFgready+3,10,SPFGoalie+3,300,SPFgready+2,10,SPFgready+3,10
	dw SPFgready+2,-10
	;frame/time list for direction 2
.2:	dw SPFGoalie+6,210,SPFgready+4,10,SPFgready+5,10,SPFgready+4,10,SPFgready+5,10,SPFGoalie+6,120,SPFgready+4,10,SPFgready+5,10
	dw SPFgready+4,-10
	;frame/time list for direction 3
.3:	dw SPFGoalie+9,100,SPFgready+6,10,SPFgready+7,10,SPFgready+6,10,SPFgready+7,10,SPFGoalie+9,200,SPFgready+6,10,SPFgready+7,10
	dw SPFgready+6,-10
	;frame/time list for direction 4
.4:	dw SPFGoalie+12,240,SPFgready+8,10,SPFgready+9,10,SPFgready+8,10,SPFgready+9,10,SPFGoalie+12,60,SPFgready+8,10,SPFgready+9,10
	dw SPFgready+8,-10
	;frame/time list for direction 5
.5:	dw SPFGoalie+15,180,SPFgready+10,10,SPFgready+11,10,SPFgready+10,10,SPFgready+11,10,SPFGoalie+15,240,SPFgready+10,10,SPFgready+11,10
	dw SPFgready+10,-10
	;frame/time list for direction 6
.6:	dw SPFGoalie+18,120,SPFgready+12,10,SPFgready+13,10,SPFgready+12,10,SPFgready+13,10,SPFGoalie+18,120,SPFgready+12,10,SPFgready+13,10
	dw SPFgready+12,-10
	;frame/time list for direction 7
.7:	dw SPFGoalie+21,180,SPFgready+14,10,SPFgready+15,10,SPFgready+14,10,SPFgready+15,10,SPFGoalie+21,180,SPFgready+14,10,SPFgready+15,10
	dw SPFgready+14,-10
	assert SPAgready_table-SPAlist == SPAgready

SPAgready2		=	$0134
SPAgready2_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAgready2_table			; direction 0
	dw .1-SPAgready2_table			; direction 1
	dw .2-SPAgready2_table			; direction 2
	dw .3-SPAgready2_table			; direction 3
	dw .4-SPAgready2_table			; direction 4
	dw .5-SPAgready2_table			; direction 5
	dw .6-SPAgready2_table			; direction 6
	dw .7-SPAgready2_table			; direction 7
	dw 0							; attributes
.0:	dw SPFGoalie,-30				; frame/time list for direction 0
.1:	dw SPFGoalie+3,-30				; frame/time list for direction 1
.2:	dw SPFGoalie+6,-30				; frame/time list for direction 2
.3:	dw SPFGoalie+9,-30				; frame/time list for direction 3
.4:	dw SPFGoalie+12,-30				; frame/time list for direction 4
.5:	dw SPFGoalie+15,-30				; frame/time list for direction 5
.6:	dw SPFGoalie+18,-30				; frame/time list for direction 6
.7:	dw SPFGoalie+21,-30				; frame/time list for direction 7
	assert SPAgready2_table-SPAlist == SPAgready2

SPAgglover		=	$0166			; glove save (GoalieSaveList 0)
SPAgglover_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAgglover_table			; direction 0
	dw .1-SPAgglover_table			; direction 1
	dw .2-SPAgglover_table			; direction 2
	dw .3-SPAgglover_table			; direction 3
	dw .4-SPAgglover_table			; direction 4
	dw .5-SPAgglover_table			; direction 5
	dw .6-SPAgglover_table			; direction 6
	dw .7-SPAgglover_table			; direction 7
	dw 0							; attributes
.0:	dw SPFGoalie+1,-32				; frame/time list for direction 0
.1:	dw SPFGoalie+4,-32				; frame/time list for direction 1
.2:	dw SPFGoalie+7,-32				; frame/time list for direction 2
.3:	dw SPFGoalie+10,-32				; frame/time list for direction 3
.4:	dw SPFGoalie+13,-32				; frame/time list for direction 4
.5:	dw SPFGoalie+16,-32				; frame/time list for direction 5
.6:	dw SPFGoalie+19,-32				; frame/time list for direction 6
.7:	dw SPFGoalie+22,-32				; frame/time list for direction 7
	assert SPAgglover_table-SPAlist == SPAgglover

SPAgglovel		=	$0198			; glove save (GoalieSaveList 1)
SPAgglovel_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAgglovel_table			; direction 0
	dw .1-SPAgglovel_table			; direction 1
	dw .2-SPAgglovel_table			; direction 2
	dw .3-SPAgglovel_table			; direction 3
	dw .4-SPAgglovel_table			; direction 4
	dw .5-SPAgglovel_table			; direction 5
	dw .6-SPAgglovel_table			; direction 6
	dw .7-SPAgglovel_table			; direction 7
	dw 0							; attributes
.0:	dw SPFGoalie+2,-32				; frame/time list for direction 0
.1:	dw SPFGoalie+5,-32				; frame/time list for direction 1
.2:	dw SPFGoalie+8,-32				; frame/time list for direction 2
.3:	dw SPFGoalie+11,-32				; frame/time list for direction 3
.4:	dw SPFGoalie+14,-32				; frame/time list for direction 4
.5:	dw SPFGoalie+17,-32				; frame/time list for direction 5
.6:	dw SPFGoalie+20,-32				; frame/time list for direction 6
.7:	dw SPFGoalie+23,-32				; frame/time list for direction 7
	assert SPAgglovel_table-SPAlist == SPAgglovel

SPAgstickr		=	$01CA			; stick save (GoalieSaveList 4) (93G $20C)
SPAgstickr_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAgstickr_table			; direction 0
	dw .1-SPAgstickr_table			; direction 1
	dw .2-SPAgstickr_table			; direction 2
	dw .3-SPAgstickr_table			; direction 3
	dw .4-SPAgstickr_table			; direction 4
	dw .5-SPAgstickr_table			; direction 5
	dw .6-SPAgstickr_table			; direction 6
	dw .7-SPAgstickr_table			; direction 7
	dw 0							; attributes
.0:	dw SPFGoalie+64,-32				; frame/time list for direction 0
.1:	dw SPFGoalie+66,-32				; frame/time list for direction 1
.2:	dw SPFGoalie+68,-32				; frame/time list for direction 2
.3:	dw SPFGoalie+70,-32				; frame/time list for direction 3
.4:	dw SPFGoalie+72,-32				; frame/time list for direction 4
.5:	dw SPFGoalie+74,-32				; frame/time list for direction 5
.6:	dw SPFGoalie+76,-32				; frame/time list for direction 6
.7:	dw SPFGoalie+78,-32				; frame/time list for direction 7
	assert SPAgstickr_table-SPAlist == SPAgstickr

SPAgstickl		=	$01FC			; stick save (GoalieSaveList 5) (93G $23E)
SPAgstickl_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAgstickl_table			; direction 0
	dw .1-SPAgstickl_table			; direction 1
	dw .2-SPAgstickl_table			; direction 2
	dw .3-SPAgstickl_table			; direction 3
	dw .4-SPAgstickl_table			; direction 4
	dw .5-SPAgstickl_table			; direction 5
	dw .6-SPAgstickl_table			; direction 6
	dw .7-SPAgstickl_table			; direction 7
	dw 0							; attributes
.0:	dw SPFGoalie+65,-32				; frame/time list for direction 0
.1:	dw SPFGoalie+67,-32				; frame/time list for direction 1
.2:	dw SPFGoalie+69,-32				; frame/time list for direction 2
.3:	dw SPFGoalie+71,-32				; frame/time list for direction 3
.4:	dw SPFGoalie+73,-32				; frame/time list for direction 4
.5:	dw SPFGoalie+75,-32				; frame/time list for direction 5
.6:	dw SPFGoalie+77,-32				; frame/time list for direction 6
.7:	dw SPFGoalie+79,-32				; frame/time list for direction 7
	assert SPAgstickl_table-SPAlist == SPAgstickl

SPAgstackr		=	$022E			; stack pad save (GoalieSaveList 2) (93G $270)
SPAgstackr_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAgstackr_table			; direction 0
	dw .1-SPAgstackr_table			; direction 1
	dw .2-SPAgstackr_table			; direction 2
	dw .3-SPAgstackr_table			; direction 3
	dw .4-SPAgstackr_table			; direction 4
	dw .5-SPAgstackr_table			; direction 5
	dw .6-SPAgstackr_table			; direction 6
	dw .7-SPAgstackr_table			; direction 7
	dw 0							; attributes
.0:	dw SPFGoalie+40,8,SPFGoalie+41,-20	; frame/time list for direction 0
.1:	dw SPFGoalie+42,8,SPFGoalie+43,-20	; frame/time list for direction 1
.2:	dw SPFGoalie+42,8,SPFGoalie+43,-20	; frame/time list for direction 2
.3:	dw SPFGoalie+44,8,SPFGoalie+45,-20	; frame/time list for direction 3
.4:	dw SPFGoalie+46,8,SPFGoalie+47,-20	; frame/time list for direction 4
.5:	dw SPFGoalie+48,8,SPFGoalie+49,-20	; frame/time list for direction 5
.6:	dw SPFGoalie+48,8,SPFGoalie+49,-20	; frame/time list for direction 6
.7:	dw SPFGoalie+50,8,SPFGoalie+51,-20	; frame/time list for direction 7
	assert SPAgstackr_table-SPAlist == SPAgstackr

SPAgstackl		=	$0280			; stack pad save (GoalieSaveList 3) (93G $2C2)
SPAgstackl_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAgstackl_table			; direction 0
	dw .1-SPAgstackl_table			; direction 1
	dw .2-SPAgstackl_table			; direction 2
	dw .3-SPAgstackl_table			; direction 3
	dw .4-SPAgstackl_table			; direction 4
	dw .5-SPAgstackl_table			; direction 5
	dw .6-SPAgstackl_table			; direction 6
	dw .7-SPAgstackl_table			; direction 7
	dw 0							; attributes
.0:	dw SPFGoalie+52,8,SPFGoalie+53,-20	; frame/time list for direction 0
.1:	dw SPFGoalie+54,8,SPFGoalie+55,-20	; frame/time list for direction 1
.2:	dw SPFGoalie+54,8,SPFGoalie+55,-20	; frame/time list for direction 2
.3:	dw SPFGoalie+56,8,SPFGoalie+57,-20	; frame/time list for direction 3
.4:	dw SPFGoalie+58,8,SPFGoalie+59,-20	; frame/time list for direction 4
.5:	dw SPFGoalie+60,8,SPFGoalie+61,-20	; frame/time list for direction 5
.6:	dw SPFGoalie+60,8,SPFGoalie+61,-20	; frame/time list for direction 6
.7:	dw SPFGoalie+62,8,SPFGoalie+63,-20	; frame/time list for direction 7
	assert SPAgstackl_table-SPAlist == SPAgstackl

SPAgswing		=	$02D2			; (93G $386)
SPAgswing_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAgswing_table			; direction 0
	dw .1-SPAgswing_table			; direction 1
	dw .2-SPAgswing_table			; direction 2
	dw .3-SPAgswing_table			; direction 3
	dw .4-SPAgswing_table			; direction 4
	dw .5-SPAgswing_table			; direction 5
	dw .6-SPAgswing_table			; direction 6
	dw .7-SPAgswing_table			; direction 7
	dw 0							; attributes
.0:	dw SPFGoalie+24,5,SPFGoalie+25,8,SPFGoalie+24,-16	; frame/time list for direction 0
.1:	dw SPFGoalie+26,5,SPFGoalie+27,8,SPFGoalie+26,-16	; frame/time list for direction 1
.2:	dw SPFGoalie+28,5,SPFGoalie+29,8,SPFGoalie+28,-16	; frame/time list for direction 2
.3:	dw SPFGoalie+30,5,SPFGoalie+31,8,SPFGoalie+30,-16	; frame/time list for direction 3
.4:	dw SPFGoalie+32,5,SPFGoalie+33,8,SPFGoalie+32,-16	; frame/time list for direction 4
.5:	dw SPFGoalie+34,5,SPFGoalie+35,8,SPFGoalie+34,-16	; frame/time list for direction 5
.6:	dw SPFGoalie+36,5,SPFGoalie+37,8,SPFGoalie+36,-16	; frame/time list for direction 6
.7:	dw SPFGoalie+38,5,SPFGoalie+39,8,SPFGoalie+38,-16	; frame/time list for direction 7
	assert SPAgswing_table-SPAlist == SPAgswing

SPAgskate		=	$0344			; goalie skating (93G $3F8)
SPAgskate_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAgskate_table			; direction 0
	dw .1-SPAgskate_table			; direction 1
	dw .2-SPAgskate_table			; direction 2
	dw .3-SPAgskate_table			; direction 3
	dw .4-SPAgskate_table			; direction 4
	dw .5-SPAgskate_table			; direction 5
	dw .6-SPAgskate_table			; direction 6
	dw .7-SPAgskate_table			; direction 7
	dw 1							; attributes: loops
.0:	dw SPFGoalie+80,10,SPFGoalie+81,10,SPFGoalie+82,10,SPFGoalie+83,-15	; frame/time list for direction 0
.1:	dw SPFGoalie+84,10,SPFGoalie+85,10,SPFGoalie+86,10,SPFGoalie+87,-15	; frame/time list for direction 1
.2:	dw SPFGoalie+88,10,SPFGoalie+89,10,SPFGoalie+90,10,SPFGoalie+91,-15	; frame/time list for direction 2
.3:	dw SPFGoalie+92,10,SPFGoalie+93,10,SPFGoalie+94,10,SPFGoalie+95,-15	; frame/time list for direction 3
.4:	dw SPFGoalie+96,10,SPFGoalie+97,10,SPFGoalie+98,10,SPFGoalie+99,-15	; frame/time list for direction 4
.5:	dw SPFGoalie+100,10,SPFGoalie+101,10,SPFGoalie+102,10,SPFGoalie+103,-15	; frame/time list for direction 5
.6:	dw SPFGoalie+104,10,SPFGoalie+105,10,SPFGoalie+106,10,SPFGoalie+107,-15	; frame/time list for direction 6
.7:	dw SPFGoalie+108,10,SPFGoalie+109,10,SPFGoalie+110,10,SPFGoalie+111,-15	; frame/time list for direction 7
	assert SPAgskate_table-SPAlist == SPAgskate

SPApflip		=	$03D6			; puck spin (93G $48A)
SPApflip_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPApflip_table			; direction 0
	dw .1-SPApflip_table			; direction 1
	dw .2-SPApflip_table			; direction 2
	dw .3-SPApflip_table			; direction 3
	dw .4-SPApflip_table			; direction 4
	dw .5-SPApflip_table			; direction 5
	dw .6-SPApflip_table			; direction 6
	dw .7-SPApflip_table			; direction 7
	dw 1							; attributes: loops
	;frame/time list for direction 0
.0:	dw SPFpuck+2,4,SPFpuck+3,4,SPFpuck+4,4,SPFpuck+5,4,SPFpuck+6,4,SPFpuck+3,4,SPFpuck+7,4,SPFpuck+1,-4
	;frame/time list for direction 1
.1:	dw SPFpuck+9,2,SPFpuck+1,2,SPFpuck+8,2,SPFpuck+5,2,SPFpuck+10,2,SPFpuck+5,2,SPFpuck+8,2,SPFpuck+1,-2
	;frame/time list for direction 2
.2:	dw SPFpuck+4,2,SPFpuck+3,2,SPFpuck+2,2,SPFpuck+1,2,SPFpuck+7,2,SPFpuck+3,2,SPFpuck+6,2,SPFpuck+5,-2
	;frame/time list for direction 3
.3:	dw SPFpuck+8,4,SPFpuck+1,4,SPFpuck+9,4,SPFpuck+1,4,SPFpuck+8,4,SPFpuck+5,4,SPFpuck+10,4,SPFpuck+5,-4
.4:	dw SPFpuck+1,-4096				; frame/time list for direction 4
.5:	dw SPFpuck+1,-4096				; frame/time list for direction 5
.6:	dw SPFpuck+5,-4096				; frame/time list for direction 6
.7:	dw SPFpuck+5,-4096				; frame/time list for direction 7
	assert SPApflip_table-SPAlist == SPApflip

SPAglide		=	$0478			; glide (93G $52C)
SPAglide_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAglide_table			; direction 0
	dw .1-SPAglide_table			; direction 1
	dw .2-SPAglide_table			; direction 2
	dw .3-SPAglide_table			; direction 3
	dw .4-SPAglide_table			; direction 4
	dw .5-SPAglide_table			; direction 5
	dw .6-SPAglide_table			; direction 6
	dw .7-SPAglide_table			; direction 7
	dw 0							; attributes
.0:	dw SPFskatewp,-8				; frame/time list for direction 0
.1:	dw SPFskatewp+5,-8				; frame/time list for direction 1
.2:	dw SPFskatewp+10,-8				; frame/time list for direction 2
.3:	dw SPFskatewp+15,-8				; frame/time list for direction 3
.4:	dw SPFskatewp+20,-8				; frame/time list for direction 4
.5:	dw SPFskatewp+25,-8				; frame/time list for direction 5
.6:	dw SPFskatewp+30,-8				; frame/time list for direction 6
.7:	dw SPFskatewp+35,-8				; frame/time list for direction 7
	assert SPAglide_table-SPAlist == SPAglide

SPAskatewp		=	$04AA			; (93G $55E)
SPAskatewp_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAskatewp_table			; direction 0
	dw .1-SPAskatewp_table			; direction 1
	dw .2-SPAskatewp_table			; direction 2
	dw .3-SPAskatewp_table			; direction 3
	dw .4-SPAskatewp_table			; direction 4
	dw .5-SPAskatewp_table			; direction 5
	dw .6-SPAskatewp_table			; direction 6
	dw .7-SPAskatewp_table			; direction 7
	dw 0							; attributes
	;frame/time list for direction 0
.0:	dw SPFskatewp+1,10,SPFskatewp+2,10,SPFskatewp+3,10,SPFskatewp+4,10,SPFskatewp,-15
	;frame/time list for direction 1
.1:	dw SPFskatewp+6,10,SPFskatewp+7,10,SPFskatewp+8,10,SPFskatewp+9,10,SPFskatewp+5,-15
	;frame/time list for direction 2
.2:	dw SPFskatewp+11,10,SPFskatewp+12,10,SPFskatewp+13,10,SPFskatewp+14,10,SPFskatewp+10,-15
	;frame/time list for direction 3
.3:	dw SPFskatewp+16,10,SPFskatewp+17,10,SPFskatewp+18,10,SPFskatewp+19,10,SPFskatewp+15,-15
	;frame/time list for direction 4
.4:	dw SPFskatewp+21,10,SPFskatewp+22,10,SPFskatewp+23,10,SPFskatewp+24,10,SPFskatewp+20,-15
	;frame/time list for direction 5
.5:	dw SPFskatewp+26,10,SPFskatewp+27,10,SPFskatewp+28,10,SPFskatewp+29,10,SPFskatewp+25,-15
	;frame/time list for direction 6
.6:	dw SPFskatewp+31,10,SPFskatewp+32,10,SPFskatewp+33,10,SPFskatewp+34,10,SPFskatewp+30,-15
	;frame/time list for direction 7
.7:	dw SPFskatewp+36,10,SPFskatewp+37,10,SPFskatewp+38,10,SPFskatewp+39,10,SPFskatewp+35,-15
	assert SPAskatewp_table-SPAlist == SPAskatewp

SPAskate		=	$055C			; (93G $5F0)
SPAskate_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAskate_table			; direction 0
	dw .1-SPAskate_table			; direction 1
	dw .2-SPAskate_table			; direction 2
	dw .3-SPAskate_table			; direction 3
	dw .4-SPAskate_table			; direction 4
	dw .5-SPAskate_table			; direction 5
	dw .6-SPAskate_table			; direction 6
	dw .7-SPAskate_table			; direction 7
	dw 0							; attributes
.0:	dw SPFskate+1,10,SPFskate+2,10,SPFskate+3,10,SPFskate+4,10,SPFskate,-15	; frame/time list for direction 0
	;frame/time list for direction 1
.1:	dw SPFskate+6,10,SPFskate+7,10,SPFskate+8,10,SPFskate+9,10,SPFskate+5,-15
	;frame/time list for direction 2
.2:	dw SPFskate+11,10,SPFskate+12,10,SPFskate+13,10,SPFskate+14,10,SPFskate+10,-15
	;frame/time list for direction 3
.3:	dw SPFskate+16,10,SPFskate+17,10,SPFskate+18,10,SPFskate+19,10,SPFskate+15,-15
	;frame/time list for direction 4
.4:	dw SPFskate+21,10,SPFskate+22,10,SPFskate+23,10,SPFskate+24,10,SPFskate+20,-15
	;frame/time list for direction 5
.5:	dw SPFskate+26,10,SPFskate+27,10,SPFskate+28,10,SPFskate+29,10,SPFskate+25,-15
	;frame/time list for direction 6
.6:	dw SPFskate+31,10,SPFskate+32,10,SPFskate+33,10,SPFskate+34,10,SPFskate+30,-15
	;frame/time list for direction 7
.7:	dw SPFskate+36,10,SPFskate+37,10,SPFskate+38,10,SPFskate+39,10,SPFskate+35,-15
	assert SPAskate_table-SPAlist == SPAskate

SPAturnl		=	$060E			; (93G $682)
SPAturnl_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAturnl_table			; direction 0
	dw .1-SPAturnl_table			; direction 1
	dw .2-SPAturnl_table			; direction 2
	dw .3-SPAturnl_table			; direction 3
	dw .4-SPAturnl_table			; direction 4
	dw .5-SPAturnl_table			; direction 5
	dw .6-SPAturnl_table			; direction 6
	dw .7-SPAturnl_table			; direction 7
	dw 0							; attributes
.0:	dw SPFturnl,-18					; frame/time list for direction 0
.1:	dw SPFturnl+1,-18				; frame/time list for direction 1
.2:	dw SPFturnl+2,-18				; frame/time list for direction 2
.3:	dw SPFturnl+3,-18				; frame/time list for direction 3
.4:	dw SPFturnl+4,-18				; frame/time list for direction 4
.5:	dw SPFturnl+5,-18				; frame/time list for direction 5
.6:	dw SPFturnl+6,-18				; frame/time list for direction 6
.7:	dw SPFturnl+7,-18				; frame/time list for direction 7
	assert SPAturnl_table-SPAlist == SPAturnl

SPAturnr		=	$0640			; (93G $6B4)
SPAturnr_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAturnr_table			; direction 0
	dw .1-SPAturnr_table			; direction 1
	dw .2-SPAturnr_table			; direction 2
	dw .3-SPAturnr_table			; direction 3
	dw .4-SPAturnr_table			; direction 4
	dw .5-SPAturnr_table			; direction 5
	dw .6-SPAturnr_table			; direction 6
	dw .7-SPAturnr_table			; direction 7
	dw 0							; attributes
.0:	dw SPFturnr,-18					; frame/time list for direction 0
.1:	dw SPFturnr+1,-18				; frame/time list for direction 1
.2:	dw SPFturnr+2,-18				; frame/time list for direction 2
.3:	dw SPFturnr+3,-18				; frame/time list for direction 3
.4:	dw SPFturnr+4,-18				; frame/time list for direction 4
.5:	dw SPFturnr+5,-18				; frame/time list for direction 5
.6:	dw SPFturnr+6,-18				; frame/time list for direction 6
.7:	dw SPFturnr+7,-18				; frame/time list for direction 7
	assert SPAturnr_table-SPAlist == SPAturnr

SPAstop			=	$0672			; stop (93G $6E6)
SPAstop_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAstop_table				; direction 0
	dw .1-SPAstop_table				; direction 1
	dw .2-SPAstop_table				; direction 2
	dw .3-SPAstop_table				; direction 3
	dw .4-SPAstop_table				; direction 4
	dw .5-SPAstop_table				; direction 5
	dw .6-SPAstop_table				; direction 6
	dw .7-SPAstop_table				; direction 7
	dw 1							; attributes: loops
.0:	dw SPFstop,4,SPFstop+1,-4		; frame/time list for direction 0
.1:	dw SPFstop+2,4,SPFstop+3,-4		; frame/time list for direction 1
.2:	dw SPFstop+4,4,SPFstop+5,-4		; frame/time list for direction 2
.3:	dw SPFstop+6,4,SPFstop+7,-4		; frame/time list for direction 3
.4:	dw SPFstop+8,4,SPFstop+9,-4		; frame/time list for direction 4
.5:	dw SPFstop+10,4,SPFstop+11,-4	; frame/time list for direction 5
.6:	dw SPFstop+12,4,SPFstop+13,-4	; frame/time list for direction 6
.7:	dw SPFstop+14,4,SPFstop+15,-4	; frame/time list for direction 7
	assert SPAstop_table-SPAlist == SPAstop

SPApassf		=	$06C4			; (93G $738)
SPApassf_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPApassf_table			; direction 0
	dw .1-SPApassf_table			; direction 1
	dw .2-SPApassf_table			; direction 2
	dw .3-SPApassf_table			; direction 3
	dw .4-SPApassf_table			; direction 4
	dw .5-SPApassf_table			; direction 5
	dw .6-SPApassf_table			; direction 6
	dw .7-SPApassf_table			; direction 7
	dw 0							; attributes
.0:	dw SPFswing+3,4,SPFswing+4,4,SPFswing+5,-20	; frame/time list for direction 0
.1:	dw SPFswing+9,4,SPFswing+10,4,SPFswing+11,-20	; frame/time list for direction 1
.2:	dw SPFswing+15,4,SPFswing+16,4,SPFswing+17,-20	; frame/time list for direction 2
.3:	dw SPFswing+21,4,SPFswing+22,4,SPFswing+23,-20	; frame/time list for direction 3
.4:	dw SPFswing+27,4,SPFswing+28,4,SPFswing+29,-20	; frame/time list for direction 4
.5:	dw SPFswing+33,4,SPFswing+34,4,SPFswing+35,-20	; frame/time list for direction 5
.6:	dw SPFswing+39,4,SPFswing+40,4,SPFswing+41,-20	; frame/time list for direction 6
.7:	dw SPFswing+45,4,SPFswing+46,4,SPFswing+47,-20	; frame/time list for direction 7
	assert SPApassf_table-SPAlist == SPApassf

SPApassb		=	$0736			; (93G $7AA)
SPApassb_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPApassb_table			; direction 0
	dw .1-SPApassb_table			; direction 1
	dw .2-SPApassb_table			; direction 2
	dw .3-SPApassb_table			; direction 3
	dw .4-SPApassb_table			; direction 4
	dw .5-SPApassb_table			; direction 5
	dw .6-SPApassb_table			; direction 6
	dw .7-SPApassb_table			; direction 7
	dw 0							; attributes
.0:	dw SPFswing+3,4,SPFswing+2,4,SPFswing+1,-20	; frame/time list for direction 0
.1:	dw SPFswing+9,4,SPFswing+8,4,SPFswing+7,-20	; frame/time list for direction 1
.2:	dw SPFswing+15,4,SPFswing+14,4,SPFswing+13,-20	; frame/time list for direction 2
.3:	dw SPFswing+21,4,SPFswing+20,4,SPFswing+19,-20	; frame/time list for direction 3
.4:	dw SPFswing+27,4,SPFswing+26,4,SPFswing+25,-20	; frame/time list for direction 4
.5:	dw SPFswing+33,4,SPFswing+32,4,SPFswing+31,-20	; frame/time list for direction 5
.6:	dw SPFswing+39,4,SPFswing+38,4,SPFswing+37,-20	; frame/time list for direction 6
.7:	dw SPFswing+45,4,SPFswing+44,4,SPFswing+43,-20	; frame/time list for direction 7
	assert SPApassb_table-SPAlist == SPApassb

SPAshotf		=	$07A8			; forehand shot (93G $81C)
SPAshotf_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAshotf_table			; direction 0
	dw .1-SPAshotf_table			; direction 1
	dw .2-SPAshotf_table			; direction 2
	dw .3-SPAshotf_table			; direction 3
	dw .4-SPAshotf_table			; direction 4
	dw .5-SPAshotf_table			; direction 5
	dw .6-SPAshotf_table			; direction 6
	dw .7-SPAshotf_table			; direction 7
	dw 0							; attributes
	;frame/time list for direction 0
.0:	dw SPFswing+3,4,SPFswing+2,4,SPFswing+1,4,SPFswing,4,SPFswing+2,0,SPFswing+3,0,SPFswing+4,0,SPFswing+5,-20
	;frame/time list for direction 1
.1:	dw SPFswing+9,4,SPFswing+8,4,SPFswing+7,4,SPFswing+6,4,SPFswing+8,0,SPFswing+9,0,SPFswing+10,0,SPFswing+11,-20
	;frame/time list for direction 2
.2:	dw SPFswing+15,4,SPFswing+14,4,SPFswing+13,4,SPFswing+12,4,SPFswing+14,0,SPFswing+15,0,SPFswing+16,0,SPFswing+17,-20
	;frame/time list for direction 3
.3:	dw SPFswing+21,4,SPFswing+20,4,SPFswing+19,4,SPFswing+18,4,SPFswing+20,0,SPFswing+21,0,SPFswing+22,0,SPFswing+23,-20
	;frame/time list for direction 4
.4:	dw SPFswing+27,4,SPFswing+26,4,SPFswing+25,4,SPFswing+24,4,SPFswing+26,0,SPFswing+27,0,SPFswing+28,0,SPFswing+29,-20
	;frame/time list for direction 5
.5:	dw SPFswing+33,4,SPFswing+32,4,SPFswing+31,4,SPFswing+30,4,SPFswing+32,0,SPFswing+33,0,SPFswing+34,0,SPFswing+35,-20
	;frame/time list for direction 6
.6:	dw SPFswing+39,4,SPFswing+38,4,SPFswing+37,4,SPFswing+36,4,SPFswing+38,0,SPFswing+39,0,SPFswing+40,0,SPFswing+41,-20
	;frame/time list for direction 7
.7:	dw SPFswing+45,4,SPFswing+44,4,SPFswing+43,4,SPFswing+42,4,SPFswing+44,0,SPFswing+45,0,SPFswing+46,0,SPFswing+47,-20
	assert SPAshotf_table-SPAlist == SPAshotf

SPAshotb		=	$08BA			; backhand shot (93G $94E)
SPAshotb_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAshotb_table			; direction 0
	dw .1-SPAshotb_table			; direction 1
	dw .2-SPAshotb_table			; direction 2
	dw .3-SPAshotb_table			; direction 3
	dw .4-SPAshotb_table			; direction 4
	dw .5-SPAshotb_table			; direction 5
	dw .6-SPAshotb_table			; direction 6
	dw .7-SPAshotb_table			; direction 7
	dw 0							; attributes
	;frame/time list for direction 0
.0:	dw SPFswing+3,4,SPFswing+4,4,SPFswing+5,4,SPFswing+5,4,SPFswing+4,0,SPFswing+3,0,SPFswing+2,0,SPFswing+1,-20
	;frame/time list for direction 1
.1:	dw SPFswing+9,4,SPFswing+10,4,SPFswing+11,4,SPFswing+11,4,SPFswing+10,0,SPFswing+9,0,SPFswing+8,0,SPFswing+7,-20
	;frame/time list for direction 2
.2:	dw SPFswing+15,4,SPFswing+16,4,SPFswing+17,4,SPFswing+17,4,SPFswing+16,0,SPFswing+15,0,SPFswing+14,0,SPFswing+13,-20
	;frame/time list for direction 3
.3:	dw SPFswing+21,4,SPFswing+22,4,SPFswing+23,4,SPFswing+23,4,SPFswing+22,0,SPFswing+21,0,SPFswing+20,0,SPFswing+19,-20
	;frame/time list for direction 4
.4:	dw SPFswing+27,4,SPFswing+28,4,SPFswing+29,4,SPFswing+29,4,SPFswing+28,0,SPFswing+27,0,SPFswing+26,0,SPFswing+25,-20
	;frame/time list for direction 5
.5:	dw SPFswing+33,4,SPFswing+34,4,SPFswing+35,4,SPFswing+35,4,SPFswing+34,0,SPFswing+33,0,SPFswing+32,0,SPFswing+31,-20
	;frame/time list for direction 6
.6:	dw SPFswing+39,4,SPFswing+40,4,SPFswing+41,4,SPFswing+41,4,SPFswing+40,0,SPFswing+39,0,SPFswing+38,0,SPFswing+37,-20
	;frame/time list for direction 7
.7:	dw SPFswing+45,4,SPFswing+46,4,SPFswing+47,4,SPFswing+47,4,SPFswing+46,0,SPFswing+45,0,SPFswing+44,0,SPFswing+43,-20
	assert SPAshotb_table-SPAlist == SPAshotb

SPAglideback	=	$09CC			; (93G $A80)
SPAglideback_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAglideback_table		; direction 0
	dw .1-SPAglideback_table		; direction 1
	dw .2-SPAglideback_table		; direction 2
	dw .3-SPAglideback_table		; direction 3
	dw .4-SPAglideback_table		; direction 4
	dw .5-SPAglideback_table		; direction 5
	dw .6-SPAglideback_table		; direction 6
	dw .7-SPAglideback_table		; direction 7
	dw 0							; attributes
.0:	dw SPFskateb,-8					; frame/time list for direction 0
.1:	dw SPFskateb+3,-8				; frame/time list for direction 1
.2:	dw SPFskateb+6,-8				; frame/time list for direction 2
.3:	dw SPFskateb+9,-8				; frame/time list for direction 3
.4:	dw SPFskateb+12,-8				; frame/time list for direction 4
.5:	dw SPFskateb+15,-8				; frame/time list for direction 5
.6:	dw SPFskateb+18,-8				; frame/time list for direction 6
.7:	dw SPFskateb+21,-8				; frame/time list for direction 7
	assert SPAglideback_table-SPAlist == SPAglideback

SPAskateback	=	$09FE			; (93G $AB2)
SPAskateback_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAskateback_table		; direction 0
	dw .1-SPAskateback_table		; direction 1
	dw .2-SPAskateback_table		; direction 2
	dw .3-SPAskateback_table		; direction 3
	dw .4-SPAskateback_table		; direction 4
	dw .5-SPAskateback_table		; direction 5
	dw .6-SPAskateback_table		; direction 6
	dw .7-SPAskateback_table		; direction 7
	dw 0							; attributes
.0:	dw SPFskateb,10,SPFskateb+1,10,SPFskateb,10,SPFskateb+2,-10	; frame/time list for direction 0
.1:	dw SPFskateb+3,10,SPFskateb+4,10,SPFskateb+3,10,SPFskateb+5,-10	; frame/time list for direction 1
.2:	dw SPFskateb+6,10,SPFskateb+7,10,SPFskateb+6,10,SPFskateb+8,-10	; frame/time list for direction 2
.3:	dw SPFskateb+9,10,SPFskateb+10,10,SPFskateb+9,10,SPFskateb+11,-10	; frame/time list for direction 3
.4:	dw SPFskateb+12,10,SPFskateb+13,10,SPFskateb+12,10,SPFskateb+14,-10	; frame/time list for direction 4
.5:	dw SPFskateb+15,10,SPFskateb+16,10,SPFskateb+15,10,SPFskateb+17,-10	; frame/time list for direction 5
.6:	dw SPFskateb+18,10,SPFskateb+19,10,SPFskateb+18,10,SPFskateb+20,-10	; frame/time list for direction 6
.7:	dw SPFskateb+21,10,SPFskateb+22,10,SPFskateb+21,10,SPFskateb+23,-10	; frame/time list for direction 7
	assert SPAskateback_table-SPAlist == SPAskateback

SPAsweepchk		=	$0A90			; sweep check (93G $B44)
SPAsweepchk_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAsweepchk_table			; direction 0
	dw .1-SPAsweepchk_table			; direction 1
	dw .2-SPAsweepchk_table			; direction 2
	dw .3-SPAsweepchk_table			; direction 3
	dw .4-SPAsweepchk_table			; direction 4
	dw .5-SPAsweepchk_table			; direction 5
	dw .6-SPAsweepchk_table			; direction 6
	dw .7-SPAsweepchk_table			; direction 7
	dw 0							; attributes
.0:	dw SPFsweep,4,SPFsweep+1,8,SPFsweep,-4	; frame/time list for direction 0
.1:	dw SPFsweep+2,4,SPFsweep+3,8,SPFsweep+2,-4	; frame/time list for direction 1
.2:	dw SPFsweep+4,4,SPFsweep+5,8,SPFsweep+4,-4	; frame/time list for direction 2
.3:	dw SPFsweep+6,4,SPFsweep+7,8,SPFsweep+6,-4	; frame/time list for direction 3
.4:	dw SPFsweep+8,4,SPFsweep+9,8,SPFsweep+8,-4	; frame/time list for direction 4
.5:	dw SPFsweep+10,4,SPFsweep+11,8,SPFsweep+10,-4	; frame/time list for direction 5
.6:	dw SPFsweep+12,4,SPFsweep+13,8,SPFsweep+12,-4	; frame/time list for direction 6
.7:	dw SPFsweep+14,4,SPFsweep+15,8,SPFsweep+14,-4	; frame/time list for direction 7
	assert SPAsweepchk_table-SPAlist == SPAsweepchk

SPAshoulderchkl	=	$0B02			; (93G $BB6)
SPAshoulderchkl_table:				;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAshoulderchkl_table		; direction 0
	dw .1-SPAshoulderchkl_table		; direction 1
	dw .2-SPAshoulderchkl_table		; direction 2
	dw .3-SPAshoulderchkl_table		; direction 3
	dw .4-SPAshoulderchkl_table		; direction 4
	dw .5-SPAshoulderchkl_table		; direction 5
	dw .6-SPAshoulderchkl_table		; direction 6
	dw .7-SPAshoulderchkl_table		; direction 7
	dw 0							; attributes
.0:	dw SPFshoulderl,-24				; frame/time list for direction 0
.1:	dw SPFshoulderl+1,-24			; frame/time list for direction 1
.2:	dw SPFshoulderl+2,-24			; frame/time list for direction 2
.3:	dw SPFshoulderl+3,-24			; frame/time list for direction 3
.4:	dw SPFshoulderl+4,-24			; frame/time list for direction 4
.5:	dw SPFshoulderl+5,-24			; frame/time list for direction 5
.6:	dw SPFshoulderl+6,-24			; frame/time list for direction 6
.7:	dw SPFshoulderl+7,-24			; frame/time list for direction 7
	assert SPAshoulderchkl_table-SPAlist == SPAshoulderchkl

SPAshoulderchkr	=	$0B34			; (93G $BE8)
SPAshoulderchkr_table:				;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAshoulderchkr_table		; direction 0
	dw .1-SPAshoulderchkr_table		; direction 1
	dw .2-SPAshoulderchkr_table		; direction 2
	dw .3-SPAshoulderchkr_table		; direction 3
	dw .4-SPAshoulderchkr_table		; direction 4
	dw .5-SPAshoulderchkr_table		; direction 5
	dw .6-SPAshoulderchkr_table		; direction 6
	dw .7-SPAshoulderchkr_table		; direction 7
	dw 0							; attributes
.0:	dw SPFshoulderr,-24				; frame/time list for direction 0
.1:	dw SPFshoulderr+1,-24			; frame/time list for direction 1
.2:	dw SPFshoulderr+2,-24			; frame/time list for direction 2
.3:	dw SPFshoulderr+3,-24			; frame/time list for direction 3
.4:	dw SPFshoulderr+4,-24			; frame/time list for direction 4
.5:	dw SPFshoulderr+5,-24			; frame/time list for direction 5
.6:	dw SPFshoulderr+6,-24			; frame/time list for direction 6
.7:	dw SPFshoulderr+7,-24			; frame/time list for direction 7
	assert SPAshoulderchkr_table-SPAlist == SPAshoulderchkr

SPAhipchkl		=	$0B66			; (93G $C1A)
SPAhipchkl_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAhipchkl_table			; direction 0
	dw .1-SPAhipchkl_table			; direction 1
	dw .2-SPAhipchkl_table			; direction 2
	dw .3-SPAhipchkl_table			; direction 3
	dw .4-SPAhipchkl_table			; direction 4
	dw .5-SPAhipchkl_table			; direction 5
	dw .6-SPAhipchkl_table			; direction 6
	dw .7-SPAhipchkl_table			; direction 7
	dw 0							; attributes
.0:	dw SPFhipl,-24					; frame/time list for direction 0
.1:	dw SPFhipl+1,-24				; frame/time list for direction 1
.2:	dw SPFhipl+2,-24				; frame/time list for direction 2
.3:	dw SPFhipl+3,-24				; frame/time list for direction 3
.4:	dw SPFhipl+4,-24				; frame/time list for direction 4
.5:	dw SPFhipl+5,-24				; frame/time list for direction 5
.6:	dw SPFhipl+6,-24				; frame/time list for direction 6
.7:	dw SPFhipl+7,-24				; frame/time list for direction 7
	assert SPAhipchkl_table-SPAlist == SPAhipchkl

SPAhipchkr		=	$0B98			; (93G $C4C)
SPAhipchkr_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAhipchkr_table			; direction 0
	dw .1-SPAhipchkr_table			; direction 1
	dw .2-SPAhipchkr_table			; direction 2
	dw .3-SPAhipchkr_table			; direction 3
	dw .4-SPAhipchkr_table			; direction 4
	dw .5-SPAhipchkr_table			; direction 5
	dw .6-SPAhipchkr_table			; direction 6
	dw .7-SPAhipchkr_table			; direction 7
	dw 0							; attributes
.0:	dw SPFhipr,-24					; frame/time list for direction 0
.1:	dw SPFhipr+1,-24				; frame/time list for direction 1
.2:	dw SPFhipr+2,-24				; frame/time list for direction 2
.3:	dw SPFhipr+3,-24				; frame/time list for direction 3
.4:	dw SPFhipr+4,-24				; frame/time list for direction 4
.5:	dw SPFhipr+5,-24				; frame/time list for direction 5
.6:	dw SPFhipr+6,-24				; frame/time list for direction 6
.7:	dw SPFhipr+7,-24				; frame/time list for direction 7
	assert SPAhipchkr_table-SPAlist == SPAhipchkr

SPAburst		=	$0BCA			; check button burst (93G $C7E)
SPAburst_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAburst_table			; direction 0
	dw .1-SPAburst_table			; direction 1
	dw .2-SPAburst_table			; direction 2
	dw .3-SPAburst_table			; direction 3
	dw .4-SPAburst_table			; direction 4
	dw .5-SPAburst_table			; direction 5
	dw .6-SPAburst_table			; direction 6
	dw .7-SPAburst_table			; direction 7
	dw 0							; attributes
.0:	dw SPFskate,-24					; frame/time list for direction 0
.1:	dw SPFskate+5,-24				; frame/time list for direction 1
.2:	dw SPFskate+10,-24				; frame/time list for direction 2
.3:	dw SPFskate+15,-24				; frame/time list for direction 3
.4:	dw SPFskate+20,-24				; frame/time list for direction 4
.5:	dw SPFskate+25,-24				; frame/time list for direction 5
.6:	dw SPFskate+30,-24				; frame/time list for direction 6
.7:	dw SPFskate+35,-24				; frame/time list for direction 7
	assert SPAburst_table-SPAlist == SPAburst

SPAHold			=	$0BFC			; hold (93G $CB0)
SPAHold_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAHold_table				; direction 0
	dw .1-SPAHold_table				; direction 1
	dw .2-SPAHold_table				; direction 2
	dw .3-SPAHold_table				; direction 3
	dw .4-SPAHold_table				; direction 4
	dw .5-SPAHold_table				; direction 5
	dw .6-SPAHold_table				; direction 6
	dw .7-SPAHold_table				; direction 7
	dw 0							; attributes
.0:	dw SPFhold,-30					; frame/time list for direction 0
.1:	dw SPFhold+1,-30				; frame/time list for direction 1
.2:	dw SPFhold+2,-30				; frame/time list for direction 2
.3:	dw SPFhold+3,-30				; frame/time list for direction 3
.4:	dw SPFhold+4,-30				; frame/time list for direction 4
.5:	dw SPFhold+5,-30				; frame/time list for direction 5
.6:	dw SPFhold+6,-30				; frame/time list for direction 6
.7:	dw SPFhold+7,-30				; frame/time list for direction 7
	assert SPAHold_table-SPAlist == SPAHold

SPAHold2		=	$0C2E			; (93G $CE2)
SPAHold2_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAHold2_table			; direction 0
	dw .1-SPAHold2_table			; direction 1
	dw .2-SPAHold2_table			; direction 2
	dw .3-SPAHold2_table			; direction 3
	dw .4-SPAHold2_table			; direction 4
	dw .5-SPAHold2_table			; direction 5
	dw .6-SPAHold2_table			; direction 6
	dw .7-SPAHold2_table			; direction 7
	dw 0							; attributes
.0:	dw SPFhold,-30					; frame/time list for direction 0
.1:	dw SPFhold+1,-30				; frame/time list for direction 1
.2:	dw SPFhold+2,-30				; frame/time list for direction 2
.3:	dw SPFhold+3,-30				; frame/time list for direction 3
.4:	dw SPFhold+4,-30				; frame/time list for direction 4
.5:	dw SPFhold+5,-30				; frame/time list for direction 5
.6:	dw SPFhold+6,-30				; frame/time list for direction 6
.7:	dw SPFhold+7,-30				; frame/time list for direction 7
	assert SPAHold2_table-SPAlist == SPAHold2

SPAflail		=	$0C60			; (93G $D14)
SPAflail_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAflail_table			; direction 0
	dw .1-SPAflail_table			; direction 1
	dw .2-SPAflail_table			; direction 2
	dw .3-SPAflail_table			; direction 3
	dw .4-SPAflail_table			; direction 4
	dw .5-SPAflail_table			; direction 5
	dw .6-SPAflail_table			; direction 6
	dw .7-SPAflail_table			; direction 7
	dw 0							; attributes
.0:	dw SPFskate,-30					; frame/time list for direction 0
.1:	dw SPFskate+5,-30				; frame/time list for direction 1
.2:	dw SPFskate+10,-30				; frame/time list for direction 2
.3:	dw SPFskate+15,-30				; frame/time list for direction 3
.4:	dw SPFskate+20,-30				; frame/time list for direction 4
.5:	dw SPFskate+25,-30				; frame/time list for direction 5
.6:	dw SPFskate+30,-30				; frame/time list for direction 6
.7:	dw SPFskate+35,-30				; frame/time list for direction 7
	assert SPAflail_table-SPAlist == SPAflail

SPAfallfwd		=	$0C92			; (93G $D46)
SPAfallfwd_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAfallfwd_table			; direction 0
	dw .1-SPAfallfwd_table			; direction 1
	dw .2-SPAfallfwd_table			; direction 2
	dw .3-SPAfallfwd_table			; direction 3
	dw .4-SPAfallfwd_table			; direction 4
	dw .5-SPAfallfwd_table			; direction 5
	dw .6-SPAfallfwd_table			; direction 6
	dw .7-SPAfallfwd_table			; direction 7
	dw 0							; attributes
	;frame/time list for direction 0
.0:	dw SPFfallfwd,6,SPFfallfwd+1,6,SPFfallfwd+2,100,SPFfallfwd+3,8,SPFduck,-8
	;frame/time list for direction 1
.1:	dw SPFfallfwd+4,6,SPFfallfwd+5,6,SPFfallfwd+6,100,SPFfallfwd+7,8,SPFduck+1,-8
	;frame/time list for direction 2
.2:	dw SPFfallfwd+8,6,SPFfallfwd+9,6,SPFfallfwd+10,100,SPFfallfwd+11,8,SPFduck+2,-8
	;frame/time list for direction 3
.3:	dw SPFfallfwd+12,6,SPFfallfwd+13,6,SPFfallfwd+14,100,SPFfallfwd+15,8,SPFduck+3,-8
	;frame/time list for direction 4
.4:	dw SPFfallfwd+16,6,SPFfallfwd+17,6,SPFfallfwd+18,100,SPFfallfwd+19,8,SPFduck+4,-8
	;frame/time list for direction 5
.5:	dw SPFfallfwd+20,6,SPFfallfwd+21,6,SPFfallfwd+22,100,SPFfallfwd+23,8,SPFduck+5,-8
	;frame/time list for direction 6
.6:	dw SPFfallfwd+24,6,SPFfallfwd+25,6,SPFfallfwd+26,100,SPFfallfwd+27,8,SPFduck+6,-8
	;frame/time list for direction 7
.7:	dw SPFfallfwd+28,6,SPFfallfwd+29,6,SPFfallfwd+30,100,SPFfallfwd+31,8,SPFduck+7,-8
	assert SPAfallfwd_table-SPAlist == SPAfallfwd

SPAfallback		=	$0D44			; (93G $DF8)
SPAfallback_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAfallback_table			; direction 0
	dw .1-SPAfallback_table			; direction 1
	dw .2-SPAfallback_table			; direction 2
	dw .3-SPAfallback_table			; direction 3
	dw .4-SPAfallback_table			; direction 4
	dw .5-SPAfallback_table			; direction 5
	dw .6-SPAfallback_table			; direction 6
	dw .7-SPAfallback_table			; direction 7
	dw 0							; attributes
	;frame/time list for direction 0
.0:	dw SPFfallback,6,SPFfallback+1,6,SPFfallback+2,100,SPFfallback+3,8,SPFduck,-8
	;frame/time list for direction 1
.1:	dw SPFfallback+4,6,SPFfallback+5,6,SPFfallback+6,100,SPFfallback+7,8,SPFduck+1,-8
	;frame/time list for direction 2
.2:	dw SPFfallback+8,6,SPFfallback+9,6,SPFfallback+10,100,SPFfallback+11,8,SPFduck+2,-8
	;frame/time list for direction 3
.3:	dw SPFfallback+12,6,SPFfallback+13,6,SPFfallback+14,100,SPFfallback+15,8,SPFduck+3,-8
	;frame/time list for direction 4
.4:	dw SPFfallback+16,6,SPFfallback+17,6,SPFfallback+18,100,SPFfallback+19,8,SPFduck+4,-8
	;frame/time list for direction 5
.5:	dw SPFfallback+20,6,SPFfallback+21,6,SPFfallback+22,100,SPFfallback+23,8,SPFduck+5,-8
	;frame/time list for direction 6
.6:	dw SPFfallback+24,6,SPFfallback+25,6,SPFfallback+26,100,SPFfallback+27,8,SPFduck+6,-8
	;frame/time list for direction 7
.7:	dw SPFfallback+28,6,SPFfallback+29,6,SPFfallback+30,100,SPFfallback+31,8,SPFduck+7,-8
	assert SPAfallback_table-SPAlist == SPAfallback

SPAcelebrate	=	$0DF6			; (93G $EAA)
SPAcelebrate_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAcelebrate_table		; direction 0
	dw .1-SPAcelebrate_table		; direction 1
	dw .2-SPAcelebrate_table		; direction 2
	dw .3-SPAcelebrate_table		; direction 3
	dw .4-SPAcelebrate_table		; direction 4
	dw .5-SPAcelebrate_table		; direction 5
	dw .6-SPAcelebrate_table		; direction 6
	dw .7-SPAcelebrate_table		; direction 7
	dw 0							; attributes
.0:	dw SPFcelebrate,12,SPFcelebrate+1,40,SPFcelebrate,-5	; frame/time list for direction 0
.1:	dw SPFcelebrate+2,12,SPFcelebrate+3,40,SPFcelebrate+2,-5	; frame/time list for direction 1
.2:	dw SPFcelebrate+4,12,SPFcelebrate+5,40,SPFcelebrate+4,-5	; frame/time list for direction 2
.3:	dw SPFcelebrate+6,12,SPFcelebrate+7,40,SPFcelebrate+6,-5	; frame/time list for direction 3
.4:	dw SPFcelebrate+8,12,SPFcelebrate+9,40,SPFcelebrate+8,-5	; frame/time list for direction 4
.5:	dw SPFcelebrate+10,12,SPFcelebrate+11,40,SPFcelebrate+10,-5	; frame/time list for direction 5
.6:	dw SPFcelebrate+12,12,SPFcelebrate+13,40,SPFcelebrate+12,-5	; frame/time list for direction 6
.7:	dw SPFcelebrate+14,12,SPFcelebrate+15,40,SPFcelebrate+14,-5	; frame/time list for direction 7
	assert SPAcelebrate_table-SPAlist == SPAcelebrate

SPApump			=	$0E68			; (93G $F1C)
SPApump_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPApump_table				; direction 0
	dw .1-SPApump_table				; direction 1
	dw .2-SPApump_table				; direction 2
	dw .3-SPApump_table				; direction 3
	dw .4-SPApump_table				; direction 4
	dw .5-SPApump_table				; direction 5
	dw .6-SPApump_table				; direction 6
	dw .7-SPApump_table				; direction 7
	dw 0							; attributes
.0:	dw SPFpump,8,SPFpump+1,8,SPFpump,-8	; frame/time list for direction 0
.1:	dw SPFpump+2,8,SPFpump+3,8,SPFpump+2,-8	; frame/time list for direction 1
.2:	dw SPFpump+4,8,SPFpump+5,8,SPFpump+4,-8	; frame/time list for direction 2
.3:	dw SPFpump+6,8,SPFpump+7,8,SPFpump+6,-8	; frame/time list for direction 3
.4:	dw SPFpump+8,8,SPFpump+9,8,SPFpump+8,-8	; frame/time list for direction 4
.5:	dw SPFpump+10,8,SPFpump+11,8,SPFpump+10,-8	; frame/time list for direction 5
.6:	dw SPFpump+12,8,SPFpump+13,8,SPFpump+12,-8	; frame/time list for direction 6
.7:	dw SPFpump+14,8,SPFpump+15,8,SPFpump+14,-8	; frame/time list for direction 7
	assert SPApump_table-SPAlist == SPApump

SPAfight		=	$0EDA			; fight (93G $F8E)
SPAfight_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAfight_table			; direction 0
	dw .0-SPAfight_table			; direction 1
	dw .0-SPAfight_table			; direction 2
	dw .3-SPAfight_table			; direction 3
	dw .3-SPAfight_table			; direction 4
	dw .3-SPAfight_table			; direction 5
	dw .3-SPAfight_table			; direction 6
	dw .3-SPAfight_table			; direction 7
	dw 0							; attributes
.0:	dw SPFfight,8,SPFfight+1,8,SPFfight+2,8,SPFfight+3,-6	; frame/time list for direction 0
.3:	dw SPFfight,8,SPFfight+1,8,SPFfight+2,8,SPFfight+8,-6	; frame/time list for direction 3
	assert SPAfight_table-SPAlist == SPAfight

SPAfgrab		=	$0F0C			; (93G $FC0)
SPAfgrab_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAfgrab_table			; direction 0
	dw .0-SPAfgrab_table			; direction 1
	dw .0-SPAfgrab_table			; direction 2
	dw .3-SPAfgrab_table			; direction 3
	dw .3-SPAfgrab_table			; direction 4
	dw .3-SPAfgrab_table			; direction 5
	dw .3-SPAfgrab_table			; direction 6
	dw .3-SPAfgrab_table			; direction 7
	dw 0							; attributes
.0:	dw SPFfight+4,28,SPFfight+3,-4	; frame/time list for direction 0
.3:	dw SPFfight+9,28,SPFfight+8,-4	; frame/time list for direction 3
	assert SPAfgrab_table-SPAlist == SPAfgrab

SPAfheld		=	$0F2E			; (93G $FE2)
SPAfheld_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAfheld_table			; direction 0
	dw .0-SPAfheld_table			; direction 1
	dw .0-SPAfheld_table			; direction 2
	dw .3-SPAfheld_table			; direction 3
	dw .3-SPAfheld_table			; direction 4
	dw .3-SPAfheld_table			; direction 5
	dw .3-SPAfheld_table			; direction 6
	dw .3-SPAfheld_table			; direction 7
	dw 0							; attributes
.0:	dw SPFfight+4,30,SPFfight+3,-4	; frame/time list for direction 0
.3:	dw SPFfight+9,30,SPFfight+8,-4	; frame/time list for direction 3
	assert SPAfheld_table-SPAlist == SPAfheld

SPAfhigh		=	$0F50			; (93G $1004)
SPAfhigh_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAfhigh_table			; direction 0
	dw .0-SPAfhigh_table			; direction 1
	dw .0-SPAfhigh_table			; direction 2
	dw .3-SPAfhigh_table			; direction 3
	dw .3-SPAfhigh_table			; direction 4
	dw .3-SPAfhigh_table			; direction 5
	dw .3-SPAfhigh_table			; direction 6
	dw .3-SPAfhigh_table			; direction 7
	dw 0							; attributes
.0:	dw SPFfight+5,6,SPFfight+6,16,SPFfight+5,4,SPFfight+3,-16	; frame/time list for direction 0
.3:	dw SPFfight+10,6,SPFfight+11,16,SPFfight+10,4,SPFfight+8,-16	; frame/time list for direction 3
	assert SPAfhigh_table-SPAlist == SPAfhigh

SPAflow			=	$0F82			; (93G $1036)
SPAflow_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAflow_table				; direction 0
	dw .0-SPAflow_table				; direction 1
	dw .0-SPAflow_table				; direction 2
	dw .3-SPAflow_table				; direction 3
	dw .3-SPAflow_table				; direction 4
	dw .3-SPAflow_table				; direction 5
	dw .3-SPAflow_table				; direction 6
	dw .3-SPAflow_table				; direction 7
	dw 0							; attributes
.0:	dw SPFfight+5,6,SPFfight+7,16,SPFfight+5,4,SPFfight+3,-16	; frame/time list for direction 0
.3:	dw SPFfight+10,6,SPFfight+12,16,SPFfight+10,4,SPFfight+8,-16	; frame/time list for direction 3
	assert SPAflow_table-SPAlist == SPAflow

SPAfhith		=	$0FB4			; (93G $1068)
SPAfhith_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAfhith_table			; direction 0
	dw .0-SPAfhith_table			; direction 1
	dw .0-SPAfhith_table			; direction 2
	dw .3-SPAfhith_table			; direction 3
	dw .3-SPAfhith_table			; direction 4
	dw .3-SPAfhith_table			; direction 5
	dw .3-SPAfhith_table			; direction 6
	dw .3-SPAfhith_table			; direction 7
	dw 0							; attributes
.0:	dw SPFfight+14,16,SPFfight+3,-8	; frame/time list for direction 0
.3:	dw SPFfight+14,16,SPFfight+8,-8	; frame/time list for direction 3
	assert SPAfhith_table-SPAlist == SPAfhith

SPAfhitl		=	$0FD6			; (93G $108A)
SPAfhitl_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAfhitl_table			; direction 0
	dw .0-SPAfhitl_table			; direction 1
	dw .0-SPAfhitl_table			; direction 2
	dw .3-SPAfhitl_table			; direction 3
	dw .3-SPAfhitl_table			; direction 4
	dw .3-SPAfhitl_table			; direction 5
	dw .3-SPAfhitl_table			; direction 6
	dw .3-SPAfhitl_table			; direction 7
	dw 0							; attributes
.0:	dw SPFfight+13,16,SPFfight+3,-8	; frame/time list for direction 0
.3:	dw SPFfight+13,16,SPFfight+8,-8	; frame/time list for direction 3
	assert SPAfhitl_table-SPAlist == SPAfhitl

SPAffall		=	$0FF8			; (93G $10AC)
SPAffall_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAffall_table			; direction 0
	dw .0-SPAffall_table			; direction 1
	dw .0-SPAffall_table			; direction 2
	dw .0-SPAffall_table			; direction 3
	dw .0-SPAffall_table			; direction 4
	dw .0-SPAffall_table			; direction 5
	dw .0-SPAffall_table			; direction 6
	dw .0-SPAffall_table			; direction 7
	dw 0							; attributes
.0:	dw SPFfight+14,8,SPFfight+15,8,SPFfight+16,200,SPFfight+16,-2	; frame/time list for direction 0
	assert SPAffall_table-SPAlist == SPAffall

SPAwallright	=	$101A			; (93G $1128)
SPAwallright_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAwallright_table		; direction 0
	dw .1-SPAwallright_table		; direction 1
	dw .1-SPAwallright_table		; direction 2
	dw .3-SPAwallright_table		; direction 3
	dw .3-SPAwallright_table		; direction 4
	dw .3-SPAwallright_table		; direction 5
	dw .3-SPAwallright_table		; direction 6
	dw SPAwallleft_table-SPAwallright_table	; direction 7: points at the next table header
	dw 0							; attributes
.0:	dw SPFPen+4,8,SPFPen+5,8,SPFPen+6,-8	; frame/time list for direction 0
.1:	dw SPFPen,8,SPFPen+1,8,SPFPen+2,8,SPFPen+3,-8	; frame/time list for direction 1
.3:	dw SPFPen+3,8,SPFPen+2,8,SPFPen+1,8,SPFPen,-8	; frame/time list for direction 3
	assert SPAwallright_table-SPAlist == SPAwallright

SPAwallleft		=	$1058			; (93G $1166)
SPAwallleft_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAwallleft_table			; direction 0
	dw .1-SPAwallleft_table			; direction 1
	dw .1-SPAwallleft_table			; direction 2
	dw .3-SPAwallleft_table			; direction 3
	dw .3-SPAwallleft_table			; direction 4
	dw .3-SPAwallleft_table			; direction 5
	dw .3-SPAwallleft_table			; direction 6
	dw SPAfaceoff_table-SPAwallleft_table	; direction 7: points at the next table header
	dw 0							; attributes
.0:	dw SPFPen+6,8,SPFPen+5,8,SPFPen+4,-8	; frame/time list for direction 0
.1:	dw SPFPen+3,8,SPFPen+2,8,SPFPen+1,8,SPFPen,-8	; frame/time list for direction 1
.3:	dw SPFPen,8,SPFPen+1,8,SPFPen+2,8,SPFPen+3,-8	; frame/time list for direction 3
	assert SPAwallleft_table-SPAlist == SPAwallleft

SPAfaceoff		=	$1096			; faceoff pull (93G $11A4)
SPAfaceoff_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAfaceoff_table			; direction 0
	dw .1-SPAfaceoff_table			; direction 1
	dw .1-SPAfaceoff_table			; direction 2
	dw .1-SPAfaceoff_table			; direction 3
	dw .1-SPAfaceoff_table			; direction 4
	dw .1-SPAfaceoff_table			; direction 5
	dw .1-SPAfaceoff_table			; direction 6
	dw .1-SPAfaceoff_table			; direction 7
	dw 0							; attributes
.0:	dw SPFskatewp,2,SPFsweep+1,10,SPFsweep,-6	; frame/time list for direction 0
.1:	dw SPFskatewp+20,2,SPFsweep+9,10,SPFsweep+8,-6	; frame/time list for direction 1
	assert SPAfaceoff_table-SPAlist == SPAfaceoff

SPAfaceoffr		=	$10C0			; faceoff ready (93G $11CE)
SPAfaceoffr_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAfaceoffr_table			; direction 0
	dw .1-SPAfaceoffr_table			; direction 1
	dw .1-SPAfaceoffr_table			; direction 2
	dw .1-SPAfaceoffr_table			; direction 3
	dw .1-SPAfaceoffr_table			; direction 4
	dw .1-SPAfaceoffr_table			; direction 5
	dw .1-SPAfaceoffr_table			; direction 6
	dw .1-SPAfaceoffr_table			; direction 7
	dw 0							; attributes
.0:	dw SPFskatewp,-5				; frame/time list for direction 0
.1:	dw SPFskatewp+20,-5				; frame/time list for direction 1
	assert SPAfaceoffr_table-SPAlist == SPAfaceoffr

SPAsiren		=	$10DA			; goal siren on the puck shadow (93G $11E8)
SPAsiren_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAsiren_table			; direction 0
	dw .0-SPAsiren_table			; direction 1
	dw .0-SPAsiren_table			; direction 2
	dw .0-SPAsiren_table			; direction 3
	dw .0-SPAsiren_table			; direction 4
	dw .0-SPAsiren_table			; direction 5
	dw .0-SPAsiren_table			; direction 6
	dw .0-SPAsiren_table			; direction 7
	dw 1							; attributes: loops
	;frame/time list for direction 0
.0:	dw SPFSiren,3,SPFSiren+1,3,SPFSiren+2,3,SPFSiren+3,3,SPFSiren+4,3,SPFSiren+5,3,SPFSiren+6,3,SPFSiren+7,3
	dw SPFSiren+8,3,SPFSiren+9,3,SPFSiren+10,3,SPFSiren+11,3,SPFSiren+12,3,SPFSiren+13,-3
	assert SPAsiren_table-SPAlist == SPAsiren

SPAstanley		=	$1124			; (93G $1258)
SPAstanley_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAstanley_table			; direction 0
	dw .1-SPAstanley_table			; direction 1
	dw .2-SPAstanley_table			; direction 2
	dw .3-SPAstanley_table			; direction 3
	dw .4-SPAstanley_table			; direction 4
	dw .5-SPAstanley_table			; direction 5
	dw .6-SPAstanley_table			; direction 6
	dw .7-SPAstanley_table			; direction 7
	dw 1							; attributes: loops
.0:	dw SPFcup,-30					; frame/time list for direction 0
.1:	dw SPFcup+1,-30					; frame/time list for direction 1
.2:	dw SPFcup+2,-30					; frame/time list for direction 2
.3:	dw SPFcup+3,-30					; frame/time list for direction 3
.4:	dw SPFcup+4,-30					; frame/time list for direction 4
.5:	dw SPFcup+5,-30					; frame/time list for direction 5
.6:	dw SPFcup+6,-30					; frame/time list for direction 6
.7:	dw SPFcup+7,-30					; frame/time list for direction 7
	assert SPAstanley_table-SPAlist == SPAstanley

SPAfinjury		=	$1156			; fight injury (fight loser down) (93G $10CE)
SPAfinjury_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAfinjury_table			; direction 0
	dw .0-SPAfinjury_table			; direction 1
	dw .0-SPAfinjury_table			; direction 2
	dw .0-SPAfinjury_table			; direction 3
	dw .0-SPAfinjury_table			; direction 4
	dw .0-SPAfinjury_table			; direction 5
	dw .0-SPAfinjury_table			; direction 6
	dw .0-SPAfinjury_table			; direction 7
	dw 0							; attributes
	;frame/time list for direction 0
.0:	dw SPFfight+14,8,SPFfight+15,8,SPFfight+16,20,SPFfinjury,8,SPFfinjury+1,8,SPFfinjury+2,8,SPFfinjury+3,10,SPFfinjury+4,10
	dw SPFfinjury+5,10,SPFfinjury+3,10,SPFfinjury+4,10,SPFfinjury+5,10,SPFfinjury+3,10,SPFfinjury+4,10,SPFfinjury+5,10,SPFfinjury+3,10
	dw SPFfinjury+4,10,SPFfinjury+5,-400
	assert SPAfinjury_table-SPAlist == SPAfinjury

SPAflip			=	$11B0			; third fall animation (flip) (93G $1524)
SPAflip_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAflip_table				; direction 0
	dw .1-SPAflip_table				; direction 1
	dw .2-SPAflip_table				; direction 2
	dw .3-SPAflip_table				; direction 3
	dw .4-SPAflip_table				; direction 4
	dw .5-SPAflip_table				; direction 5
	dw .6-SPAflip_table				; direction 6
	dw .7-SPAflip_table				; direction 7
	dw 0							; attributes
	;frame/time list for direction 0
.0:	dw SPFflip,6,SPFflip+1,6,SPFflip+2,6,SPFflip+3,6,SPFfallback+2,100,SPFfallback+3,8,SPFduck,-8
	;frame/time list for direction 1
.1:	dw SPFflip,6,SPFflip+1,6,SPFflip+2,6,SPFflip+3,6,SPFfallback+6,100,SPFfallback+7,8,SPFduck+1,-8
	;frame/time list for direction 2
.2:	dw SPFflip,6,SPFflip+1,6,SPFflip+2,6,SPFflip+3,6,SPFfallback+10,100,SPFfallback+11,8,SPFduck+2,-8
	;frame/time list for direction 3
.3:	dw SPFflip+4,6,SPFflip+5,6,SPFflip+6,6,SPFflip+7,6,SPFfallback+14,100,SPFfallback+15,8,SPFduck+3,-8
	;frame/time list for direction 4
.4:	dw SPFflip+4,6,SPFflip+5,6,SPFflip+6,6,SPFflip+7,6,SPFfallback+18,100,SPFfallback+19,8,SPFduck+4,-8
	;frame/time list for direction 5
.5:	dw SPFflip+4,6,SPFflip+5,6,SPFflip+6,6,SPFflip+7,6,SPFfallback+22,100,SPFfallback+23,8,SPFduck+5,-8
	;frame/time list for direction 6
.6:	dw SPFflip+4,6,SPFflip+5,6,SPFflip+6,6,SPFflip+7,6,SPFfallback+26,100,SPFfallback+27,8,SPFduck+6,-8
	;frame/time list for direction 7
.7:	dw SPFflip,6,SPFflip+1,6,SPFflip+2,6,SPFflip+3,6,SPFfallback+30,100,SPFfallback+31,8,SPFduck+7,-8
	assert SPAflip_table-SPAlist == SPAflip

SPAstumble		=	$12A2			; stumble instead of a fall (93G $13A0)
SPAstumble_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAstumble_table			; direction 0
	dw .1-SPAstumble_table			; direction 1
	dw .2-SPAstumble_table			; direction 2
	dw .3-SPAstumble_table			; direction 3
	dw .4-SPAstumble_table			; direction 4
	dw .5-SPAstumble_table			; direction 5
	dw .6-SPAstumble_table			; direction 6
	dw .7-SPAstumble_table			; direction 7
	dw 0							; attributes
	;frame/time list for direction 0
.0:	dw SPFstumble,6,SPFstumble+1,6,SPFstumble+2,8,SPFstumble+1,6,SPFstumble,-6
	;frame/time list for direction 1
.1:	dw SPFstumble+3,6,SPFstumble+4,6,SPFstumble+5,8,SPFstumble+4,6,SPFstumble+3,-6
	;frame/time list for direction 2
.2:	dw SPFstumble+6,6,SPFstumble+7,6,SPFstumble+8,8,SPFstumble+7,6,SPFstumble+6,-6
	;frame/time list for direction 3
.3:	dw SPFstumble+9,6,SPFstumble+10,6,SPFstumble+11,8,SPFstumble+10,6,SPFstumble+9,-6
	;frame/time list for direction 4
.4:	dw SPFstumble+12,6,SPFstumble+13,6,SPFstumble+14,8,SPFstumble+13,6,SPFstumble+12,-6
	;frame/time list for direction 5
.5:	dw SPFstumble+15,6,SPFstumble+16,6,SPFstumble+17,8,SPFstumble+16,6,SPFstumble+15,-6
	;frame/time list for direction 6
.6:	dw SPFstumble+18,6,SPFstumble+19,6,SPFstumble+20,8,SPFstumble+19,6,SPFstumble+18,-6
	;frame/time list for direction 7
.7:	dw SPFstumble+21,6,SPFstumble+22,6,SPFstumble+23,8,SPFstumble+22,6,SPFstumble+21,-6
	assert SPAstumble_table-SPAlist == SPAstumble

SPAhook			=	$1354			; hold/hook (Holdplayer, Acheck) (93G $12DC)
SPAhook_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAhook_table				; direction 0
	dw .1-SPAhook_table				; direction 1
	dw .2-SPAhook_table				; direction 2
	dw .3-SPAhook_table				; direction 3
	dw .4-SPAhook_table				; direction 4
	dw .5-SPAhook_table				; direction 5
	dw .6-SPAhook_table				; direction 6
	dw .7-SPAhook_table				; direction 7
	dw 0							; attributes
.0:	dw SPFhook,-30					; frame/time list for direction 0
.1:	dw SPFhook+2,-30				; frame/time list for direction 1
.2:	dw SPFhook+4,-30				; frame/time list for direction 2
.3:	dw SPFhook+6,-30				; frame/time list for direction 3
.4:	dw SPFhook+8,-30				; frame/time list for direction 4
.5:	dw SPFhook+10,-30				; frame/time list for direction 5
.6:	dw SPFhook+12,-30				; frame/time list for direction 6
.7:	dw SPFhook+14,-30				; frame/time list for direction 7
	assert SPAhook_table-SPAlist == SPAhook

SPAhook2		=	$1386			; (93G $130E)
SPAhook2_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAhook2_table			; direction 0
	dw .1-SPAhook2_table			; direction 1
	dw .2-SPAhook2_table			; direction 2
	dw .3-SPAhook2_table			; direction 3
	dw .4-SPAhook2_table			; direction 4
	dw .5-SPAhook2_table			; direction 5
	dw .6-SPAhook2_table			; direction 6
	dw .7-SPAhook2_table			; direction 7
	dw 0							; attributes
.0:	dw SPFhook,9,SPFhook+1,9,SPFhook,9,SPFhook+1,-9	; frame/time list for direction 0
.1:	dw SPFhook+2,9,SPFhook+3,9,SPFhook+2,9,SPFhook+3,-9	; frame/time list for direction 1
.2:	dw SPFhook+4,9,SPFhook+5,9,SPFhook+4,9,SPFhook+5,-9	; frame/time list for direction 2
.3:	dw SPFhook+6,9,SPFhook+7,9,SPFhook+6,9,SPFhook+7,-9	; frame/time list for direction 3
.4:	dw SPFhook+8,9,SPFhook+9,9,SPFhook+8,9,SPFhook+9,-9	; frame/time list for direction 4
.5:	dw SPFhook+10,9,SPFhook+11,9,SPFhook+10,9,SPFhook+11,-9	; frame/time list for direction 5
.6:	dw SPFhook+12,9,SPFhook+13,9,SPFhook+12,9,SPFhook+13,-9	; frame/time list for direction 6
.7:	dw SPFhook+14,9,SPFhook+15,9,SPFhook+14,9,SPFhook+15,-9	; frame/time list for direction 7
	assert SPAhook2_table-SPAlist == SPAhook2

SPAcatch		=	$1418			; player hit by a slow puck (93G $128A)
SPAcatch_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAcatch_table			; direction 0
	dw .1-SPAcatch_table			; direction 1
	dw .2-SPAcatch_table			; direction 2
	dw .3-SPAcatch_table			; direction 3
	dw .4-SPAcatch_table			; direction 4
	dw .5-SPAcatch_table			; direction 5
	dw .6-SPAcatch_table			; direction 6
	dw .7-SPAcatch_table			; direction 7
	dw 0							; attributes
.0:	dw SPFcatch,6,SPFcatch+1,-6		; frame/time list for direction 0
.1:	dw SPFcatch+2,6,SPFcatch+3,-6	; frame/time list for direction 1
.2:	dw SPFcatch+4,6,SPFcatch+5,-6	; frame/time list for direction 2
.3:	dw SPFcatch+6,6,SPFcatch+7,-6	; frame/time list for direction 3
.4:	dw SPFcatch+8,6,SPFcatch+9,-6	; frame/time list for direction 4
.5:	dw SPFcatch+10,6,SPFcatch+11,-6	; frame/time list for direction 5
.6:	dw SPFcatch+12,6,SPFcatch+13,-6	; frame/time list for direction 6
.7:	dw SPFcatch+14,6,SPFcatch+15,-6	; frame/time list for direction 7
	assert SPAcatch_table-SPAlist == SPAcatch

SPAbglass		=	$146A			; the puck shadow over the glass (93G $1232)
SPAbglass_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAbglass_table			; direction 0
	dw .0-SPAbglass_table			; direction 1
	dw .0-SPAbglass_table			; direction 2
	dw .0-SPAbglass_table			; direction 3
	dw .0-SPAbglass_table			; direction 4
	dw .0-SPAbglass_table			; direction 5
	dw .0-SPAbglass_table			; direction 6
	dw .0-SPAbglass_table			; direction 7
	dw 0							; attributes
	;frame/time list for direction 0
.0:	dw SPFbglass,8,SPFbglass+1,8,SPFbglass+2,8,SPFbglass+3,8,SPFbglass+4,-1000
	assert SPAbglass_table-SPAlist == SPAbglass

SPAgdive		=	$1490			; goalie dive (temp5 = 5 after a save) (93G $314)
SPAgdive_table:						;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAgdive_table			; direction 0
	dw .1-SPAgdive_table			; direction 1
	dw .2-SPAgdive_table			; direction 2
	dw .3-SPAgdive_table			; direction 3
	dw .4-SPAgdive_table			; direction 4
	dw .5-SPAgdive_table			; direction 5
	dw .6-SPAgdive_table			; direction 6
	dw .7-SPAgdive_table			; direction 7
	dw 0							; attributes
.0:	dw SPFgdive,8,SPFgdive+1,48,SPFgdive,-8	; frame/time list for direction 0
.1:	dw SPFgdive+2,8,SPFgdive+3,48,SPFgdive+2,-8	; frame/time list for direction 1
.2:	dw SPFgdive+4,8,SPFgdive+5,48,SPFgdive+4,-8	; frame/time list for direction 2
.3:	dw SPFgdive+6,8,SPFgdive+7,48,SPFgdive+6,-8	; frame/time list for direction 3
.4:	dw SPFgdive+8,8,SPFgdive+9,48,SPFgdive+8,-8	; frame/time list for direction 4
.5:	dw SPFgdive+10,8,SPFgdive+11,48,SPFgdive+10,-8	; frame/time list for direction 5
.6:	dw SPFgdive+12,8,SPFgdive+13,48,SPFgdive+12,-8	; frame/time list for direction 6
.7:	dw SPFgdive+14,8,SPFgdive+15,48,SPFgdive+14,-8	; frame/time list for direction 7
	assert SPAgdive_table-SPAlist == SPAgdive

SPAinjury1		=	$1502			; injured: no movement, no bounce (93G $1616)
SPAinjury1_table:					;table of the animation above: direction offsets, flags, frame/time lists
	dw .0-SPAinjury1_table			; direction 0
	dw .0-SPAinjury1_table			; direction 1
	dw .0-SPAinjury1_table			; direction 2
	dw .3-SPAinjury1_table			; direction 3
	dw .3-SPAinjury1_table			; direction 4
	dw .3-SPAinjury1_table			; direction 5
	dw .3-SPAinjury1_table			; direction 6
	dw .0-SPAinjury1_table			; direction 7
	dw 0							; attributes
	;frame/time list for direction 0
.0:	dw SPFfallback,20,SPFfallback+1,20,SPFfallback+2,1000,SPFfallback+2,-1000
	;frame/time list for direction 3
.3:	dw SPFfallback+16,20,SPFfallback+17,20,SPFfallback+18,1000,SPFfallback+18,-1000
	assert SPAinjury1_table-SPAlist == SPAinjury1
SPAListEnd:							;end of the SPA tables
