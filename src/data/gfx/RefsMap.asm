RefsMap:							;the ref window frames, 7 frames of 8 x 7 words (Refs.snesmap);
									;PushRef copies frame d0 (+$70 each)
	incbin "../../../Extracted/Graphics/Refs.snesmap"
RefsMapEnd:							; end of RefsMap
	assert RefsMapEnd-RefsMap == 7*$70
