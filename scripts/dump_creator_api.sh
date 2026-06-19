#!/usr/bin/env bash
# Dumps every creator-related API response so the exact field names can be
# mapped into the Flutter add/edit code.
#
# Usage:
#   bash scripts/dump_creator_api.sh "<BEARER_TOKEN>"
#   # or:  TOKEN=xxxxx bash scripts/dump_creator_api.sh
#
# Then copy ALL the printed output and paste it back in chat.
# Do NOT commit your token.

set -u
BASE="${API_BASE:-https://adzmavall.com/api/v1}"
TOKEN="${1:-${TOKEN:-}}"

if [ -z "$TOKEN" ]; then
  echo "Pass the bearer token as the first argument:"
  echo "  bash scripts/dump_creator_api.sh \"<BEARER_TOKEN>\""
  exit 1
fi

AUTH="Authorization: Bearer $TOKEN"
ACC="Accept: application/json"

pretty() { python3 -m json.tool 2>/dev/null || cat; }

dump() {
  echo
  echo "================================================================"
  echo "GET $1"
  echo "----------------------------------------------------------------"
  curl -s -H "$AUTH" -H "$ACC" "$BASE$1" | pretty
}

# Current creator data (so we see the real shapes after saving)
dump "/auth/user/profile/content-creator"
dump "/auth/user/social-accounts"
dump "/auth/user/clients"
dump "/auth/user/ads"

# Lookups the add/edit forms depend on (correct ids/slugs)
dump "/lookup/social-platforms"
dump "/lookup/companies"
dump "/lookup/ad-content-types"
dump "/lookup/categories"
dump "/lookup/cities"
dump "/lookup/city-directions"
dump "/lookup/content-creator-types"
dump "/lookup/model-content-creator-accents"
dump "/lookup/model-content-creator-sizes"
dump "/lookup/model-content-creator-skin-tones"

# Orders (already wired, included for completeness)
dump "/influencer/orders"

echo
echo "================================================================"
echo "Done. Copy everything above and paste it back in chat."
