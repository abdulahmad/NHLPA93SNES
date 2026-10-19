RosterAnimScripts:					;The roster animation scripts: animation and facing steps
	dw .s0-RosterAnimScripts,.s1-RosterAnimScripts,.s2-RosterAnimScripts,.s3-RosterAnimScripts,.s4-RosterAnimScripts,.s5-RosterAnimScripts,.s6-RosterAnimScripts,.s7-RosterAnimScripts
		;goalie: ready stance, then a glove save to the right
.s0:	dw SPAgready2,3,SPAgready2,4,SPAgready2,5,SPAgready2,-4,SPAgglover,4,SPAgready2,4,SPAgglovel,4,SPAgready2,4,0
		;goalie: ready stance, then a glove save to the left
.s5:	dw SPAgready2,3,SPAgready2,4,SPAgready2,5,SPAgready2,-4,SPAgglovel,4,SPAgready2,4,SPAgready2,4,0
		;skater: skate, celebrate, glide
.s1:	dw SPAskate,3,SPAskate,4,SPAcelebrate,-5,SPAcelebrate,4,SPAglide,4,SPAglide,4,0
		;skater with the puck: skate, glide
.s2:	dw SPAskatewp,4,SPAskatewp,4,SPAskatewp,-4,SPAglide,4,SPAglide,4,0
		;skater with the puck: skate, wrist shot
.s3:	dw SPAskatewp,5,SPAskatewp,5,SPAshotf,-5,SPAglide,5,SPAglide,5,0
		;skater with the puck: skate, stumble, shot
.s4:	dw SPAskatewp,3,SPAskatewp,3,SPAstumble,-3,SPAshotf,3,SPAglide,3,SPAglide,3,0
		;skater: skate with a sweep check
.s6:	dw SPAskate,4,SPAskate,5,SPAsweepchk,-5,SPAsweepchk,5,SPAskate,5,SPAsweepchk,5,SPAglide,5,SPAglide,5,0
		;skater: fight sequence, high and low punches
.s7:	dw SPAskate,3,SPAskate,2,SPAfight,-2,SPAfhigh,2,SPAflow,2,SPAfhigh,2,SPAflow,2,0
