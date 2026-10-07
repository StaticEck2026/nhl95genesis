;
; NHL 95 segment queue. No ranges are confirmed.
; Drop lst/nhl95.bin and lst/nhl95.bin.lst in before the first segment.
; Do not reorder includes once a segment is matched.
;
; include Main95.asm
; include Ram95.asm
	dcb.b	$100000-*,$FF
