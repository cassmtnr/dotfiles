# Search Tools

Exa AI search engine.

## Exa AI Search

High-quality AI search engine, strong on technical and code queries.

```bash
mcporter call 'exa.web_search_exa(query: "query", numResults: 5)'
mcporter call 'exa.get_code_context_exa(query: "code question", tokensNum: 3000)'
```

### Usage

| Scenario | Call |
|-----|------|
| Web search | `web_search_exa(query: "...", numResults: 5)` |
| Code search | `get_code_context_exa(query: "...", tokensNum: 3000)` |

### Strengths

- Strong on English content and technical docs
- Supports code-context search
- High result quality

## Compared to other search tools

| Tool | Source | Best for |
|-----|------|---------|
| Exa | agent-reach | English/technical/code search |
| GitHub search | agent-reach (dev.md) | Repo/code search |
