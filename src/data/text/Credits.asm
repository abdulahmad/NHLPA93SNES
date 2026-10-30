Credits:							;the title screen credit lines (length word, text); $FE ends the copyright
									;page, $FF a page, an empty string the list
	%String("$ 1992 Electronic Arts")
	%String("Licensed by Nintendo")
	%StringCC(CC_LastPage)

	%String("Design adapted by")
	%String("Michael Brook")
	%String("Scott Orr")
	%String("Richard Hilleman")
	%StringCC(CC_PageEnd)

	%String("Technical Design by")
	%String("Jim Simmons")
	%StringCC(CC_PageEnd)

	%String("Programmed by")
	%String("Park Place Productions")
	%String("William Robinson")
	%StringCC(CC_PageEnd)

	%String("Graphics by")
	%String("George Simmons")
	%String("Brian O'Hara")
	%String("Curt Toumanian")
	%StringCC(CC_PageEnd)

	%String("Music and Sound by")
	%String("Rob Hubbard")
	%StringCC(CC_PageEnd)

	%String("Produced by")
	%String("Michael Brook")
	%StringCC(CC_PageEnd)

	%String("Assistant Producer")
	%String("Robert Zalot")
	%StringCC(CC_PageEnd)

	%String("Technical Directors")
	%String("Scott Cronce")
	%String("Tom DeBry")
	%StringCC(CC_PageEnd)

	%String("Testing by")
	%String("Yun Shin")
	%String("Steve Matulac")
	%String("Mike Rubinelli")
	%StringCC(CC_PageEnd)

	%String("Player Ratings by")
	%String("Igor Kuperman")
	%StringCC(CC_PageEnd)

	%String("Special Thanks to")
	%String("Bob Borgen")
	%String("Ted Saskin")
	%String("Ian Pulver")
	%String("Rob Blake")
	%String("John McIntyre")
	%StringCC(CC_PageEnd)
	dw 2							; empty: end of the credits
	%StringCC(CC_PageEnd)
	%StringCC(CC_PageEnd)
