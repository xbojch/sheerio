#!/usr/bin/env bash
set -euo pipefail

PLAYLIST_ID="PLScZZJbtTmplrsXx1cgyDaehT3E7tlgCZ"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIDEOS_DIR="$SCRIPT_DIR/../content/videos"
source "$SCRIPT_DIR/_token.sh"
load_youtube_token

response=$(yt_api GET \
  "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=${PLAYLIST_ID}&maxResults=1")

video_id=$(echo "$response" | jq -r '.items[0].snippet.resourceId.videoId // empty')

if [[ -z "$video_id" ]]; then
  echo "Error: Could not extract video ID from API response." >&2
  exit 1
fi

if grep -rl "$video_id" "$VIDEOS_DIR" --include="index.md" > /dev/null 2>&1; then
  echo "Already added: https://youtu.be/$video_id" >&2
  exit 1
fi

echo "$video_id"
