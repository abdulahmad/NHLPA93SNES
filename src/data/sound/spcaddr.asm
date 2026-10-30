; SPC700 (APU RAM) addresses, used only by the sound uploads (bootsound.asm, gamesound.asm) and the
; SPC700 driver (spcdriver.asm). Equates only, no ROM bytes. Moved out of ram93s.asm.
SPCSAMPLEDIR	=	$2C00			; DSP sample directory (DIR = $2C)
SPCDRIVER		=	$0400			; SPC700 sound driver code (boot upload); the boot upload starts it here
SPCINSTR		=	$2B00			; instrument table of the boot set (6 bytes per instrument)
SPCBOOTSAMPLES	=	$2C30			; first BRR sample of the boot set
SPCSAMPLES		=	$2C50			; first BRR sample of the in-game set
SPCRESUME		=	$0800			;driver entry after the in-game sample upload (the boot upload starts the
									;driver at $0400)
SPCDRIVERSIZE	=	$26E7			; bytes of the SPC700 program (SPCDriver .. SPCDriverEnd)
BOOTSAMPLESIZE	=	$5271			; bytes of Extracted/Sound/bootsamples.brr
GAMESAMPLESIZE	=	$B814			; bytes of the in-game BRR samples (GameSamples)
