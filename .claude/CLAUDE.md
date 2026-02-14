# ProgrammingNewsletters.com

Perl 5.38.2 static site generator. Scrapes ~100 programming newsletter RSS feeds and HTML pages, sorts by last updated, and builds a single-page static site deployed on Netlify.

@README.md

For fresh machine setup, see `.claude/rules/local-setup.md` (Docker recommended, or native with asdf).

## Project Structure

- `Run.pm` — Entry point. Parses `--rebuild` and `--first-only` flags, delegates to Build
- `lib/Build.pm` — Orchestrator: calls JSON, HTML, CSS, JS build steps in sequence
- `lib/Newsletters.pm` — Scrapes RSS (XML::Twig) and HTML (Mojo::DOM) sources (468 lines)
- `lib/Presenter.pm` — Sorts by date, groups entries, formats timestamps, filters fields
- `lib/Cache.pm` — Read/write cache at `private/newsletters-cache.json`
- `lib/Translate.pm` — French month name → English translation
- `lib/Build/JSON.pm` — Runs presenter pipeline → writes `public/index.json`
- `lib/Build/HTML.pm` — Renders Mojo::Template → minifies with HTML::Packer → `public/index.html`
- `lib/Build/CSS.pm` — Concatenates 3 CSS files → minifies with CSS::Packer → `public/css/index.css`
- `lib/Build/JavaScript.pm` — Minifies with JavaScript::Packer → `public/javascript/`
- `private/newsletters.json` — Newsletter registry (source of truth, ~117 entries)
- `private/css/` — Source CSS: normalize.css, default.css, main.css (concatenated in this order)
- `private/javascript/main.js` — Vanilla JS category filter (68 lines)
- `private/templates/index.html.ep` — Mojo::Template (single page, 70 lines)
- `public/` — Generated output directory (most files gitignored)

## Build Commands

- **Full build:** `carton exec perl Run.pm`
- **Force rebuild (bypass cache):** `carton exec perl Run.pm --rebuild`
- **Single-entry test build:** `carton exec perl Run.pm --rebuild --first-only`
- **Local dev server:** `python3 -m http.server --directory public` (port 8000)

## Build Pipeline Order

Order matters — each step depends on the previous:
1. `write_json_file()` — Scrape feeds → cache → process → `public/index.json`
2. `write_html_file()` — Read JSON, render template, minify → `public/index.html`
3. `write_css_files()` — Concatenate and minify CSS → `public/css/index.css`
4. `write_js_files()` — Minify JS → `public/javascript/`

## Deployment

- GitHub Actions cron (daily 15:15 UTC) triggers Netlify build webhook
- Build config in `netlify.toml` — installs cpanm, Carton, deps, then runs `Run.pm`
- Netlify build image: Ubuntu Noble 24.04 (system Perl 5.38.2)
- Netlify MCP server available for AI-assisted deploy management (configured in Cursor)
- Config: `.github/workflows/main.yml` (webhook trigger), `netlify.toml` (build command)

## Critical Constraints

- Perl 5.38.2 — system Perl on Ubuntu Noble 24.04 (matches Netlify build image)
- Docker local dev uses `ubuntu:24.04` base to match Netlify environment
- `carton install --deployment` for reproducible locked builds (cpanfile.snapshot is current)
- No test suite — verify changes manually with `--first-only` builds and local server
- Generated files in `public/` are gitignored (except favicon.ico, icon.png, site.webmanifest)
- Solo developer, trunk-based workflow: commit directly to master
- Commit messages: "Add X newsletter", "Remove outdated newsletters", "Fix broken newsletters"
