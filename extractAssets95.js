// NHL 95 asset extractor.
// Usage: node extractAssets95.js lst/nhl95.bin
// Add a slice only after the listing label and the retail range are confirmed.
const fs = require('fs');
const path = require('path');
const romPath = process.argv[2] || 'lst/nhl95.bin';
if (!fs.existsSync(romPath)) {
  console.error('Missing ' + romPath + '. Put the IDA ROM at lst/nhl95.bin first.');
  process.exit(1);
}
// Slices: name, folder under Extracted, start, end (exclusive).
const assets = [
    // NHL 95 team palettes, src/teamdata95.asm .pad of each team block (block + $C): home then visitor, 32 bytes each, in ROM order.
    // Every one differs from 94, so each is the 94 file stem (93 stem for MIN / LI / NY / TBY) with 95 added.
    { name: 'ASEh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000007EE, end: 0x0000080E }, // ASE home
    { name: 'ASEv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000080E, end: 0x0000082E }, // ASE visitor
    { name: 'ASWh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00000ABE, end: 0x00000ADE }, // ASW home
    { name: 'ASWv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00000ADE, end: 0x00000AFE }, // ASW visitor
    { name: 'ANHh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00000D72, end: 0x00000D92 }, // ANH home
    { name: 'ANHv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00000D92, end: 0x00000DB2 }, // ANH visitor
    { name: 'BOSh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00001036, end: 0x00001056 }, // BOS home
    { name: 'BOSv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00001056, end: 0x00001076 }, // BOS visitor
    { name: 'BUFh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00001310, end: 0x00001330 }, // BUF home
    { name: 'BUFv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00001330, end: 0x00001350 }, // BUF visitor
    { name: 'CGYh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000015EC, end: 0x0000160C }, // CGY home
    { name: 'CGYv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000160C, end: 0x0000162C }, // CGY visitor
    { name: 'CHIh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000018CA, end: 0x000018EA }, // CHI home
    { name: 'CHIv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000018EA, end: 0x0000190A }, // CHI visitor
    { name: 'DETh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00001BAA, end: 0x00001BCA }, // DET home
    { name: 'DETv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00001BCA, end: 0x00001BEA }, // DET visitor
    { name: 'EDMh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00001EA8, end: 0x00001EC8 }, // EDM home
    { name: 'EDMv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00001EC8, end: 0x00001EE8 }, // EDM visitor
    { name: 'FLAh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000219A, end: 0x000021BA }, // FLA home
    { name: 'FLAv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000021BA, end: 0x000021DA }, // FLA visitor
    { name: 'HFDh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000247A, end: 0x0000249A }, // HFD home
    { name: 'HFDv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000249A, end: 0x000024BA }, // HFD visitor
    { name: 'LAh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000276E, end: 0x0000278E }, // LA home
    { name: 'LAv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000278E, end: 0x000027AE }, // LA visitor
    { name: 'MINh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00002A30, end: 0x00002A50 }, // DAL home
    { name: 'MINv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00002A50, end: 0x00002A70 }, // DAL visitor
    { name: 'MTLh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00002D04, end: 0x00002D24 }, // MTL home
    { name: 'MTLv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00002D24, end: 0x00002D44 }, // MTL visitor
    { name: 'NJh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00002FF4, end: 0x00003014 }, // NJ home
    { name: 'NJv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00003014, end: 0x00003034 }, // NJ visitor
    { name: 'LIh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000032E6, end: 0x00003306 }, // NYI home
    { name: 'LIv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00003306, end: 0x00003326 }, // NYI visitor
    { name: 'NYh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000035D2, end: 0x000035F2 }, // NYR home
    { name: 'NYv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000035F2, end: 0x00003612 }, // NYR visitor
    { name: 'OTWh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000038B4, end: 0x000038D4 }, // OTW home
    { name: 'OTWv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000038D4, end: 0x000038F4 }, // OTW visitor
    { name: 'PHIh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00003BAA, end: 0x00003BCA }, // PHI home
    { name: 'PHIv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00003BCA, end: 0x00003BEA }, // PHI visitor
    { name: 'PITh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00003E88, end: 0x00003EA8 }, // PIT home
    { name: 'PITv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00003EA8, end: 0x00003EC8 }, // PIT visitor
    { name: 'QUEh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004178, end: 0x00004198 }, // QUE home
    { name: 'QUEv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004198, end: 0x000041B8 }, // QUE visitor
    { name: 'SJh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000445E, end: 0x0000447E }, // SJ home
    { name: 'SJv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000447E, end: 0x0000449E }, // SJ visitor
    { name: 'STLh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004722, end: 0x00004742 }, // STL home
    { name: 'STLv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004742, end: 0x00004762 }, // STL visitor
    { name: 'TBYh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004A0A, end: 0x00004A2A }, // TB home
    { name: 'TBYv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004A2A, end: 0x00004A4A }, // TB visitor
    { name: 'TORh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004CC2, end: 0x00004CE2 }, // TOR home
    { name: 'TORv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004CE2, end: 0x00004D02 }, // TOR visitor
    { name: 'VANh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004FB4, end: 0x00004FD4 }, // VAN home
    { name: 'VANv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00004FD4, end: 0x00004FF4 }, // VAN visitor
    { name: 'WPGh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x0000529A, end: 0x000052BA }, // WPG home
    { name: 'WPGv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x000052BA, end: 0x000052DA }, // WPG visitor
    { name: 'WSHh95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00005562, end: 0x00005582 }, // WSH home
    { name: 'WSHv95.pal', folder: 'NHL95/Graphics/Pals', start: 0x00005582, end: 0x000055A2 }, // WSH visitor
    // NHL 95 revframetbl, src/frames95.asm after the SPA tables: one word per sprite frame (1057), the frame RestoreReplayFrame shows for a reverse angle replay.
    // 94 kept it at the end of graphics94 (NHL94/Graphics/revframetbl.bin, 880 words).
    { name: 'revframetbl.bin', folder: 'NHL95/Graphics', start: 0x00008596, end: 0x00008DD8 }, // revframetbl
    // NHL 95 sound driver data, src/sounddrv95.asm: the Z80 program ($BD86, $1B63 bytes loaded by SndLoadZ80, plus its last byte $FF),
    // then the items of the sound bank at $D8EC (SoundBanks) in bank order, named by item type and id.
    { name: 'z80_snd_drv95.bin', folder: 'NHL95/Sound', start: 0x0000BD86, end: 0x0000D8EA }, // Z80Program
    { name: 'snd95_patch_00.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB22, end: 0x0000DB27 }, // patch 0
    { name: 'snd95_patch_01.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB27, end: 0x0000DB2C }, // patch 1
    { name: 'snd95_patch_02.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB2C, end: 0x0000DB31 }, // patch 2
    { name: 'snd95_patch_03.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB31, end: 0x0000DB36 }, // patch 3
    { name: 'snd95_patch_04.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB36, end: 0x0000DB3B }, // patch 4
    { name: 'snd95_patch_05.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB3B, end: 0x0000DB40 }, // patch 5
    { name: 'snd95_patch_06.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB40, end: 0x0000DB45 }, // patch 6
    { name: 'snd95_patch_07.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB45, end: 0x0000DB4A }, // patch 7
    { name: 'snd95_patch_08.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB4A, end: 0x0000DB4F }, // patch 8
    { name: 'snd95_patch_09.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB4F, end: 0x0000DB54 }, // patch 9
    { name: 'snd95_patch_0A.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB54, end: 0x0000DB59 }, // patch 10
    { name: 'snd95_patch_0B.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB59, end: 0x0000DB80 }, // patch 11
    { name: 'snd95_patch_0C.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB80, end: 0x0000DB85 }, // patch 12
    { name: 'snd95_patch_0D.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DB85, end: 0x0000DBAC }, // patch 13
    { name: 'snd95_patch_0E.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DBAC, end: 0x0000DBD3 }, // patch 14
    { name: 'snd95_patch_11.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DBD3, end: 0x0000DBFA }, // patch 17
    { name: 'snd95_patch_13.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DBFA, end: 0x0000DC0A }, // patch 19
    { name: 'snd95_patch_14.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DC0A, end: 0x0000DC1A }, // patch 20
    { name: 'snd95_patch_15.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DC1A, end: 0x0000DC41 }, // patch 21
    { name: 'snd95_patch_16.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DC41, end: 0x0000DC68 }, // patch 22
    { name: 'snd95_patch_18.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DC68, end: 0x0000DC8F }, // patch 24
    { name: 'snd95_patch_19.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DC8F, end: 0x0000DCB6 }, // patch 25
    { name: 'snd95_patch_1B.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DCB6, end: 0x0000DCDD }, // patch 27
    { name: 'snd95_patch_1C.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DCDD, end: 0x0000DD04 }, // patch 28
    { name: 'snd95_patch_1D.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD04, end: 0x0000DD2B }, // patch 29
    { name: 'snd95_patch_33.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD2B, end: 0x0000DD30 }, // patch 51
    { name: 'snd95_patch_36.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD30, end: 0x0000DD35 }, // patch 54
    { name: 'snd95_patch_38.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD35, end: 0x0000DD3A }, // patch 56
    { name: 'snd95_patch_39.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD3A, end: 0x0000DD3F }, // patch 57
    { name: 'snd95_patch_3B.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD3F, end: 0x0000DD44 }, // patch 59
    { name: 'snd95_patch_3D.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD44, end: 0x0000DD49 }, // patch 61
    { name: 'snd95_patch_3E.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD49, end: 0x0000DD70 }, // patch 62
    { name: 'snd95_patch_3F.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD70, end: 0x0000DD97 }, // patch 63
    { name: 'snd95_patch_40.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DD97, end: 0x0000DDBE }, // patch 64
    { name: 'snd95_patch_41.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DDBE, end: 0x0000DDC3 }, // patch 65
    { name: 'snd95_patch_42.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DDC3, end: 0x0000DDC8 }, // patch 66
    { name: 'snd95_patch_43.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DDC8, end: 0x0000DDCD }, // patch 67
    { name: 'snd95_patch_44.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DDCD, end: 0x0000DDD2 }, // patch 68
    { name: 'snd95_patch_45.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DDD2, end: 0x0000DDF9 }, // patch 69
    { name: 'snd95_patch_46.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DDF9, end: 0x0000DDFE }, // patch 70
    { name: 'snd95_patch_47.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DDFE, end: 0x0000DE25 }, // patch 71
    { name: 'snd95_patch_48.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DE25, end: 0x0000DE2A }, // patch 72
    { name: 'snd95_patch_49.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DE2A, end: 0x0000DE51 }, // patch 73
    { name: 'snd95_sample_00.bin', folder: 'NHL95/Sound/Bank', start: 0x0000DE51, end: 0x0000FF94 }, // sample 0
    { name: 'snd95_sample_01.bin', folder: 'NHL95/Sound/Bank', start: 0x0000FF94, end: 0x000101BB }, // sample 1
    { name: 'snd95_sample_02.bin', folder: 'NHL95/Sound/Bank', start: 0x000101BB, end: 0x00012286 }, // sample 2
    { name: 'snd95_sample_03.bin', folder: 'NHL95/Sound/Bank', start: 0x00012286, end: 0x00012AE9 }, // sample 3
    { name: 'snd95_sample_04.bin', folder: 'NHL95/Sound/Bank', start: 0x00012AE9, end: 0x000134EC }, // sample 4
    { name: 'snd95_sample_05.bin', folder: 'NHL95/Sound/Bank', start: 0x000134EC, end: 0x000143F5 }, // sample 5
    { name: 'snd95_sample_06.bin', folder: 'NHL95/Sound/Bank', start: 0x000143F5, end: 0x00015318 }, // sample 6
    { name: 'snd95_sample_07.bin', folder: 'NHL95/Sound/Bank', start: 0x00015318, end: 0x000161DB }, // sample 7
    { name: 'snd95_sample_08.bin', folder: 'NHL95/Sound/Bank', start: 0x000161DB, end: 0x000172AE }, // sample 8
    { name: 'snd95_sample_09.bin', folder: 'NHL95/Sound/Bank', start: 0x000172AE, end: 0x000175DD }, // sample 9
    { name: 'snd95_sample_0A.bin', folder: 'NHL95/Sound/Bank', start: 0x000175DD, end: 0x00017930 }, // sample 10
    { name: 'snd95_sample_0B.bin', folder: 'NHL95/Sound/Bank', start: 0x00017930, end: 0x00018EF2 }, // sample 11
    { name: 'snd95_sample_0C.bin', folder: 'NHL95/Sound/Bank', start: 0x00018EF2, end: 0x00019F37 }, // sample 12
    { name: 'snd95_sample_0E.bin', folder: 'NHL95/Sound/Bank', start: 0x00019F37, end: 0x00023AFA }, // sample 14
    { name: 'snd95_sample_10.bin', folder: 'NHL95/Sound/Bank', start: 0x00023AFA, end: 0x00032723 }, // sample 16
    { name: 'snd95_sample_11.bin', folder: 'NHL95/Sound/Bank', start: 0x00032723, end: 0x00034C4B }, // sample 17
    { name: 'snd95_sample_13.bin', folder: 'NHL95/Sound/Bank', start: 0x00034C4B, end: 0x0003A419 }, // sample 19
    { name: 'snd95_sample_15.bin', folder: 'NHL95/Sound/Bank', start: 0x0003A419, end: 0x0003C2E2 }, // sample 21
    { name: 'snd95_sample_16.bin', folder: 'NHL95/Sound/Bank', start: 0x0003C2E2, end: 0x00049365 }, // sample 22
    { name: 'snd95_sample_17.bin', folder: 'NHL95/Sound/Bank', start: 0x00049365, end: 0x0004DB35 }, // sample 23
    { name: 'snd95_sample_18.bin', folder: 'NHL95/Sound/Bank', start: 0x0004DB35, end: 0x0004F038 }, // sample 24
    { name: 'snd95_sample_19.bin', folder: 'NHL95/Sound/Bank', start: 0x0004F038, end: 0x00050B7B }, // sample 25
    { name: 'snd95_sample_1B.bin', folder: 'NHL95/Sound/Bank', start: 0x00050B7B, end: 0x0005239D }, // sample 27
    { name: 'snd95_sample_1D.bin', folder: 'NHL95/Sound/Bank', start: 0x0005239D, end: 0x000525CF }, // sample 29
    { name: 'snd95_song_00.bin', folder: 'NHL95/Sound/Bank', start: 0x000525CF, end: 0x00056CCA }, // song 0
    { name: 'snd95_song_01.bin', folder: 'NHL95/Sound/Bank', start: 0x00056CCA, end: 0x0005984C }, // song 1
    { name: 'snd95_song_02.bin', folder: 'NHL95/Sound/Bank', start: 0x0005984C, end: 0x0005CDD3 }, // song 2
    { name: 'snd95_song_03.bin', folder: 'NHL95/Sound/Bank', start: 0x0005CDD3, end: 0x00060D06 }, // song 3
    { name: 'snd95_song_04.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D06, end: 0x00060D12 }, // song 4
    { name: 'snd95_song_05.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D12, end: 0x00060D1E }, // song 5
    { name: 'snd95_song_06.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D1E, end: 0x00060D2A }, // song 6
    { name: 'snd95_song_07.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D2A, end: 0x00060D36 }, // song 7
    { name: 'snd95_song_08.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D36, end: 0x00060D42 }, // song 8
    { name: 'snd95_song_09.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D42, end: 0x00060D4E }, // song 9
    { name: 'snd95_song_0A.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D4E, end: 0x00060D5A }, // song 10
    { name: 'snd95_song_0B.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D5A, end: 0x00060D66 }, // song 11
    { name: 'snd95_song_0E.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D66, end: 0x00060D74 }, // song 14
    { name: 'snd95_song_10.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D74, end: 0x00060D82 }, // song 16
    { name: 'snd95_song_11.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D82, end: 0x00060D8E }, // song 17
    { name: 'snd95_song_13.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D8E, end: 0x00060D9A }, // song 19
    { name: 'snd95_song_15.bin', folder: 'NHL95/Sound/Bank', start: 0x00060D9A, end: 0x00060DA6 }, // song 21
    { name: 'snd95_song_16.bin', folder: 'NHL95/Sound/Bank', start: 0x00060DA6, end: 0x00060E0A }, // song 22
    { name: 'snd95_song_17.bin', folder: 'NHL95/Sound/Bank', start: 0x00060E0A, end: 0x00060E5E }, // song 23
    { name: 'snd95_song_18.bin', folder: 'NHL95/Sound/Bank', start: 0x00060E5E, end: 0x00060E6A }, // song 24
    { name: 'snd95_song_19.bin', folder: 'NHL95/Sound/Bank', start: 0x00060E6A, end: 0x00060E76 }, // song 25
    { name: 'snd95_song_1A.bin', folder: 'NHL95/Sound/Bank', start: 0x00060E76, end: 0x00060E82 }, // song 26
    { name: 'snd95_song_1B.bin', folder: 'NHL95/Sound/Bank', start: 0x00060E82, end: 0x00060E8E }, // song 27
    { name: 'snd95_song_1C.bin', folder: 'NHL95/Sound/Bank', start: 0x00060E8E, end: 0x00060E9A }, // song 28
    { name: 'snd95_song_1D.bin', folder: 'NHL95/Sound/Bank', start: 0x00060E9A, end: 0x00060EA6 }, // song 29
    { name: 'snd95_song_1E.bin', folder: 'NHL95/Sound/Bank', start: 0x00060EA6, end: 0x00060EB4 }, // song 30
    { name: 'snd95_song_20.bin', folder: 'NHL95/Sound/Bank', start: 0x00060EB4, end: 0x00060EC0 }, // song 32
    { name: 'snd95_song_21.bin', folder: 'NHL95/Sound/Bank', start: 0x00060EC0, end: 0x00060ECC }, // song 33
    { name: 'snd95_song_22.bin', folder: 'NHL95/Sound/Bank', start: 0x00060ECC, end: 0x00060ED8 }, // song 34
    { name: 'snd95_song_23.bin', folder: 'NHL95/Sound/Bank', start: 0x00060ED8, end: 0x00060EE4 }, // song 35
    { name: 'snd95_song_24.bin', folder: 'NHL95/Sound/Bank', start: 0x00060EE4, end: 0x00060EF0 }, // song 36
    { name: 'snd95_song_25.bin', folder: 'NHL95/Sound/Bank', start: 0x00060EF0, end: 0x00060EFC }, // song 37
    { name: 'snd95_song_26.bin', folder: 'NHL95/Sound/Bank', start: 0x00060EFC, end: 0x00061217 }, // song 38
    { name: 'snd95_song_27.bin', folder: 'NHL95/Sound/Bank', start: 0x00061217, end: 0x0006122B }, // song 39
    { name: 'snd95_song_28.bin', folder: 'NHL95/Sound/Bank', start: 0x0006122B, end: 0x0006123F }, // song 40
    { name: 'snd95_song_29.bin', folder: 'NHL95/Sound/Bank', start: 0x0006123F, end: 0x0006124B }, // song 41
    { name: 'snd95_song_32.bin', folder: 'NHL95/Sound/Bank', start: 0x0006124B, end: 0x0006143D }, // song 50
    { name: 'snd95_song_33.bin', folder: 'NHL95/Sound/Bank', start: 0x0006143D, end: 0x00061921 }, // song 51
    { name: 'snd95_song_34.bin', folder: 'NHL95/Sound/Bank', start: 0x00061921, end: 0x00061B75 }, // song 52
    { name: 'snd95_song_35.bin', folder: 'NHL95/Sound/Bank', start: 0x00061B75, end: 0x00061E23 }, // song 53
    { name: 'snd95_song_36.bin', folder: 'NHL95/Sound/Bank', start: 0x00061E23, end: 0x0006213F }, // song 54
    { name: 'snd95_song_37.bin', folder: 'NHL95/Sound/Bank', start: 0x0006213F, end: 0x000623E7 }, // song 55
    { name: 'snd95_song_38.bin', folder: 'NHL95/Sound/Bank', start: 0x000623E7, end: 0x00062683 }, // song 56
    { name: 'snd95_song_39.bin', folder: 'NHL95/Sound/Bank', start: 0x00062683, end: 0x0006282F }, // song 57
    { name: 'snd95_song_3A.bin', folder: 'NHL95/Sound/Bank', start: 0x0006282F, end: 0x00062C13 }, // song 58
    { name: 'snd95_song_3B.bin', folder: 'NHL95/Sound/Bank', start: 0x00062C13, end: 0x00062E57 }, // song 59
    { name: 'snd95_song_3C.bin', folder: 'NHL95/Sound/Bank', start: 0x00062E57, end: 0x00062E87 }, // song 60
    { name: 'snd95_song_3D.bin', folder: 'NHL95/Sound/Bank', start: 0x00062E87, end: 0x0006328B }, // song 61
    { name: 'snd95_song_3E.bin', folder: 'NHL95/Sound/Bank', start: 0x0006328B, end: 0x000635CC }, // song 62
    { name: 'snd95_song_3F.bin', folder: 'NHL95/Sound/Bank', start: 0x000635CC, end: 0x000637D4 }, // song 63
    { name: 'snd95_song_40.bin', folder: 'NHL95/Sound/Bank', start: 0x000637D4, end: 0x00063A52 }, // song 64
    { name: 'snd95_song_41.bin', folder: 'NHL95/Sound/Bank', start: 0x00063A52, end: 0x00063DAA }, // song 65
    { name: 'snd95_song_42.bin', folder: 'NHL95/Sound/Bank', start: 0x00063DAA, end: 0x00063ED6 }, // song 66
    { name: 'snd95_song_43.bin', folder: 'NHL95/Sound/Bank', start: 0x00063ED6, end: 0x0006429A }, // song 67
    { name: 'snd95_song_44.bin', folder: 'NHL95/Sound/Bank', start: 0x0006429A, end: 0x000644A6 }, // song 68
    { name: 'snd95_song_45.bin', folder: 'NHL95/Sound/Bank', start: 0x000644A6, end: 0x0006471A }, // song 69
    { name: 'snd95_song_46.bin', folder: 'NHL95/Sound/Bank', start: 0x0006471A, end: 0x00064872 }, // song 70
    { name: 'snd95_song_47.bin', folder: 'NHL95/Sound/Bank', start: 0x00064872, end: 0x00064C2E }, // song 71
    { name: 'snd95_song_48.bin', folder: 'NHL95/Sound/Bank', start: 0x00064C2E, end: 0x00065052 }, // song 72
    { name: 'snd95_song_49.bin', folder: 'NHL95/Sound/Bank', start: 0x00065052, end: 0x00065452 }, // song 73
    { name: 'snd95_song_4A.bin', folder: 'NHL95/Sound/Bank', start: 0x00065452, end: 0x00065767 }, // song 74
    { name: 'snd95_song_4B.bin', folder: 'NHL95/Sound/Bank', start: 0x00065767, end: 0x00065ACC }, // song 75
    { name: 'snd95_song_4C.bin', folder: 'NHL95/Sound/Bank', start: 0x00065ACC, end: 0x00065E2F }, // song 76
    { name: 'snd95_song_4D.bin', folder: 'NHL95/Sound/Bank', start: 0x00065E2F, end: 0x000660F8 }, // song 77
    { name: 'snd95_song_4E.bin', folder: 'NHL95/Sound/Bank', start: 0x000660F8, end: 0x00066514 }, // song 78
    { name: 'snd95_song_4F.bin', folder: 'NHL95/Sound/Bank', start: 0x00066514, end: 0x000669A0 }, // song 79
    { name: 'snd95_song_50.bin', folder: 'NHL95/Sound/Bank', start: 0x000669A0, end: 0x00066BF5 }, // song 80
    { name: 'snd95_song_51.bin', folder: 'NHL95/Sound/Bank', start: 0x00066BF5, end: 0x00066E1F }, // song 81
    { name: 'snd95_song_52.bin', folder: 'NHL95/Sound/Bank', start: 0x00066E1F, end: 0x00066F0F }, // song 82
    { name: 'snd95_song_53.bin', folder: 'NHL95/Sound/Bank', start: 0x00066F0F, end: 0x00067183 }, // song 83
    { name: 'snd95_song_54.bin', folder: 'NHL95/Sound/Bank', start: 0x00067183, end: 0x00067257 }, // song 84
    { name: 'snd95_song_55.bin', folder: 'NHL95/Sound/Bank', start: 0x00067257, end: 0x00067680 }, // song 85
    { name: 'snd95_list_00.bin', folder: 'NHL95/Sound/Bank', start: 0x00067680, end: 0x00067699 }, // list 0
    { name: 'snd95_list_01.bin', folder: 'NHL95/Sound/Bank', start: 0x00067699, end: 0x000676D8 }, // list 1
    // NHL 95 sound95_01: the 94 PCM samples and FM patches (same bytes as the 94 files, 94 address + $4D2BA).
    { name: 'sfx_shotbh_pcm.bin', folder: 'NHL95/Sound', start: 0x0006834E, end: 0x00068542 }, // 94 file, same bytes (94 $1B094)
    { name: 'sfx_pass_pcm.bin', folder: 'NHL95/Sound', start: 0x00068542, end: 0x0006926F }, // 94 file, same bytes (94 $1B288)
    { name: 'sfx_oooh_pcm.bin', folder: 'NHL95/Sound', start: 0x00069270, end: 0x0006C4B4 }, // 94 file, same bytes (94 $1BFB6)
    { name: 'sfx_crowdboo_pcm.bin', folder: 'NHL95/Sound', start: 0x0006C4B4, end: 0x0006EA01 }, // 94 file, same bytes (94 $1F1FA)
    { name: 'sfx_check_pcm.bin', folder: 'NHL95/Sound', start: 0x0006EA02, end: 0x00070954 }, // 94 file, same bytes (94 $21748)
    { name: 'sfx_crowdcheer_pcm.bin', folder: 'NHL95/Sound', start: 0x00070954, end: 0x00073834 }, // 94 file, same bytes (94 $2369A)
    { name: 'sfx_id_0E_pcm.bin', folder: 'NHL95/Sound', start: 0x00073834, end: 0x000772B3 }, // 94 file, same bytes (94 $2657A)
    { name: 'sfx_playerwall_pcm.bin', folder: 'NHL95/Sound', start: 0x000772B4, end: 0x00077764 }, // 94 file, same bytes (94 $29FFA)
    { name: 'sfx_check2_pcm.bin', folder: 'NHL95/Sound', start: 0x00077764, end: 0x00078193 }, // 94 file, same bytes (94 $2A4AA)
    { name: 'sfx_hithigh_pcm.bin', folder: 'NHL95/Sound', start: 0x00078194, end: 0x000786EA }, // 94 file, same bytes (94 $2AEDA)
    { name: 'sfx_shotfh_pcm.bin', folder: 'NHL95/Sound', start: 0x000786EA, end: 0x000792A2 }, // 94 file, same bytes (94 $2B430)
    { name: 'sfx_puckget_pcm.bin', folder: 'NHL95/Sound', start: 0x000792A2, end: 0x00079502 }, // 94 file, same bytes (94 $2BFE8)
    { name: 'fm_instrument_patches.bin', folder: 'NHL95/Sound', start: 0x00079502, end: 0x00079902 }, // 94 file, same bytes (94 $2C248)
    { name: 'z80_snd_drv93.bin', folder: 'NHL95/Sound', start: 0x0007E0E1, end: 0x0007E358 }, // sound95_02: the 94 Z80 driver after its first byte, up to the ld bc of the FM patch bank address (93 / 94 file, same bytes; 94 $1AD91)
    { name: 'z80_snd_drv93_end.bin', folder: 'NHL95/Sound', start: 0x0007E35D, end: 0x0007E36B }, // sound95_02: rest of the 94 Z80 driver (93 / 94 file, same bytes; 94 $1B00D)
];
const outRoot = path.join('Extracted');
const rom = fs.readFileSync(romPath);
for (const asset of assets) {
  const dir = path.join(outRoot, asset.folder);
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, asset.name), rom.subarray(asset.start, asset.end));
}
console.log('Extracted ' + assets.length + ' slices to ' + outRoot + '.');
