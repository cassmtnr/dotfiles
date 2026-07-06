# Social Media & Communities

Twitter/X, Bilibili, V2EX, Reddit.

<!-- Trimmed to installed channels — upstream also documents XiaoHongShu,
     Facebook, Instagram (OpenCLI-backed; not installed on this machine). -->

## Twitter/X (twitter-cli)

### Stable commands

```bash
# Home timeline (most reliable)
twitter feed -n 20

# Read a single tweet (with replies)
twitter tweet URL_OR_ID

# Read a long-form post / X Article
twitter article URL_OR_ID

# A user's timeline
twitter user-posts @username -n 20

# User profile
twitter user @username
```

### Potentially unstable commands

```bash
# Tweet search (Twitter changes GraphQL endpoints often; may 404)
twitter search "query" -n 10

# likes (since 2024 only your own are visible — platform limitation)
twitter likes
```

### Retry chain when search fails (run in order, stop on success)

1. Retry once (intermittent failures are common): `twitter search "query" -n 10`
2. Upgrade then retry: `pipx upgrade twitter-cli && twitter search "query" -n 10`
3. If still failing, route around it with stable commands: `twitter feed` / `twitter user-posts @somebody`

### Important notes

> **Install**: `pipx install twitter-cli` (ensure v0.8.5+)
>
> **Auth**: cookies already configured via `agent-reach configure --from-browser chrome`.
>
> **IP risk**: don't hammer it from VPS/datacenter IPs — especially followers/following — account-ban risk. Use a residential connection or local machine.
>
> **Output format**: prefer `--yaml` or `--json` for structured output; friendlier for AI agents.

## Bilibili

> ⚠️ **Never use yt-dlp for Bilibili** (their anti-bot now blocks it with 412 across the board; verified unfixable). Use bili-cli.

```bash
# Search / trending / video details (bili-cli, read-only, no login)
bili search "query" --type video -n 5
bili hot -n 10
bili video BVxxx
```

> More commands (raw API fallback) in [references/video.md](video.md). Subtitles require OpenCLI (not installed).

## V2EX (public API)

No auth needed — call the public API directly.

### Hot topics

```bash
curl -s "https://www.v2ex.com/api/topics/hot.json" -H "User-Agent: agent-reach/1.0"
```

### Topics by node

```bash
# node_name examples: python, tech, jobs, qna, programmers
curl -s "https://www.v2ex.com/api/topics/show.json?node_name=python&page=1" -H "User-Agent: agent-reach/1.0"
```

### Topic details

```bash
# topic_id comes from the URL, e.g. https://www.v2ex.com/t/1234567
curl -s "https://www.v2ex.com/api/topics/show.json?id=TOPIC_ID" -H "User-Agent: agent-reach/1.0"
```

### Topic replies

```bash
curl -s "https://www.v2ex.com/api/replies/show.json?topic_id=TOPIC_ID&page=1" -H "User-Agent: agent-reach/1.0"
```

### User info

```bash
curl -s "https://www.v2ex.com/api/members/show.json?username=USERNAME" -H "User-Agent: agent-reach/1.0"
```

> **Node list**: https://www.v2ex.com/planes

## Reddit (rdt-cli, login required)

**Reddit has no zero-config path**: anonymous `.json` endpoints are blocked (403) and official API access requires manual approval. This machine's backend is rdt-cli (cookie-based login; no browser needed at runtime).

```bash
rdt search "query" --limit 10   # Search posts
rdt read POST_ID                # Read full post + comments
rdt sub python --limit 20       # Browse a subreddit
rdt popular --limit 10          # Browse popular
rdt all --limit 10              # Browse /r/all
```

> **Install**: `pipx install 'git+https://github.com/public-clis/rdt-cli.git'` (PyPI lags; install from GitHub, v0.4.2+). Run `rdt login` before searching/reading (auto-extracts browser cookies; requires being logged into reddit.com in Chrome).
> Prefer `--yaml` output; friendlier for AI agents.
