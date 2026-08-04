# Programming Newsletters

Read the latest programming newsletter issues. No email needed.

[programmingnewsletters.com](https://programmingnewsletters.com)

---

## How it works

A Perl static site generator that scrapes programming newsletter feeds daily, groups current issues by date, and outputs a single-page site. No backend at runtime — just HTML served from Netlify.

```text
private/newsletters.json       <- newsletter definitions (name, URL, selectors)
        |
   Newsletters.pm              <- scrapes RSS feeds + HTML pages
        |
     Cache.pm                  <- caches results to avoid re-scraping
        |
   Presenter.pm                <- sorts by date, groups, extracts categories
        |
   Build::JSON.pm              <- writes public/index.json + source-health.json
        |
   +----+------------+
   |    |             |
 HTML  CSS           JS         <- minified via Packer modules
   |    |             |
   +----+------------+
        |
    public/                     <- static output, deployed to Netlify
```

The site auto-detects light/dark mode, filters by category client-side, and works without JavaScript (filters just hide).

## Get running

```bash
git clone git@github.com:szTheory/programmingnewsletters.com.git
cd programmingnewsletters.com
docker compose up
# -> localhost:8000
```

That's it. Docker handles Perl 5.38, Carton deps, building, and serving.

## Build commands

All commands run inside Docker:

```bash
# Full rebuild -- scrape all newsletters, regenerate everything
docker compose exec dev carton exec perl Run.pm --rebuild

# Use cache -- only scrape if no cache exists
docker compose exec dev carton exec perl Run.pm

# Test a single newsletter -- scrape only the first entry in newsletters.json
docker compose exec dev carton exec perl Run.pm --rebuild --first-only

# Assets only -- regenerate HTML/CSS/JS from existing JSON (instant, no network)
docker compose exec dev carton exec perl Run.pm --assets-only
```

`--assets-only` is useful when iterating on templates or CSS. It skips scraping entirely and rebuilds the frontend from `public/index.json`.

## Quality checks

Run the high-value regression checks in the same container used for development and CI:

```bash
docker compose run --rm --no-deps dev carton exec prove -lv t
docker compose run --rm --no-deps dev carton exec perl -c Run.pm
```

The checks cover URL normalization and scheme validation, freshness boundaries, and low-confidence source dates. GitHub Actions runs them for pull requests and pushes to `master`.

## Add a newsletter

1. Add an entry to `private/newsletters.json` (put it first in the array for testing):

```json
{
  "category": "JavaScript",
  "name": "Node Weekly",
  "url": "https://nodeweekly.com/latest",
  "feed_url": "https://nodeweekly.com/rss/"
}
```

1. Test it:

```bash
docker compose exec dev carton exec perl Run.pm --rebuild --first-only
```

1. If it works, move the entry to its alphabetical position. If it fails, check `private/broken-newsletters.md` for common fixes.

Most newsletters work with just `feed_url` (RSS). For sites without RSS, use CSS/XPath selectors:

```json
{
  "category": "Security",
  "name": "Bug Bytes",
  "url": "https://www.intigriti.com/researchers/blog/bug-bytes",
  "link_selector": "a[href*='bug-bytes']",
  "updated_selector": "time",
  "updated_attr": "datetime"
}
```

See existing entries in `newsletters.json` for more selector patterns.

## Project structure

```text
Run.pm                          <- entry point (CLI flags)
lib/
  Build.pm                      <- orchestrator
  Build/HTML.pm                 <- template -> public/index.html
  Build/CSS.pm                  <- normalize + main -> public/css/index.css
  Build/JavaScript.pm           <- minify -> public/javascript/main.js
  Build/JSON.pm                 <- presenter data -> public/index.json
  Newsletters.pm                <- RSS + HTML scraper
  Cache.pm                      <- read/write newsletters-cache.json
  Presenter.pm                  <- sort, group, format
private/
  newsletters.json              <- newsletter definitions (the source of truth)
  templates/index.html.ep       <- Mojo::Template HTML template
  css/main.css                  <- design system (CSS custom properties, BEM)
  javascript/main.js            <- client-side category filtering
  DESIGN.md                     <- brand guide and design tokens
public/                         <- generated output (do not edit)
```

## Deploy

Pushes to `master` trigger a Netlify build. The build command is in `netlify.toml` — it installs Perl deps and runs the full scrape + generate pipeline.

## API

`public/index.json` is the API. It contains every newsletter entry grouped by date, plus the category list. It's the same data the HTML is built from.

Each entry includes an ISO-8601 `updated_at` timestamp. `public/source-health.json` reports the generated time and each source's `current`, `stale`, `failed`, or `low_confidence` state; raw remote errors are deliberately never published.

```bash
curl https://programmingnewsletters.com/index.json
```

## Curation policy

Sources must provide public, direct HTTPS issue links. A source is current for three of its configured cadence periods (30 days by default); stale, failed, and fixed-weekday-only sources are quarantined from the primary feed and surfaced in `source-health.json` for review. They are not removed automatically.

Potential additions belong in `private/candidates.json` until their feed/archive, freshness, fit, and extraction are reviewed.
