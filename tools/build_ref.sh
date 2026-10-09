#!/usr/bin/env bash
# Build the NHL 94 reference (https://github.com/abdulahmad/NHL94Genesis) bit-perfect under wine,
# so tools/fingerprint_map.py can read its listing "output/nhl94 .lst" and its ROM.
#   tools/build_ref.sh [ref_dir]      (default /tmp/NHL94Genesis; cloned when missing)
# Needs git, node/npm and wine (apt: wine wine32 wine64, with the i386 architecture enabled).
set -euo pipefail

REF=${1:-/tmp/NHL94Genesis}
[ -d "$REF/.git" ] || git clone --depth 1 https://github.com/abdulahmad/NHL94Genesis "$REF"
cd "$REF"
npm install --no-audit --no-fund
node extractAssets94.js lst/nhl94.bin
mkdir -p output
(cd src && WINEDEBUG=-all wine ../assembler/Assembler.exe /p /m /g \
  /o d- /o s- /o r+ /o l+ /o l. /o ow+ /o op- /o os+ /o oz+ /o omq- /o oaq+ /o osq+ \
  /e REV=0 /e CHECKSUM=1 'nhl94.asm,..\output\nhl94.bin,..\output\nhl94,..\output\nhl94')
node fixopcodes.js "output/nhl94 .lst" output/nhl94.bin
node verifyRom.js output/modified_nhl94.bin lst/nhl94.bin
