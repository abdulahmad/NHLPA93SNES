ClrPassBits:						;Clear the password bits
	stz.w pwddatabuffer
	stz.w pwddatabuffer+2
	stz.w pwddatabuffer+4
	stz.w pwddatabuffer+6
	stz.w pwddatabuffer+8
	stz.w pwddatabuffer+10
	stz.w pwddatabuffer+12
	stz.w pwddatabuffer+14
	rtl
