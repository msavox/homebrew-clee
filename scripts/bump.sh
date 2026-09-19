#!/bin/sh
# Points the formula at a new release.
#
#   scripts/bump.sh 0.28.2
#
# Four urls and four checksums is more to keep in step than one, which is the price of handing
# people a binary instead of a compile. This is that price paid once: the release publishes a
# `.sha256` beside every asset, so nothing here is typed by hand.
#
# The checksums are not taken on trust. Each archive is downloaded and hashed, and the result
# is compared with the published file — because the published file is only a claim, and a
# formula with a wrong checksum does not fail loudly: it downloads, mismatches, and looks to
# the user like a hung install. Each download is also checked to *be* an archive first. GitHub
# under load answers with a 200 and a two-line "429: Too Many Requests" body, and that body has
# a perfectly good sha256.

set -eu

version=${1:-}
[ -n "$version" ] || { echo "usage: $0 <version>   e.g. $0 0.28.2" >&2; exit 2; }
version=${version#v}

repo=msavox/cleecode
base="https://github.com/$repo/releases/download/v$version"
formula=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/Formula/clee.rb
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# gh, when it is there, so a private or rate-limited release is still reachable.
auth=''
if command -v gh >/dev/null 2>&1 && token=$(gh auth token 2>/dev/null) && [ -n "$token" ]; then
	auth="Authorization: Bearer $token"
fi
fetch() {
	if [ -n "$auth" ]; then curl -fsSL -H "$auth" "$1" -o "$2"; else curl -fsSL "$1" -o "$2"; fi
}

sha_of() {
	if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
	else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

for slug in macos-arm64 macos-x86_64 linux-arm64 linux-x86_64; do
	asset="clee-v$version-$slug.tar.gz"
	printf '%-16s ' "$slug"
	fetch "$base/$asset" "$work/$asset"
	tar -tzf "$work/$asset" >/dev/null 2>&1 || { echo "not an archive"; exit 1; }
	real=$(sha_of "$work/$asset")
	published=$(fetch "$base/$asset.sha256" "$work/$asset.sha256" && cut -d' ' -f1 <"$work/$asset.sha256")
	[ "$real" = "$published" ] || {
		echo "checksum published for $asset does not match its bytes"
		exit 1
	}
	echo "$real"
	# One url line and the sha256 line under it, per platform. Matched on the asset name so the
	# four blocks cannot be confused for one another.
	old_url=$(grep -n "clee-v[0-9.]*-$slug\.tar\.gz\"$" "$formula" | cut -d: -f1)
	[ -n "$old_url" ] || { echo "no url line for $slug in the formula"; exit 1; }
	awk -v n="$old_url" -v u="      url \"$base/$asset\"" -v s="      sha256 \"$real\"" \
		'NR==n {print u; next} NR==n+1 {print s; next} {print}' "$formula" >"$work/formula" &&
		cat "$work/formula" >"$formula"
done

echo
echo "Formula/clee.rb now points at v$version. Check it, then:"
echo "  brew audit --formula msavox/clee/clee && brew reinstall msavox/clee/clee && brew test msavox/clee/clee"
