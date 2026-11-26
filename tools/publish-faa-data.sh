#!/bin/sh
# Refreshes the small FAA registry file that the app's "Download the FAA registry" / "Update now" button fetches.
# Run it by hand, from a home or office connection, whenever you want newer records (the FAA site refuses GitHub's cloud
# servers, so this can't run as a GitHub Action). Needs Node 22+ and the GitHub CLI (gh), signed in to the repo.
set -e
cd "$(dirname "$0")/.."
tmp=$(mktemp -d)
curl --fail --silent --show-error -A "KrabbzDevPorchRadar/1.0 (maintainer)" -o "$tmp/ReleasableAircraft.zip" https://registry.faa.gov/database/ReleasableAircraft.zip
node server.js --build-faa-index "$tmp/ReleasableAircraft.zip" "$tmp/faa-index.json.gz"
gh release view faa-data >/dev/null 2>&1 || gh release create faa-data --prerelease --latest=false --title "FAA registry data" --notes "FAA registry data. Used by the app's Download the FAA registry button. Not an app release."
gh release upload faa-data "$tmp/faa-index.json.gz" --clobber
gh release edit faa-data --notes "FAA registry data, built $(date -u +%F). Used by the app's Download the FAA registry button. Not an app release."
rm -rf "$tmp"
echo "Published the FAA registry data for $(date -u +%F)."
