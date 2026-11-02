; NHLPA Hockey '93 (SNES) - top level: hardware registers, macros and RAM names, then one file per bank in ROM
; order (docs/file-map.md). LoROM + FastROM (map mode $30), 4 Mbit, 16 banks mapped at $80-$8F.
; Bank $90 is not in the default build; docs/adding-a-team.md says how to add it.
asar 1.91
lorom
check bankcross off
incsrc "inc/snes_regs.asm"
incsrc "macros/snes93.mac"
incsrc "ram93s.asm"
incsrc "data/sound/spcaddr.asm"
incsrc "banks/b80_engine_game.asm"
incsrc "banks/b81_samples.asm"
incsrc "banks/b82_samples_rink.asm"
incsrc "banks/b83_teams_rink.asm"
incsrc "banks/b84_spriteframes_scouting_stats.asm"
incsrc "banks/b85_spriteframes_title.asm"
incsrc "banks/b86_sound_songs.asm"
incsrc "banks/b87_spriteframes.asm"
incsrc "banks/b88_spriteframes_setup_playoffs.asm"
incsrc "banks/b89_spriteframes_refs_replay.asm"
incsrc "banks/b8A_spriteframes.asm"
incsrc "banks/b8B_spriteframes.asm"
incsrc "banks/b8C_spriteframes_logos.asm"
incsrc "banks/b8D_spriteframes_fonts.asm"
incsrc "banks/b8E_spriteframes.asm"
incsrc "banks/b8F_spriteframes_hud_flow.asm"
