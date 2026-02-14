# Broken Newsletters Report

Generated: 2026-02-13 (from Docker `--rebuild` run)

## How to fix

Move the newsletter to position #1 in `private/newsletters.json`, then run:
```bash
docker compose exec dev carton exec perl Run.pm --rebuild --first-only
```
Visit the URL manually, decide to fix the scraper config or remove the entry.

---

## Removed (confirmed dead)

- ~~Week That Was~~ — Cloudfront blocks Netlify (removed)
- ~~Signals and Space~~ — dead (removed)
- ~~Frontend Weekly~~ — dead (removed)
- ~~Le courrier du hacker (FR)~~ — dead (removed)
- ~~Skynet Today~~ — dead (removed)
- ~~LLVM Weekly~~ — fixed typo handling in RSS path (`Feburary` → `February`)
- ~~Cloud Security Reading List~~ — fixed selectors (`//entry/id` → `//item/link`, `//entry/published` → `//item/pubDate`)
- ~~Weekly Xamarin~~ — dead (removed)
- ~~CentOS Community Newsletter~~ — dead (removed)
- ~~CryptoWeekly~~ — dead (removed)
- ~~Bug Bytes~~ — fixed URL + selectors (moved to intigriti.com/researchers/blog/bug-bytes)
- ~~Data Science News~~ — dead (removed)
- ~~Julia Monthly Newsletter~~ — dead (removed)
- ~~H+ AI Newsletter~~ — fixed, moved to Substack RSS (humanityredefined.com/feed) + added `link_contains_text` filter for Sync issues
- ~~Changelog Weekly~~ — fixed, switched to RSS feed (changelog.com/news/feed)
- ~~GraphQL Weekly~~ — fixed selectors for new site design (`a[href*="/issues/"]`)
- ~~Python Weekly~~ — newsletterest.com broken (removed)
- ~~WebAIM Accessibility~~ — newsletterest.com broken (removed)
- ~~Gamedev.js Weekly~~ — newsletterest.com broken (removed)
- ~~Google Cloud Weekly~~ — newsletterest.com broken (removed)
- ~~Laravel News~~ — newsletterest.com broken (removed)
- ~~20 libhunt.com newsletters~~ — removed (were working from Docker but 403 on Netlify)
- ~~Advisory Week~~ — dead (removed)
- ~~Better Dev Link~~ — dead (removed)
- ~~Kubelist~~ — outdated since 2022 (removed)
- ~~The Sequence of AI Knowledge~~ — paywalled (removed)
- ~~SecAlerts~~ — dead (removed)
- ~~DevOps Bulletin~~ — fixed, switched to Substack RSS (devopsbulletin.com/feed)
- ~~Self Hosted Weekly Roundup~~ — dead (removed)
- ~~API Security Weekly~~ — duplicate of API Security Newsletter (removed)

---

## Feed Download Failures (3)

These feeds fail to download from Docker (likely user-agent or IP filtering). Config is correct — may work on Netlify.

| Newsletter | Feed URL | Error |
|---|---|---|
| The WP Weekly | https://thewpweekly.com/feed/ | `500 Server closed connection` |
| Packet Pushers | https://us2.campaign-archive.com/feed?u=5e5640dc2e2a939f35bf54df2&id=485084dd79 | unknown |
| Distro Watch | https://distrowatch.com/news/dww.xml | `403 Forbidden` |

---

## Summary

| Error Type | Count |
|---|---|
| Feed download failures (Docker only) | 3 |
| **Total remaining broken** | **~3** |

## Notes

- The WP Weekly and Distro Watch feeds work in browser but fail from Docker — server blocks the scraper's user agent. Configs are correct. May work on Netlify.
- Distro Watch uses RDF/RSS 1.0 format with `item/dc:date` selector (already configured).
