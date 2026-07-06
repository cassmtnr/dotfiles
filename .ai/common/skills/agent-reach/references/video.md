# Video

YouTube and Bilibili subtitles and metadata.

<!-- Trimmed to installed channels — upstream also documents Xiaoyuzhou
     podcast transcription (Groq Whisper) and OpenCLI Bilibili subtitles
     (not installed on this machine). -->

## YouTube (yt-dlp)

### Video metadata

```bash
yt-dlp --dump-json "URL"
```

### Download subtitles

```bash
# Subtitles only (no video download)
yt-dlp --write-sub --write-auto-sub --sub-lang "en,zh-Hans,zh" --skip-download -o "/tmp/%(id)s" "URL"

# Then read the .vtt file
cat /tmp/VIDEO_ID.*.vtt
```

### Comments

```bash
# Extract comments (best-effort, not guaranteed complete)
yt-dlp --write-comments --skip-download --write-info-json \
  --extractor-args "youtube:max_comments=20" \
  -o "/tmp/%(id)s" "URL"
# Comments are in the .info.json "comments" field
```

### Search videos

```bash
yt-dlp --dump-json "ytsearch5:query"
```

> **Subtitle note**: manually-uploaded subtitles extract reliably; auto-generated ones may have duplicated lines and need post-processing.
> **Comment note**: `--write-comments` scrapes the web page (not the YouTube Data API); some comments may be missing.

## Bilibili (bili-cli)

> ⚠️ **Never use yt-dlp for Bilibili**: their anti-bot blocks it with 412 across the board (verified with the latest version — direct, proxied, and cookie-authenticated requests all fail). yt-dlp is for YouTube only.

### Video details / search / trending / rankings (bili-cli, read-only, no login)

```bash
# Video details (title/uploader/duration/engagement stats/subtitle availability)
bili video BVxxx

# Search videos
bili search "query" --type video -n 5

# Trending / rankings
bili hot -n 10
bili rank -n 10
```

### Zero-config fallback: direct search API

```bash
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
curl -s -c /tmp/bili_ck.txt -o /dev/null -A "$UA" "https://www.bilibili.com/"
curl -s -b /tmp/bili_ck.txt -A "$UA" -e "https://www.bilibili.com/" \
  "https://api.bilibili.com/x/web-interface/search/all/v2?keyword=QUERY&page=1"
```

> **Install bili-cli**: `pipx install bilibili-cli` (upstream unmaintained since 2026-03 but verified healthy; read-only use needs no login).

## Tool selection

| Scenario | Tool |
|-----|---------|
| YouTube subtitles | yt-dlp |
| Bilibili details/search | bili-cli |
