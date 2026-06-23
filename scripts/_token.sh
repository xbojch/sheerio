# Shared YouTube auth helpers. Source this; do not run directly.
# The token is created by `make auth` and saved to scripts/.youtube_token.

_TOKEN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOKEN_FILE="$_TOKEN_DIR/.youtube_token"

# Populate YOUTUBE_TOKEN from the env (if already set) or the saved token file.
# Errors out telling the user to authorize when no token is available.
load_youtube_token() {
  if [[ -n "${YOUTUBE_TOKEN:-}" ]]; then
    return 0
  fi
  if [[ ! -s "$TOKEN_FILE" ]]; then
    echo "Error: not authorized. Run 'make auth' first." >&2
    exit 1
  fi
  YOUTUBE_TOKEN="$(cat "$TOKEN_FILE")"
  export YOUTUBE_TOKEN
}

# Authorized YouTube API call. Usage: yt_api METHOD URL
# Prints the response body on success. On HTTP 401 (missing/expired token)
# it tells the user to re-authorize; other errors print the API body.
yt_api() {
  local method="$1" url="$2" response status body
  response="$(curl -s -w $'\n%{http_code}' -X "$method" \
    -H "Authorization: Bearer ${YOUTUBE_TOKEN}" "$url")"
  status="${response##*$'\n'}"
  body="${response%$'\n'*}"

  if [[ "$status" == "401" ]]; then
    echo "Error: not authorized (token missing or expired). Run 'make auth'." >&2
    return 1
  fi
  if [[ "$status" -ge 400 ]]; then
    echo "Error: YouTube API returned HTTP $status." >&2
    echo "$body" >&2
    return 1
  fi

  printf '%s' "$body"
}
