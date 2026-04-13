#!/usr/bin/env bash
set -euo pipefail

PLAYLIST_ID="PLScZZJbtTmplrsXx1cgyDaehT3E7tlgCZ"

if [[ -z "${YOUTUBE_TOKEN:-}" ]]; then
  echo "Error: YOUTUBE_TOKEN environment variable is not set." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIDEOS_DIR="$SCRIPT_DIR/../content/videos"

response=$(curl -sf -H "Authorization: Bearer ${YOUTUBE_TOKEN}" \
  "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=${PLAYLIST_ID}&maxResults=1")

video_id=$(echo "$response" | jq -r '.items[0].snippet.resourceId.videoId // empty')

if [[ -z "$video_id" ]]; then
  echo "Error: Could not extract video ID from API response." >&2
  exit 1
fi

if grep -rl "$video_id" "$VIDEOS_DIR" --include="index.md" > /dev/null 2>&1; then
  echo "Already added: $video_id" >&2
  exit 1
fi

echo "$video_id"
