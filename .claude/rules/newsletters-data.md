# Newsletter Data Management

## Data File

`private/newsletters.json` — single JSON file, structure: `{ "entries": [ ... ] }`

## Entry Schema

### Required fields (every entry):
- `category` — e.g. "DevOps", "Security", "Programming Languages"
- `name` — display name shown on site
- `url` — newsletter page URL

### RSS/feed-based entries add:
- `feed_url` — RSS or Atom feed URL (parsed with XML::Twig)

### HTML scraping configuration (optional):
- `link_selector` — CSS selector for latest issue link
- `updated_selector` — CSS selector for timestamp element
- `updated_regex` — regex to extract date from selected text
- `base_url` — prepended to relative URLs after scraping
- `follow_link` — boolean; two-pass scrape (get link, then follow it for timestamp)
- `link_attr` — read link from element attribute (default: href)
- `link_last` — use last matching link instead of first
- `link_contains_text` — filter links by text substring match
- `link_base_filter` — regex filter for links
- `link_constant` — fixed URL that never changes
- `link_regex` — regex to extract link from text
- `updated_attr` — get timestamp from element attribute instead of text content
- `updated_fixed_day` — fixed publish weekday (e.g. "Thursday")
- `updated_link_attr` — link contained in timestamp element's attribute
- `european_date_format` — boolean; day/month/year ordering
- `translate_french_timestamp` — boolean; translate French month names

## Categories

Dynamically derived from all entries, alphabetically sorted. "All" is prepended as the first filter option. Current categories include: AI, Backend Web Frameworks, Compilers, Cryptocurrency, Data Science, Databases, DevOps, Frontend Web Frameworks, Game Dev, IT, JavaScript, Linux, Mac, Mobile, Networking, Open Source, Programming Languages, Security, Software Engineering, Testing, UI/Frontend, WordPress.

## Removing a Newsletter

1. Delete the entry object from `private/newsletters.json`
2. Ensure valid JSON (no trailing commas)
3. Verify: `carton exec perl Run.pm --rebuild --first-only`
4. Commit message: "Remove outdated newsletter" or "Remove outdated newsletters"

## Adding a Newsletter

1. Add entry object at the **top** of the `entries` array
2. Test: `carton exec perl Run.pm --rebuild --first-only` (only scrapes first entry)
3. Preview: `python3 -m http.server --directory public`
4. Commit message: "Add X newsletter"

## Cache

- Location: `private/newsletters-cache.json` (gitignored)
- Populated on first build, reused on subsequent builds
- Bypass with `--rebuild` flag
- `--first-only` processes only the first entry (fast iteration during development)

## Scraping Behavior

- HTTP timeout: 5 seconds per request
- User-Agent: Mozilla Firefox string (avoids bot blocking)
- CloudFlare/Cloudfront detection: warns and returns empty
- Entries with no valid `updated_at` timestamp are filtered out by `Presenter::_remove_empty`
