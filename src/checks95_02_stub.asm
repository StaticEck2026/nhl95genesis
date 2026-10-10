;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	checks95_02 segment stub. Retail $080BEA-$08282D.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$80BEA

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $080BEA-$08282D, read from lst/nhl95.bin.
Acheck = $AA46			;IDA: loc_AA46. used at $817FE, $81948 (setup95_01)
burstchk = $AA7A		;IDA: loc_AA7A. used at $817D4, $8191E (setup95_01)
sfx = $677AC			;IDA: sub_677AC. used at $81AE2, $82026, $82218 (sound95_01)
Sweepcheck = $7B08A		;IDA: loc_7B08A. used at $81F0C (collide95_01)
checkpuckcoll = $7B51A		;no IDA label. used at $81306 (collide95_01)
vtoa = $7C586			;IDA: sub_7C586. used at $815E6, $8168A, $816CA, $817B6, $818CA, $81E98, $81EB2, $81ED6, $8240A, $82546, $82578, $8271E, $82768 (video95_03)
randomd0s = $7C62E		;IDA: sub_7C62E. used at $80CD0, $80CE2, $80FC4, $80FD6, $824EE (video95_03)
randomd0 = $7C63A		;IDA: sub_7C63A. used at $8174C, $81860, $81A14, $81CFA, $824CA, $825E4, $82646, $82656 (video95_03)
GetHot = $7C672			;IDA: sub_7C672. used at $81276, $81C18, $81E78 (video95_03)
ReadGoaliePulled = $7CB0A	;IDA: sub_7CB0A. used at $81088, $81B5E, $8227C (video95_03)
chkpk = $7D884			;no IDA label. used at $82460 (video95_03)
chkpk2 = $7D894			;IDA: sub_7D894. used at $81CE6 (video95_03)
assgoaliecpu = $7FDA4		;no IDA label. used at $81B3E (checks95_01)
rtss21 = $809FC			;no IDA label. used at $80BF0, $80C08, $80E6C, $80E86, $80EBE, $81208, $81212 (assign95_01)
PuckOnAttackHalf = $82E88	;IDA: sub_82E88. used at $819E2 (onetimer95)
a2offsides = $83152		;no IDA label. used at $81498 (checks95_03)
PuckcIsGoalie = $836AC		;no IDA label. used at $81112, $8113C. 95 only: eq when the puck carrier is a goalie (collide95_02)
dopass = $844F8			;IDA: loc_844F8. used at $824AC, $8277E (input95_01)
compshoot = $84FB6		;no IDA label. used at $82318, $8249A, $82500, $82632 (input95_01)
AddPenalty = $89140		;IDA: sub_89140. used at $814E0 (penalty95)
AddPenalty2 = $8916E		;IDA: sub_8916E. used at $812E0 (penalty95)
puckIChk = $89ADA		;no IDA label. used at $8129E (data95_02)
ChkOffsides = $89B3A		;no IDA label. used at $812A4 (data95_02)
checkob = $89F5C		;IDA: sub_89F5C. used at $822B0 (data95_02)
AutoLineChange = $8A4FC		;no IDA label. used at $822B6 (checks95_05)
SetSPA = $8BC9A			;IDA: sub_8BC9A. used at $8134C, $81722, $81836, $8219A (checks95_06)
doplayeracc = $8BCFA		;IDA: loc_8BCFA. used at $81218, $816F4, $81F06 (checks95_06)
CanCheckStart = $8D452		;no IDA label. used at $8170E, $81822. 95 only: ne when a joystick player may start a check (replay95)
SkatePath = $9DC18		;no IDA label. used at $82358 (title95_01)
ShootoutShootCheck = $9DCA0	;no IDA label. used at $8230E (title95_01)
UpdatePenaltyShotEnd = $9EC5E	;no IDA label. used at $8122A (checks95_07)

; Main segment code
	include	checks95_02.asm
