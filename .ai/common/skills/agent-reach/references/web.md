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

## RSS (Python stdlib)

```bash
# No dependencies — handles both RSS and Atom feeds
python3 - 'FEED_URL' <<'PY'
import sys, urllib.request, xml.etree.ElementTree as ET
root = ET.fromstring(urllib.request.urlopen(sys.argv[1]).read())
ns = {'a': 'http://www.w3.org/2005/Atom'}
items = root.findall('.//item') or root.findall('.//a:entry', ns)
for e in items[:5]:
    title = e.findtext('title') or e.findtext('a:title', namespaces=ns)
    link = e.findtext('link')
    if link is None:
        el = e.find('a:link', ns)
        link = el.get('href') if el is not None else '?'
    print(f'{title} — {link}')
PY
```

**When to use**: blogs, news sources, podcast feeds — anything with RSS/Atom.

## Tool selection

| Scenario | Tool |
|-----|---------|
| Generic web page | Jina Reader (`curl r.jina.ai`) |
| RSS feeds | Python stdlib (above) |
