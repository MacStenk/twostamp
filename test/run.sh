#!/usr/bin/env bash
# Smoke test: stamp, verify, detect tampering. Needs network (freetsa.org).
set -u
bin="$(cd "$(dirname "$0")/.." && pwd)/twostamp"
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT; cd "$t"
fail() { echo "FAIL: $1"; exit 1; }

echo hello > a.txt; echo world > b.txt
"$bin" stamp a.txt b.txt | grep -q "2 files" || fail "stamp"
[ -s SHA256SUMS.txt.tsr ] || fail "no RFC 3161 stamp"
"$bin" verify >/dev/null || fail "verify untouched files"

"$bin" stamp a.txt | grep -q "SHA256SUMS-" || fail "second stamp must not overwrite"

echo tampered >> a.txt
"$bin" verify >/dev/null && fail "tampering not detected"

echo "OK"
