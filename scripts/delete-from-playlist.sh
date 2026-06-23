#!/usr/bin/env bash
set -euo pipefail

PLAYLIST_ID="PLScZZJbtTmplrsXx1cgyDaehT3E7tlgCZ"

video_id="${1:-}"
if [[ -z "$video_id" ]]; then
  echo "Usage: $0 <video_id>" >&2
  exit 1
fi

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_token.sh"
load_youtube_token

# playlistItems.list cannot filter by videoId, so page through the playlist and
# match the resourceId.videoId to find the playlistItem id (the deletable handle).
# Deleted/unavailable videos still occupy a slot here even when hidden in the UI.
page_token=""
item_id=""
while :; do
  url="https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=${PLAYLIST_ID}&maxResults=50"
  if [[ -n "$page_token" ]]; then
    url="${url}&pageToken=${page_token}"
  fi

  response=$(yt_api GET "$url")

  item_id=$(echo "$response" | jq -r --arg vid "$video_id" \
    'first(.items[] | select(.snippet.resourceId.videoId == $vid) | .id) // empty')
  if [[ -n "$item_id" ]]; then
    break
  fi

  page_token=$(echo "$response" | jq -r '.nextPageToken // empty')
  if [[ -z "$page_token" ]]; then
    break
  fi
done

if [[ -z "$item_id" ]]; then
  echo "Error: Video $video_id not found in playlist." >&2
  exit 1
fi

yt_api DELETE "https://www.googleapis.com/youtube/v3/playlistItems?id=${item_id}" > /dev/null

echo "Deleted $video_id (playlistItem $item_id) from playlist." >&2
