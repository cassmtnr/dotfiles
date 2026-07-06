---
name: agent-reach
description: >
  MUST USE when user wants to research/search/look up/find anything on the
  internet — e.g. "research this topic", "do a deep dive on X", "search the
  web for X", "see what people say about X", "look this up".

  Also MUST USE when user mentions any platform or shares any URL/link:
  Twitter/X, Reddit, YouTube, GitHub, Bilibili, V2EX, RSS.

  9 channels installed. Run `agent-reach doctor --json` to see which
  backend serves each platform right now.

  NOT for: writing reports/analysis/translation (this skill only FETCHES
  internet content); posting/commenting/liking (write operations); platforms
  that already have a dedicated skill installed (prefer that skill).
metadata:
  openclaw:
    homepage: https://github.com/Panniantong/Agent-Reach
---

# Agent Reach — internet capability router

<!-- Trimmed to this machine's installed channels (see dotfiles log.md).
     Upstream ships docs for 15 platforms; re-trim if an upgrade regenerates
     this skill. Installed: web, Exa, YouTube, GitHub, RSS, V2EX, Bilibili,
     Twitter, Reddit. -->

**When this skill exists, use it for these platforms — do not invent your
own approach.**

## Standing rules (apply for the whole session)

1. **Health-check before acting**: for login-backed platforms (Reddit /
   Twitter), run `agent-reach doctor --json` first and pick the command group
   matching each platform's `active_backend`.
2. **Announce what you use**: say "using agent-reach, platform X via backend Y"
   before starting.
3. **On failure, follow the retry chains in references/** — never guess
   commands.
4. **For broad research tasks**: combine platforms (Exa for web search +
   Twitter/Reddit for discussions), collect in parallel, then synthesize.

## Routing table

| User intent | Category | Details |
|---------|------|---------|
| Web / code search | search | [references/search.md](references/search.md) |
| Twitter / Reddit / Bilibili / V2EX | social | [references/social.md](references/social.md) |
| GitHub / code | dev | [references/dev.md](references/dev.md) |
| Web pages / articles / RSS | web | [references/web.md](references/web.md) |
| YouTube / Bilibili video | video | [references/video.md](references/video.md) |

## Zero-config quick commands

```bash
# Exa web search
mcporter call 'exa.web_search_exa(query: "query", numResults: 5)'

# Read any web page
curl -s "https://r.jina.ai/URL"

# GitHub search
gh search repos "query" --sort stars --limit 10

# YouTube subtitles (NOTE: never use yt-dlp for Bilibili — see video.md)
yt-dlp --write-sub --skip-download -o "/tmp/%(id)s" "URL"

# V2EX hot topics
curl -s "https://www.v2ex.com/api/topics/hot.json" -H "User-Agent: agent-reach/1.0"

# Bilibili search (bili-cli, no login needed)
bili search "query" --type video -n 5
```

## Login-backed platforms (pick by doctor's active_backend)

```bash
# Twitter search (twitter-cli; retry chain in social.md)
twitter search "query" -n 10

# Reddit (rdt-cli, login required — cookies configured via `rdt login`)
rdt search "query" --limit 10
```

## Environment check

```bash
# Channel availability + which backend serves each platform
agent-reach doctor --json
```

## Workspace rules

**Never create files in the agent workspace.** Use `/tmp/` for temporary
output and `~/.agent-reach/` for persistent data.

## Detailed references

Read the matching file when you need specifics (commands above cover the
common cases; references hold per-backend command groups, caveats, retry
chains):

- [Search](references/search.md) — Exa AI search
- [Social](references/social.md) — Twitter, Bilibili, V2EX, Reddit
- [Dev](references/dev.md) — GitHub CLI
- [Web](references/web.md) — Jina Reader, RSS
- [Video](references/video.md) — YouTube, Bilibili

## Configure a channel

If a channel needs setup, fetch the install guide:
https://raw.githubusercontent.com/Panniantong/agent-reach/main/docs/install.md

The user only provides cookies / one extension click; the agent does the rest.
