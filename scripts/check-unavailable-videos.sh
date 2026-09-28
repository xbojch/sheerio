#!/usr/bin/env bash
set -euo pipefail

# Lists embedded YouTube videos that are private, removed or no longer embeddable.
# Uses the public oEmbed endpoint: 200 = fine, 401 = embedding disabled,
# 403 = private, 404 = deleted or unavailable.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIDEOS_DIR="$SCRIPT_DIR/../content/videos"

check() {
  local file="$1" id="$2" code
  code=$(curl -s -o /dev/null -w "%{http_code}" \
    "https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=${id}&format=json")
  case "$code" in
    200) ;;
    401) echo "embedding disabled  $id  $file" ;;
    403) echo "private             $id  $file" ;;
    404) echo "removed             $id  $file" ;;
    *)   echo "http $code            $id  $file" ;;
  esac
}
export -f check

grep -H "^video = " "$VIDEOS_DIR"/*/index.md \
  | sed -E "s|^$VIDEOS_DIR/([^:]+)/index.md:video = '([^']+)'.*|\1 \2|" \
  | xargs -P 8 -n 2 bash -c 'check "$0" "$1"' \
  | sort
