# Web Reading

Generic web pages, RSS.

## Any web page (Jina Reader)

```bash
# Read any web page as clean text
curl -s "https://r.jina.ai/URL"

# Example
curl -s "https://r.jina.ai/https://example.com/article"
```

**When to use**: most web pages can be read directly through Jina Reader.

## RSS (feedparser)

```python
python3 -c "
import feedparser
for e in feedparser.parse('FEED_URL').entries[:5]:
    print(f'{e.title} — {e.link}')
"
```

**When to use**: blogs, news sources, podcast feeds — anything with RSS.

## Tool selection

| Scenario | Tool |
|-----|---------|
| Generic web page | Jina Reader (`curl r.jina.ai`) |
| RSS feeds | feedparser |
