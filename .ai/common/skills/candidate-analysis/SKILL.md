---
name: candidate-analysis
description: Use when preparing to interview an engineering candidate — reviewing a resume/CV, building interview questions, or researching a candidate's public footprint (GitHub, LinkedIn, talks, npm). Triggers on "review this resume", "prep questions for this candidate", "research this candidate", or an attached CV/PDF for a frontend or web-banking role.
---

# Candidate Analysis

Prepare frontend interview material grounded in the interviewer's real codebases, not generic question banks. Three workflows — resume review, question building, online research — and one combined prep output.

## Repo ground truth

Cross-reference every resume claim against what these repos actually use. Skim `package.json`/`README.md` fresh if versions matter — the table is the map, not the territory.

| Repo | Role | Stack highlights |
|---|---|---|
| `~/Work/web-banking` | Host app (shell) | React 18, TS, Vite, Module Federation (`@module-federation/enhanced` + vite plugin), Redux Toolkit + redux-persist, React Router 7, react-hook-form, styled-components, i18next, axios, Vitest + Testing Library + vitest-axe, Playwright, Storybook + Chromatic + MSW, Sentry, CSP config, Express server, `src/domains`/`features` structure, stella-ui design system |
| `~/Work/web-module-payment` | Payment micro-frontend (remote) | Same React stack; loaded into host via Module Federation; shared federation config from `web-banking-shared.module-config.vite`; dev CLI for integrated mode with the host; own Storybook/Playwright/MSW |
| `~/Work/library-web-proxy` | Node/Express BFF middleware | Auth-header injection to WSO2 API gateways, CSP + CSRF, serves MFE bundles (CORS/CDN role), Contentful caching, SSO legacy↔new banking, JWT, cookie-session, FingerprintJS fraud, Prometheus/winston; Vitest + supertest + nock |
| `~/Work/library-web-banking-shared` | Shared monorepo (Yarn workspaces + Lerna) | MFA/simple-auth apps, core domain rules + shared context + SSO, shared UI/forms/theming, GTM tracking, shared Playwright e2e base, eslint-config with i18n rules |

## Workflow 1 — Resume review

Extract:
- **Timeline**: roles with dates; compute tenure per role. Flag gaps > 6 months and hops < 1 year (pattern, not single occurrence).
- **Skills vs evidence**: separate claimed skills from skills demonstrated by described work. "React, TypeScript, Kubernetes, ML" with no matching project = list padding.
- **Depth signals**: numbers (users, perf gains, team size), ownership verbs ("designed", "led", "migrated") vs passenger verbs ("worked on", "was involved in").
- **Relevance to this platform**: React + TS depth, micro-frontend/Module Federation exposure, testing culture, Node/BFF experience, banking/fintech/regulated-industry background, accessibility, i18n.

Red flags: title inflation vs described duties, tech listed that postdates the role's timeframe, vague responsibilities in senior roles, no testing mention anywhere.

Output: one-paragraph summary, then bullets — Strengths / Gaps vs role / Red flags / Timeline notes. Keep judgments tied to evidence from the document; mark speculation as such.

## Workflow 2 — Question building

For each substantive resume claim, find the matching repo tech and build one question per tier:

1. **Screening** (facts, 2 min): confirms the claim is real. "You mention styled-components — how do you keep theme values consistent across independently deployed apps?"
2. **Deep-dive** (experience, 5–10 min): asks for a decision they made and its trade-offs, mappable to a real pattern in the repos.
3. **Architecture** (design, 10–15 min): open scenario drawn from the platform's actual shape.

Evergreen examples grounded in these repos:
- *MFE*: "Host and payment module deploy independently. How do you keep a shared dependency like React or a design system from breaking one when the other upgrades?" (Module Federation shared/singleton config)
- *State*: "Redux Toolkit with redux-persist in the host — what state belongs in the host store vs inside a remote module, and what must never be persisted in a banking app?"
- *BFF/security*: "Why put an Express proxy between the SPA and the API gateway instead of calling it directly? What would you handle there?" (auth headers, CSRF, CSP, cookie sessions — compare against `library-web-proxy`'s answers)
- *Monorepo*: "A shared UI library serves a host and five module teams. How do you version and release it without blocking anyone?" (workspaces + Lerna, semver discipline)
- *Testing*: "Where do you draw the line between Vitest + Testing Library, Storybook + MSW, and Playwright for a payment form?"

Skip questions on tech the candidate never claimed — probe adjacent experience instead ("no MFE experience: how have you split a large SPA between teams?").

## Workflow 3 — Online research

Public professional information only; keep findings factual and neutral — no speculation about personal life, no scraping behind logins.

Search (WebSearch, then WebFetch promising hits):
- `"<name>" github` — profile, pinned repos, contribution pattern, code quality on 1–2 recent repos
- `"<name>" linkedin` — cross-check titles/dates against the resume
- `"<name>" npm` / `site:npmjs.com` — published packages, maintenance state
- `"<name>" conference OR talk OR podcast`, `"<name>" blog <main tech>` — communication skills, depth
- `"<name>" site:stackoverflow.com` — optional

Summarize per source: what was found, date, one-line takeaway. Note explicitly when nothing was found (common, not a red flag). Contradictions with the resume go in the prep notes as questions to ask, not accusations.

## Full candidate prep template

```markdown
# Candidate Prep — <Name> (<role>)

## Resume summary
<one paragraph>
- Strengths: …
- Gaps vs role: …
- Red flags / to verify: …

## Online research
- GitHub: … | npm: … | Talks/blog: …
- Resume cross-check: <matches / discrepancies to probe>

## Questions
### Screening
1. …
### Deep-dive
1. … (maps to: <repo/tech>)
### Architecture
1. … (maps to: <repo/tech>)

## Verdict guidance
What a strong vs weak answer looks like for the 2–3 highest-signal questions.
```
