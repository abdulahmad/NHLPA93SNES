Credits:							;the title screen credit lines (length word, text); $FE ends the copyright
									;page, $FF a page, an empty string the list
	%String("$ 1992 Electronic Arts")
	%String("Licensed by Nintendo")
	%StringCC($FE)

	%String("Design adapted by")
	%String("Michael Brook")
	%String("Scott Orr")
	%String("Richard Hilleman")
	%StringCC($FF)

	%String("Technical Design by")
	%String("Jim Simmons")
	%StringCC($FF)

	%String("Programmed by")
	%String("Park Place Productions")
	%String("William Robinson")
	%StringCC($FF)

	%String("Graphics by")
	%String("George Simmons")
	%String("Brian O'Hara")
	%String("Curt Toumanian")
	%StringCC($FF)

	%String("Music and Sound by")
	%String("Rob Hubbard")
	%StringCC($FF)

	%String("Produced by")
	%String("Michael Brook")
	%StringCC($FF)

	%String("Assistant Producer")
	%String("Robert Zalot")
	%StringCC($FF)

	%String("Technical Directors")
	%String("Scott Cronce")
	%String("Tom DeBry")
	%StringCC($FF)

	%String("Testing by")
	%String("Yun Shin")
	%String("Steve Matulac")
	%String("Mike Rubinelli")
	%StringCC($FF)

	%String("Player Ratings by")
	%String("Igor Kuperman")
	%StringCC($FF)

	%String("Special Thanks to")
	%String("Bob Borgen")
	%String("Ted Saskin")
	%String("Ian Pulver")
	%String("Rob Blake")
	%String("John McIntyre")
	%StringCC($FF)
	dw 2							; empty: end of the credits
	%StringCC($FF)
	%StringCC($FF)
