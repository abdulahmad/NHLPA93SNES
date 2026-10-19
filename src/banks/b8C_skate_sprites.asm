; Bank $8C: skate sprites (frame set 0) and the NHLPA logo. Files in ROM order (docs/file-map.md).

if pc() < $8C8000
	org $8C8000
endif

NHLPALogo:							;the NHLPA logo, packed (NHLPALogo.map.snesjim): 8 x 10 map, 128
									;colors at $A0, 53 tiles at $1A0; game setup and playoff screens
	incbin "../../Extracted/Graphics/NHLPALogo.map.snesjim"
NHLPALogoEnd:						; end of NHLPALogo
	assert NHLPALogoEnd-NHLPALogo == $45A

incsrc "../data/gfx/SpriteSet0.asm"
incsrc "../routines/video/checksso.asm"
incsrc "../routines/logic/chk4pass.asm"
