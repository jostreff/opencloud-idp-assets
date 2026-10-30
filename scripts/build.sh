#!/bin/sh
# Build the OpenCloud IdP web assets and pack them into a tarball.
#
# usage: build.sh SRC_DIR OUT_FILE
#   SRC_DIR   checkout of opencloud-eu/opencloud at the wanted tag
#   OUT_FILE  tarball to create (absolute path)
#
# The steps mirror services/idp/Makefile ("make node-generate-prod").
# pnpm must already be in PATH, in the version pinned by upstream
# (services/idp/package.json, "packageManager").

set -eu

[ $# -eq 2 ] || { echo "usage: $0 SRC_DIR OUT_FILE" >&2; exit 2; }
src=$1
out=$2

idp="$src/services/idp"
[ -f "$idp/package.json" ] || { echo "$idp/package.json not found" >&2; exit 1; }

# Timestamp of the upstream commit keeps the archive reproducible.
mtime=$(git -C "$src" log -1 --format=%ct)

mkdir -p "$(dirname "$out")"

cd "$idp"
pnpm install --frozen-lockfile
pnpm build
cp -f src/images/favicon.svg assets/identifier/static/favicon.svg
cp -f src/images/icon-lilac.svg assets/identifier/static/icon-lilac.svg
rm -f assets/identifier/static/favicon.ico

# Archive layout: assets/... (extract it into services/idp).
tar --sort=name --mtime="@${mtime}" --owner=0 --group=0 --numeric-owner \
    -cf - assets | gzip -n -9 > "$out"

echo "created $out"
