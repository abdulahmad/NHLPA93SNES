; NHLPA Hockey '93 (SNES) - top level: macros, hardware registers and RAM names, then one file per bank in ROM
; order (docs/file-map.md). LoROM + FastROM (map mode $30), 4 Mbit, 16 banks mapped at $80-$8F.
; Bank $90 is not in the default build; docs/adding-a-team.md says how to add it.
asar 1.91
lorom
check bankcross off
incsrc "macros/snes93.mac"
incsrc "ram93s.asm"
incsrc "banks/b80_engine.asm"
incsrc "banks/b81_samples.asm"
incsrc "banks/b82_samples_rink.asm"
incsrc "banks/b83_teams.asm"
incsrc "banks/b84_sprites_scouting.asm"
incsrc "banks/b85_sprites_title.asm"
incsrc "banks/b86_sound.asm"
incsrc "banks/b87_sprites_refs.asm"
incsrc "banks/b88_sprites_teamblocks.asm"
incsrc "banks/b89_sprites_replay.asm"
incsrc "banks/b8A_sprites.asm"
incsrc "banks/b8B_sprites.asm"
incsrc "banks/b8C_sprites.asm"
incsrc "banks/b8D_sprites.asm"
incsrc "banks/b8E_sprites.asm"
incsrc "banks/b8F_frontend.asm"
