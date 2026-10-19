asstab:							;The assignment routines that updateplayers calls, by assignment number. There is no
									;"do nothing" entry, so assignment numbers from assscore on are one lower than in 92.
	dd rtss

adefo	=	$01						;defensive player on offense (assdefo)
	assert (pc()-asstab)/4 == adefo
	dd assdefo
adefd	=	$02						;defensive player on defense
	assert (pc()-asstab)/4 == adefd
	dd assdefd
awingd	=	$03						;winger on defense
	assert (pc()-asstab)/4 == awingd
	dd asswingd
awingo	=	$04						;winger on offense
	assert (pc()-asstab)/4 == awingo
	dd asswingo
acenterd	=	$05					;center on defense
	assert (pc()-asstab)/4 == acenterd
	dd asscenterd
acentero	=	$06					;center on offense
	assert (pc()-asstab)/4 == acentero
	dd asscentero

ascore	=	$07						;celebrating a goal
	assert (pc()-asstab)/4 == ascore
	dd assscore
astanley	=	$08					;skating with the Stanley Cup overhead
	assert (pc()-asstab)/4 == astanley
	dd assstanley
aeben	=	$09						;exit the bench area
	assert (pc()-asstab)/4 == aeben
	dd asseben
aepen	=	$0A						;exit the penalty area
	assert (pc()-asstab)/4 == aepen
	dd assepen
abench	=	$0B						;go to the bench
	assert (pc()-asstab)/4 == abench
	dd assbench
apenalty	=	$0C					;go to the penalty box
	assert (pc()-asstab)/4 == apenalty
	dd asspenalty
adopen	=	$0D						;add the player to the penalty box
	assert (pc()-asstab)/4 == adopen
	dd assdopen

agoalie	=	$0E						;goalie logic
	assert (pc()-asstab)/4 == agoalie
	dd assgoalie
agoalietopuck	=	$0F				;goalie skates out to a loose puck
	assert (pc()-asstab)/4 == agoalietopuck
	dd assgoalietopuck
apuckc	=	$10						;puck handler
	assert (pc()-asstab)/4 == apuckc
	dd asspuckc
anearest	=	$11					;player nearest the puck without it
	assert (pc()-asstab)/4 == anearest
	dd assnearest
ashoot	=	$12						;computer shooting
	assert (pc()-asstab)/4 == ashoot
	dd assshoot
apassrec	=	$13					;catching a pass
	assert (pc()-asstab)/4 == apassrec
	dd asspassrec
afight	=	$14						;fighting
	assert (pc()-asstab)/4 == afight
	dd assfight
afwatch	=	$15						;watching a fight
	assert (pc()-asstab)/4 == afwatch
	dd assfwatch
afaceoff	=	$16					;wait until the faceoff is over
	assert (pc()-asstab)/4 == afaceoff
	dd assfaceoff
afaceoffpl	=	$17					;players taking part in the faceoff
	assert (pc()-asstab)/4 == afaceoffpl
	dd assfaceoffpl

pnorm	=	$18						;puck object: normal movement (pucknorm)
	assert (pc()-asstab)/4 == pnorm
	dd pucknorm
pshad	=	$19						;puck object: puck shadow
	assert (pc()-asstab)/4 == pshad
	dd puckshadow
pnothing	=	$1A					;puck object: just slides along
	assert (pc()-asstab)/4 == pnothing
	dd pucknothing
pfaceoff	=	$1B					;puck object: faceoff start
	assert (pc()-asstab)/4 == pfaceoff
	dd puckfaceoff
pfaceoff2	=	$1C					;puck object: faceoff control and setup
	assert (pc()-asstab)/4 == pfaceoff2
	dd puckfaceoff2
