Add the next video from the YouTube "to add" playlist to `content/videos/`.

This is the no-argument companion to `/add-video`. It picks the video ID up from the
playlist instead of taking one by hand, so there is no need to leave the session and
run `make next`.

## Steps

1. Get the next video ID by running the script directly:

   ```
   ./scripts/next-from-playlist.sh
   ```

   Run the script, not `make next`. The Makefile target wraps the same script in a
   nested `claude "/add-video ..."` process, which is redundant when a session is
   already open.

   The script exits non zero in two expected cases. Report them and stop:
   - `Already added: ...` means the head of the playlist is already in `content/videos/`.
     Tell the user, and point out that `./scripts/move-to-processed-playlist.sh <id>`
     moves it out of the playlist so the next run advances.
   - `Could not extract video ID ...` usually means the YouTube token expired. Tell the
     user to run `make auth`.

2. Then follow every step in `.claude/commands/add-video.md` for that video ID, from the
   duplicate check through to the X post. That file is the single source of truth for
   metadata fetching, slug and title style, tags, songs, dates and front matter format.
   Do not restate or re-derive those rules here.

   That includes moving the video to the processed playlist, so the next run advances.
