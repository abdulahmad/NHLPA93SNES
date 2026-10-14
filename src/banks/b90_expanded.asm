; Bank $90: expanded. Included last. The stock build writes no bytes here.
; A team record that does not fit in bank $83, or a routine moved out of a full bank, is assembled here.

if pc() < $908000
	org $908000
endif
