; Bank $8C: skating sprites (set 0) and the NHLPA logo. Files in ROM order (docs/file-map.md).

if pc() < $8C8000
	org $8C8000
endif

NHLPALogo:							;the NHLPA logo, packed (NHLPALogo.map.sjim): 8 x 10 map, 128
									;colors at $A0, 53 tiles at $1A0; game setup and playoff screens
	incbin "../../Extracted/Graphics/NHLPALogo.map.sjim"

SpriteSet0:							;frame set 0 (SPFskatewp, SPFskate, SPFturnl, SPFturnr): frames 1-96
	incbin "../../Extracted/Graphics/Sprites/Sprites001_096.sanim"
incsrc "../routines/video/objects/checksso.asm"
incsrc "../routines/logic/puck/chk4pass.asm"
