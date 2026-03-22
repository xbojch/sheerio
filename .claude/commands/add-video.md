Add a new video entry to `content/videos/` given a YouTube video ID.

**YouTube video ID:** $ARGUMENTS

## Steps

1. Fetch the video metadata using the YouTube oEmbed endpoint:
   `https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=VIDEO_ID&format=json`
   Use WebFetch for this. Extract the `title` and `author_name` fields.

2. Also fetch the full YouTube page at `https://www.youtube.com/watch?v=VIDEO_ID` to find the upload date (look for `"publishDate"` or `"uploadDate"` in the page source).

3. From the title, derive:
   - A URL-friendly folder slug: lowercase, spaces and special characters replaced with hyphens, no trailing/leading hyphens, collapse consecutive hyphens. Strip apostrophes, quotes, and other punctuation before slugifying.
   - A clean display title (the raw oEmbed title is fine).
   - Relevant tags: infer 1–3 short lowercase tag strings from the people or topics mentioned in the title (e.g. `taylorswift`, `eminem`, `coldplay`, `beyonce`). Use no spaces in tags, just concatenated lowercase names.

4. Format the publish date as `YYYY-MM-DDT08:00:00Z`.

5. Create the folder `content/videos/SLUG/` and write `content/videos/SLUG/index.md` with this exact format (TOML front matter with `+++` delimiters):

```
+++
title = 'TITLE'
date = YYYY-MM-DDT08:00:00Z
draft = false
toc = false
tags = ['tag1', 'tag2']
videos = ['https://youtu.be/VIDEO_ID']
[[youtube_videos]]
video = 'VIDEO_ID'
+++
DESCRIPTION
```

   The `DESCRIPTION` should be 1–2 sentences written in an enthusiastic, fan-site tone describing what happens in the video. Base it on the title and any context available from the page fetch.

6. Report the created file path and the front matter to the user.
