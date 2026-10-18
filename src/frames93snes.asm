; NHLPA 93 SNES animation (SPA) and sprite frame (SPF) equates, moved out of ram93snes.asm.
; Equates only, no ROM bytes. Named like their 93G module (frames93.asm).



; animations (offsets into the animation data; value in the comment)
; SPA values: offsets of the SPAlist tables (bank82_C000 asserts each one). named and ordered like the 68000
; frame tables
SPAgready		=	$0002			; SPAgready $2: goalie ready (loops)
SPAgready2		=	$0134			; SPAgready2 $134
SPAgglover		=	$0166			; SPAgglover $166: glove save (GoalieSaveList 0)
SPAgglovel		=	$0198			; SPAgglovel $198: glove save (GoalieSaveList 1)
SPAgstickr		=	$01CA			; SPAgstickr $20C: stick save (GoalieSaveList 4)
SPAgstickl		=	$01FC			; SPAgstickl $23E: stick save (GoalieSaveList 5)
SPAgstackr		=	$022E			; SPAgstackr $270: stack pad save (GoalieSaveList 2)
SPAgstackl		=	$0280			; SPAgstackl $2C2: stack pad save (GoalieSaveList 3)
SPAgswing		=	$02D2			; SPAgswing $386
SPAgskate		=	$0344			; SPAgskate $3F8: goalie skating
SPApflip		=	$03D6			; SPApflip $48A: puck spin
SPAglide		=	$0478			; SPAglide $52C: glide
SPAskatewp		=	$04AA			; SPAskatewp $55E
SPAskate		=	$055C			; SPAskate $5F0
SPAturnl		=	$060E			; SPAturnl $682
SPAturnr		=	$0640			; SPAturnr $6B4
SPAstop			=	$0672			; SPAstop $6E6: stop
SPApassf		=	$06C4			; SPApassf $738
SPApassb		=	$0736			; SPApassb $7AA
SPAshotf		=	$07A8			; SPAshotf $81C: forehand shot
SPAshotb		=	$08BA			; SPAshotb $94E: backhand shot
SPAglideback	=	$09CC			; SPAglideback $A80
SPAskateback	=	$09FE			; SPAskateback $AB2
SPAsweepchk		=	$0A90			; SPAsweepchk $B44: sweep check
SPAshoulderchkl	=	$0B02			; SPAshoulderchkl $BB6
SPAshoulderchkr	=	$0B34			; SPAshoulderchkr $BE8
SPAhipchkl		=	$0B66			; SPAhipchkl $C1A
SPAhipchkr		=	$0B98			; SPAhipchkr $C4C
SPAburst		=	$0BCA			; SPAburst $C7E: check button burst
SPAHold			=	$0BFC			; SPAHold $CB0: hold
SPAHold2		=	$0C2E			; SPAHold2 $CE2
SPAflail		=	$0C60			; SPAflail $D14
SPAfallfwd		=	$0C92			; SPAfallfwd $D46
SPAfallback		=	$0D44			; SPAfallback $DF8
SPAcelebrate	=	$0DF6			; SPAcelebrate $EAA
SPApump			=	$0E68			; SPApump $F1C
SPAfight		=	$0EDA			; SPAfight $F8E: fight
SPAfgrab		=	$0F0C			; SPAfgrab $FC0
SPAfheld		=	$0F2E			; SPAfheld $FE2
SPAfhigh		=	$0F50			; SPAfhigh $1004
SPAflow			=	$0F82			; SPAflow $1036
SPAfhith		=	$0FB4			; SPAfhith $1068
SPAfhitl		=	$0FD6			; SPAfhitl $108A
SPAffall		=	$0FF8			; SPAffall $10AC
SPAwallright	=	$101A			; SPAwallright $1128
SPAwallleft		=	$1058			; SPAwallleft $1166
SPAfaceoff		=	$1096			; SPAfaceoff $11A4: faceoff pull
SPAfaceoffr		=	$10C0			; SPAfaceoffr $11CE: faceoff ready
SPAsiren		=	$10DA			; SPAsiren $11E8: goal siren on the puck shadow
SPAstanley		=	$1124			; SPAstanley $1258
SPAfinjury		=	$1156			; SPAfinjury $10CE: fight injury (fight loser down)
SPAflip			=	$11B0			; SPAflip $1524: third fall animation (flip)
SPAstumble		=	$12A2			; SPAstumble $13A0: stumble instead of a fall
SPAhook			=	$1354			; SPAhook $12DC: hold/hook (Holdplayer, Acheck)
SPAhook2		=	$1386			; SPAhook2 $130E
SPAcatch		=	$1418			; SPAcatch $128A: player hit by a slow puck
SPAbglass		=	$146A			; SPAbglass $1232: the puck shadow over the glass
SPAgdive		=	$1490			; SPAgdive $314: goalie dive (temp5 = 5 after a save)
SPAinjury1		=	$1502			;SPAinjury1 $1616: injured: no movement, no bounce (SNES frames differ
									;from )
; sprite frame bases (SPF): first frame of each group in the SNES sprite set. named like the 68000 frame
; tables; frames from SPFpuck on are one lower than (no SPFreplay frame) and the goalie and 93-only groups are
; laid out differently
SPFskatewp		=	1				; 1
SPFskate		=	41				; 41
SPFturnl		=	81				; 81
SPFturnr		=	89				; 89
SPFswing		=	97				; 97
SPFstop			=	145				; 145
SPFskateb		=	161				; 161
SPFcelebrate	=	185				; 185
SPFpump			=	201				; 201
SPFcup			=	217				; 217
SPFhipl			=	225				; 225
SPFhipr			=	233				; 233
SPFshoulderl	=	241				; 241
SPFshoulderr	=	249				; 249
SPFsweep		=	257				; 257
SPFfallback		=	273				; 273
SPFfallfwd		=	305				; 305
SPFduck			=	337				; 337
SPFhold			=	345				; 345
SPFgloves		=	353				; 353
SPFfight		=	354				; 354
SPFfinjury		=	371				; 371
SPFPen			=	377				; 377
SPFarrow		=	384				; 384
SPFpad			=	390				; 390
SPFpuck			=	393				; 394
SPFgoal			=	404				; 405
SPFGoalie		=	406				; 407
SPFgdive		=	643				; 519
SPFgready		=	627				; 539
SPFSiren		=	518				; 555
SPFcatch		=	606				; 569
SPFhook			=	590				; 585
SPFstumble		=	566				; 601
SPFflip			=	558				; 625
SPFbglass		=	622				; 645
SPFfaceoff		=	532				; big faceoff sprites (frame 1; checkfo adds SPFfaceoff-1)
SPFsmallfont	=	542				; pad-label glyphs (the glyph index is added)
SPFzamboni		=	557				; zamboni
SPFcrowd		=	659				; crowd and penalty-box sprites; first frame stored as 6-byte pieces
