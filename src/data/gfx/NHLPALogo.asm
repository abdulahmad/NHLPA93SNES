NHLPALogo:							;the NHLPA logo, packed (NHLPALogo.map.snesjim): 8 x 10 map, 128
									;colours at $A0, 53 tiles at $1A0; game setup and playoff screens
	incbin "../../../Extracted/Graphics/NHLPALogo.map.snesjim"
NHLPALogoEnd:
	assert NHLPALogoEnd-NHLPALogo == $45A
